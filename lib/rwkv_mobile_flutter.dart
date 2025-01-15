library rwkv_mobile_flutter;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

/// Runtime backend of RWKV flutter
enum Backend {
  /// Currently we use it on Android, Windows and Linux
  ///
  /// https://github.com/Tencent/ncnn
  ncnn,

  /// Currently only support iOS and macOS
  ///
  /// https://github.com/cryscan/web-rwkv
  webRwkv;

  String get asArgument {
    switch (this) {
      case Backend.ncnn:
        return 'ncnn';
      case Backend.webRwkv:
        return 'web-rwkv';
    }
  }
}

class StartOptions {
  final String modelPath;
  final String tokenizerPath;
  final Backend backend;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  const StartOptions(
    this.modelPath,
    this.tokenizerPath,
    this.backend,
    this.sendPort,
    this.rootIsolateToken,
  );
}

class RWKVMobile {
  Isolate? _isolate;

  bool get isRunning => _isolate != null;

  Future<void> runIsolate(
    String modelPath,
    String tokenizerPath,
    Backend backend,
    SendPort sendPort,
    RootIsolateToken rootIsolateToken,
  ) async {
    if (_isolate != null) {
      throw Exception('Isolate already running');
    }

    _isolate = await Isolate.spawn(
        isolateMain,
        StartOptions(
          modelPath,
          tokenizerPath,
          backend,
          sendPort,
          rootIsolateToken,
        ));
  }

  ffi.DynamicLibrary getDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('librwkv_mobile.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    } else {
      throw Exception('Unsupported platform');
    }
  }

  // TODO: @Molly rwkv_mobile has this function, but it's not exported yet
  String getAvailableBackendNames() {
    final rwkvMobile = rwkv_mobile(getDynamicLibrary());
    const backendNamesLength = 64; // should be enough
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(backendNamesLength);
    rwkvMobile.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  void isolateMain(StartOptions options) async {
    final sendPort = options.sendPort;
    final rootIsolateToken = options.rootIsolateToken;
    final modelPath = options.modelPath;
    final modelBackend = options.backend.asArgument;
    final tokenizerPath = options.tokenizerPath;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final rwkvMobile = rwkv_mobile(getDynamicLibrary());
    final modelPathPointer = modelPath.toNativeUtf8();

    final runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackend.toNativeUtf8().cast<ffi.Char>());
    if (runtime == ffi.nullptr) {
      throw Exception('Failed to initialize runtime');
    }

    int retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load tokenizer');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPathPointer.cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load model');
    }
    // initializations done

    int maxLength = 2000;
    int maxMessages = 1000;
    int generationStopToken = 0; // Takes effect in 'generation' mode; not used in 'chat' mode
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(maxLength);
    final inputsPtr = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);

    // bool isGenerating = false;
    await for (final (String, dynamic) message in receivePort) {
      // print("💬 message: ${message.runtimeType}");
      // message: (String command, Dynamic args)
      final command = message.$1;
      if (command == 'setMaxLength') {
        final arg = message.$2 as int;
        if (arg > 0) {
          maxLength = arg;
          calloc.free(responseBuffer);
          responseBuffer = calloc.allocate<ffi.Char>(maxLength);
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
          'samplerParams': {
            'temperature': samplerParams.temperature,
            'top_k': samplerParams.top_k,
            'top_p': samplerParams.top_p,
            'presence_penalty': penaltyParams.presence_penalty,
            'frequency_penalty': penaltyParams.frequency_penalty,
            'penalty_decay': penaltyParams.penalty_decay,
          }
        });
      } else if (command == 'message') {
        final messages = message.$2 as List<String>;
        for (var i = 0; i < messages.length; i++) {
          inputsPtr[i] = messages[i].toNativeUtf8().cast<ffi.Char>();
        }
        final numInputs = messages.length;

        callbackFunction(ffi.Pointer<ffi.Char> responseBuffer) {
          final response = responseBuffer.cast<Utf8>().toDartString();
          sendPort.send({'streamResponse': response});
          // TODO: @Molly send stop signal back to native code
        }

        final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>)>.isolateLocal(callbackFunction);

        sendPort.send({'generateStart': true});
        if (kDebugMode) print("💬 Start to call LLM (chat mode)");
        retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history(runtime, inputsPtr, numInputs, responseBuffer, maxLength, nativeCallable.nativeFunction);
        if (kDebugMode) print("💬 Call LLM done (chat mode)");
        if (retVal != 0) {
          throw Exception('Failed to evaluate chat');
        }
        final response = responseBuffer.cast<Utf8>().toDartString();
        sendPort.send({'response': response});
        sendPort.send({'generateStop': true});
      } else if (command == 'generate') {
        final prompt = message.$2 as String;
        final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();
        String responseStr = prompt;

        callbackFunction(ffi.Pointer<ffi.Char> stream, int idx) {
          responseStr += stream.cast<Utf8>().toDartString();
          sendPort.send({'streamResponse': stream.cast<Utf8>().toDartString(), 'streamResponseToken': idx});
        }

        final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int)>.isolateLocal(callbackFunction);
        sendPort.send({'generateStart': true});
        if (kDebugMode) print("💬 Start to call LLM (gen mode), maxlength = $maxLength");
        retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(runtime, promptPtr, responseBuffer, maxLength, generationStopToken, nativeCallable.nativeFunction);
        if (kDebugMode) print("💬 Call LLM done (gen mode)");
        if (retVal != 0) {
          throw Exception('Failed to evaluate generation');
        }

        sendPort.send({'response': responseStr});
        sendPort.send({'generateStop': true});
      } else {
        if (kDebugMode) print("😡 unknown command: $command");
      }
    }
  }
}
