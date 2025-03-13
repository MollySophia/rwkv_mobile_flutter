import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkv_mobile_flutter/types.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

class RWKVMobile {
  Isolate? _isolate;

  bool get isRunning => _isolate != null;

  Future<void> runIsolate(StartOptions options) async {
    if (_isolate != null) {
      throw Exception('Isolate already running');
    }
    _isolate = await Isolate.spawn(_isolateMain, options);
  }

  ffi.DynamicLibrary _getDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('librwkv_mobile.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    } else {
      // TODO: @Molly: Do we need to support other Linux?
      throw Exception('Unsupported platform');
    }
  }

  String getAvailableBackendNames() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    const backendNamesLength = 64; // should be enough
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(backendNamesLength);
    rwkvMobile.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  void _isolateMain(StartOptions options) async {
    final sendPort = options.sendPort;
    final rootIsolateToken = options.rootIsolateToken;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());

    // definitions
    int maxLength = 2000;
    int maxMessages = 1000;
    int generationStopToken = 0; // Takes effect in 'generation' mode; not used in 'chat' mode
    int retVal = 0;
    int enableReasoning = 0;
    // bool isGenerating = false;

    String responseBuffer = '';
    final inputsPtr = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);

    var modelPath = options.modelPath;
    var modelBackend = options.backend.asArgument;
    var tokenizerPath = options.tokenizerPath;

    var runtime;

    var speedReportCounter = 0;
    (double?, double?) getPrefillAndDecodeSpeed() {
      double? prefillSpeed;
      double? decodeSpeed;
      if (speedReportCounter % 10 == 0) {
        prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime);
        decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime);
        sendPort.send({'prefillSpeed': prefillSpeed, 'decodeSpeed': decodeSpeed});
      }
      speedReportCounter++;
      return (prefillSpeed, decodeSpeed);
    }

    // runtime initializations
    if (modelBackend == 'qnn') {
      // TODO: better solution for this
      final tempDir = await getTemporaryDirectory();
      if (kDebugMode) print("💬 tempDir: ${tempDir.path}");
      rwkvMobile.rwkvmobile_runtime_add_adsp_library_path((tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());

      runtime = rwkvMobile.rwkvmobile_runtime_init_with_name_extra(modelBackend.toNativeUtf8().cast<ffi.Char>(), (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>());
    } else {
      runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackend.toNativeUtf8().cast<ffi.Char>());
    }

    if (runtime.address == 0) {
      throw Exception('Failed to initialize runtime');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load tokenizer, tokenizer path: $tokenizerPath');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load model, model path: $modelPath');
    }

    await for (final (String, dynamic) message in receivePort) {
      // print("💬 message: ${message.runtimeType}");
      // message: (String command, Dynamic args)
      final command = message.$1;
      if (command == 'setMaxLength') {
        final arg = message.$2 as int;
        if (arg > 0) {
          maxLength = arg;
        }
      } else if (command == 'clearStates') {
        rwkvMobile.rwkvmobile_runtime_clear_state(runtime);
      } else if (command == 'setGenerationStopToken') {
        final arg = message.$2 as int;
        if (arg >= 0) {
          generationStopToken = arg;
        }
      } else if (command == 'setPrompt') {
        final prompt = message.$2 as String;
        final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_prompt(runtime, promptPtr);
        if (retVal != 0) {
          throw Exception('Failed to set prompt');
        }
      } else if (command == 'getPrompt') {
        final stringBuffer = calloc.allocate<ffi.Char>(maxLength);
        rwkvMobile.rwkvmobile_runtime_get_prompt(runtime, stringBuffer, maxLength);
        final prompt = stringBuffer.cast<Utf8>().toDartString();
        sendPort.send({'currentPrompt': prompt});
        calloc.free(stringBuffer);
      } else if (command == 'setSamplerParams') {
        final args = message.$2 as Map<String, dynamic>;
        final samplerParams = ffi.Struct.create<sampler_params>();
        final penaltyParams = ffi.Struct.create<penalty_params>();
        samplerParams.temperature = args['temperature'] as double;
        samplerParams.top_k = args['top_k'] as int;
        samplerParams.top_p = args['top_p'] as double;
        penaltyParams.presence_penalty = args['presence_penalty'] as double;
        penaltyParams.frequency_penalty = args['frequency_penalty'] as double;
        penaltyParams.penalty_decay = args['penalty_decay'] as double;
        rwkvMobile.rwkvmobile_runtime_set_sampler_params(runtime, samplerParams);
        rwkvMobile.rwkvmobile_runtime_set_penalty_params(runtime, penaltyParams);
      } else if (command == 'getSamplerParams') {
        final samplerParams = rwkvMobile.rwkvmobile_runtime_get_sampler_params(runtime);
        final penaltyParams = rwkvMobile.rwkvmobile_runtime_get_penalty_params(runtime);
        sendPort.send({
          'samplerParams': {'temperature': samplerParams.temperature, 'top_k': samplerParams.top_k, 'top_p': samplerParams.top_p, 'presence_penalty': penaltyParams.presence_penalty, 'frequency_penalty': penaltyParams.frequency_penalty, 'penalty_decay': penaltyParams.penalty_decay},
        });
      } else if (command == 'setEnableReasoning') {
        final arg = message.$2 as bool;
        if (arg) {
          enableReasoning = 1;
        } else {
          enableReasoning = 0;
        }
      } else if (command == 'getEnableReasoning') {
        bool enableReasoningBool = (enableReasoning != 0);
        sendPort.send({'enableReasoning': enableReasoningBool});
      } else if (command == 'message') {
        final messages = message.$2 as List<String>;
        for (var i = 0; i < messages.length; i++) {
          inputsPtr[i] = messages[i].toNativeUtf8().cast<ffi.Char>();
        }
        final numInputs = messages.length;

        callbackFunction(ffi.Pointer<ffi.Char> s) {
          final (prefillSpeed, decodeSpeed) = getPrefillAndDecodeSpeed();
          final responseObject = {
            'streamResponse': s.cast<Utf8>().toDartString(),
            'prefillSpeed': prefillSpeed,
            'decodeSpeed': decodeSpeed,
          };
          try {
            final response = s.cast<Utf8>().toDartString();
            responseBuffer = response;
            sendPort.send({
              'streamResponse': response,
              ...responseObject,
            });
          } catch (e) {
            if (kDebugMode) print("😡 Error: $e");
            sendPort.send({
              'streamResponse': responseBuffer,
              ...responseObject,
            });
          }
        }

        final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>.isolateLocal(callbackFunction);

        sendPort.send({'generateStart': true});
        if (kDebugMode) print("💬 Start to call LLM (chat mode)");
        retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history(runtime, inputsPtr, numInputs, ffi.nullptr, maxLength, nativeCallable.nativeFunction, enableReasoning);
        if (kDebugMode) print("💬 Call LLM done (chat mode)");
        if (retVal != 0) {
          sendPort.send({'generateStop': true});
          throw Exception('Failed to evaluate chat');
        }
        sendPort.send({'response': responseBuffer});
        sendPort.send({'generateStop': true});
      } else if (command == 'generate') {
        final prompt = message.$2 as String;
        final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();
        String responseStr = prompt;

        callbackFunction(ffi.Pointer<ffi.Char> stream, int idx) {
          final (prefillSpeed, decodeSpeed) = getPrefillAndDecodeSpeed();
          responseStr += stream.cast<Utf8>().toDartString();
          sendPort.send({
            'streamResponse': stream.cast<Utf8>().toDartString(),
            'streamResponseToken': idx,
            'prefillSpeed': prefillSpeed,
            'decodeSpeed': decodeSpeed,
          });
        }

        final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int)>.isolateLocal(callbackFunction);
        sendPort.send({'generateStart': true});
        if (kDebugMode) print("💬 Start to call LLM (gen mode), maxlength = $maxLength");
        retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(runtime, promptPtr, ffi.nullptr, maxLength, generationStopToken, nativeCallable.nativeFunction);
        if (kDebugMode) print("💬 Call LLM done (gen mode)");
        if (retVal != 0) {
          throw Exception('Failed to evaluate generation');
        }

        sendPort.send({'response': responseStr});
        sendPort.send({'generateStop': true});
      } else if (command == 'releaseModel') {
        if (kDebugMode) print("💬 Releasing model");
        rwkvMobile.rwkvmobile_runtime_release(runtime);
        runtime = ffi.nullptr;
      } else if (command == 'initRuntime') {
        final args = message.$2 as Map<String, dynamic>;
        modelPath = args['modelPath'] as String;
        modelBackend = args['backend'].asArgument;
        tokenizerPath = args['tokenizerPath'] as String;
        if (runtime.address != 0) {
          rwkvMobile.rwkvmobile_runtime_release(runtime);
        }

        if (modelBackend == 'qnn') {
          // TODO: better solution for this
          final tempDir = await getTemporaryDirectory();
          if (kDebugMode) print("💬 tempDir: ${tempDir.path}");
          rwkvMobile.rwkvmobile_runtime_add_adsp_library_path((tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());

          runtime = rwkvMobile.rwkvmobile_runtime_init_with_name_extra(modelBackend.toNativeUtf8().cast<ffi.Char>(), (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>());
        } else {
          runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackend.toNativeUtf8().cast<ffi.Char>());
        }
        if (runtime.address == 0) {
          sendPort.send({'initRuntimeDone': false, 'error': 'Failed to initialize runtime'});
        } else {
          retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
          if (retVal != 0) {
            sendPort.send({'initRuntimeDone': false, 'error': 'Failed to load tokenizer, tokenizer path: $tokenizerPath'});
          } else {
            retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
            if (retVal != 0) {
              sendPort.send({'initRuntimeDone': false, 'error': 'Failed to load model, model path: $modelPath'});
            } else {
              sendPort.send({'initRuntimeDone': true});
            }
          }
        }
      } else {
        if (kDebugMode) print("😡 unknown command: $command");
      }
    }
  }
}
