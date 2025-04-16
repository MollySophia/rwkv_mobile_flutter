// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
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

  static const _codec = Utf8Codec(allowMalformed: true);

  Future<void> runIsolate(StartOptions options) async {
    if (_isolate != null) {
      throw Exception('😡 Isolate already running');
    }
    _isolate = await Isolate.spawn(_isolateMain, options);
  }

  static ffi.DynamicLibrary _getDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('librwkv_mobile.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    } else if (Platform.isLinux) {
      final abi = ffi.Abi.current();
      if (abi == ffi.Abi.linuxX64) {
        return ffi.DynamicLibrary.open('librwkv_mobile-linux-x86_64.so');
      } else if (abi == ffi.Abi.linuxArm64) {
        return ffi.DynamicLibrary.open('librwkv_mobile-linux-aarch64.so');
      } else {
        throw Exception('😡 Unsupported ABI: ${abi.toString()}');
      }
    } else {
      throw Exception('😡 Unsupported platform');
    }
  }

  static String getAvailableBackendNames() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    const backendNamesLength = 64; // should be enough
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(backendNamesLength);
    rwkvMobile.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  static String getPlatformName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final platformName = rwkvMobile.rwkvmobile_get_platform_name();
    if (kDebugMode) print("💬 platformName: ${platformName.cast<Utf8>().toDartString()}");
    return platformName.cast<Utf8>().toDartString();
  }

  static String getSocName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final socName = rwkvMobile.rwkvmobile_get_soc_name();
    if (kDebugMode) print("💬 socName: ${socName.cast<Utf8>().toDartString()}");
    return socName.cast<Utf8>().toDartString();
  }

  static String getSocPartname() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final socPartname = rwkvMobile.rwkvmobile_get_soc_partname();
    return socPartname.cast<Utf8>().toDartString();
  }

  static String getSnapdragonHtpArch() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final snapdragonHtpArch = rwkvMobile.rwkvmobile_get_htp_arch();
    if (kDebugMode) print("💬 snapdragonHtpArch: ${snapdragonHtpArch.cast<Utf8>().toDartString()}");
    return snapdragonHtpArch.cast<Utf8>().toDartString();
  }

  void _isolateMain(StartOptions options) async {
    final sendPort = options.sendPort;
    final rootIsolateToken = options.rootIsolateToken;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    // TODO: We can call this when the app is launched, rather than when the model is selected
    // TODO: We can load the runtime in the future. Only Apple cannot.
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());

    // definitions
    int maxLength = 2000;
    int maxMessages = 1000;
    int generationStopToken = 0; // Takes effect in 'generation' mode; not used in 'chat' mode
    int retVal = 0;
    int enableReasoning = 0;
    // bool isGenerating = false;

    final inputsPtr = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);

    var modelPath = options.modelPath;
    var modelBackend = options.backend.asArgument;
    var tokenizerPath = options.tokenizerPath;

    rwkvmobile_runtime_t runtime;

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
      throw Exception('😡 Failed to initialize runtime');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('😡 Failed to load tokenizer, tokenizer path: $tokenizerPath');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('😡 Failed to load model, model path: $modelPath');
    }

    await for (final (String, dynamic) message in receivePort) {
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
          sendPort.send({'error': 'Failed to set prompt: return value: $retVal'});
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
      } else if (command == 'getIsGenerating') {
        bool isGeneratingBool = (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0);
        sendPort.send({'isGenerating': isGeneratingBool});
      } else if (command == 'setThinkingToken') {
        final arg = message.$2 as String;
        final thinkingTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_thinking_token(runtime, thinkingTokenPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set thinking token'});
        }
      } else if (command == 'setEosToken') {
        final arg = message.$2 as String;
        final eosTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_eos_token(runtime, eosTokenPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set eos token'});
        }
      } else if (command == 'setBosToken') {
        final arg = message.$2 as String;
        final bosTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_bos_token(runtime, bosTokenPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set bos token'});
        }
      } else if (command == 'setTokenBanned') {
        final arg = message.$2 as List<int>;
        final tokenBannedPtr = calloc.allocate<ffi.Int>(arg.length);
        for (var i = 0; i < arg.length; i++) {
          tokenBannedPtr[i] = arg[i];
        }
        retVal = rwkvMobile.rwkvmobile_runtime_set_token_banned(runtime, tokenBannedPtr, arg.length);
        calloc.free(tokenBannedPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set token banned'});
        }
      } else if (command == 'setUserRole') {
        final arg = message.$2 as String;
        final userRolePtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_user_role(runtime, userRolePtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set user role'});
        }
      } else if (command == 'loadVisionEncoder') {
        final arg = message.$2 as String;
        final encoderPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder(runtime, encoderPathPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to load vision encoder'});
        }
      } else if (command == 'releaseVisionEncoder') {
        retVal = rwkvMobile.rwkvmobile_runtime_release_vision_encoder(runtime);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to release vision encoder'});
        }
      } else if (command == 'setVisionPrompt') {
        final arg = message.$2 as String;
        final imagePathPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_image_prompt(runtime, imagePathPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set image prompt'});
        }
      } else if (command == 'loadWhisperEncoder') {
        final arg = message.$2 as String;
        final encoderPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_load_whisper_encoder(runtime, encoderPathPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to load whisper encoder'});
        }
      } else if (command == 'releaseWhisperEncoder') {
        retVal = rwkvMobile.rwkvmobile_runtime_release_whisper_encoder(runtime);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to release whisper encoder'});
          continue;
        }
      } else if (command == 'setAudioPrompt') {
        final arg = message.$2 as String;
        final audioPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
        retVal = rwkvMobile.rwkvmobile_runtime_set_audio_prompt(runtime, audioPathPtr);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to set audio prompt'});
        }
      } else if (command == 'message') {
        final messages = message.$2 as List<String>;
        for (var i = 0; i < messages.length; i++) {
          inputsPtr[i] = messages[i].toNativeUtf8().cast<ffi.Char>();
        }
        final numInputs = messages.length;

        if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
          sendPort.send({'error': 'LLM is already generating'});
          continue;
        }

        sendPort.send({'generateStart': true});
        if (kDebugMode) print("💬 Starting LLM generation thread (chat mode)");
        retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history(runtime, inputsPtr, numInputs, maxLength, ffi.nullptr, enableReasoning);
        if (kDebugMode) print("💬 Started LLM generation thread (chat mode)");
        if (retVal != 0) {
          sendPort.send({'generateStop': true, 'error': 'Failed to start generation thread: retVal: $retVal'});
        }
      } else if (command == 'generate') {
        final prompt = message.$2 as String;
        final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();

        if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
          sendPort.send({'error': 'LLM is already generating'});
          continue;
        }

        sendPort.send({'generateStart': true});
        if (kDebugMode) print("🔥 Starting LLM generation thread (gen mode), maxlength = $maxLength");
        retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(runtime, promptPtr, maxLength, generationStopToken, ffi.nullptr);
        if (kDebugMode) print("🔥 Started LLM generation thread (gen mode)");
        if (retVal != 0) {
          sendPort.send({'generateStop': true, 'error': 'Failed to start generation'});
        }
      } else if (command == 'generateBlocking') {
        final prompt = message.$2 as String;
        final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();
        String responseStr = prompt;

        callbackFunction(ffi.Pointer<ffi.Char> stream, int idx) {
          final prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime);
          final decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime);
          responseStr += stream.cast<Utf8>().toDartString();
          sendPort.send({'streamResponse': stream.cast<Utf8>().toDartString(), 'streamResponseToken': idx, 'prefillSpeed': prefillSpeed, 'decodeSpeed': decodeSpeed});
        }

        final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int)>.isolateLocal(callbackFunction);
        sendPort.send({'generateStart': true});
        if (kDebugMode) print("🔥 Start to call LLM (gen mode), maxlength = $maxLength");
        retVal = rwkvMobile.rwkvmobile_runtime_gen_completion_blocking(runtime, promptPtr, maxLength, generationStopToken, nativeCallable.nativeFunction);
        if (kDebugMode) print("🔥 Call LLM done (gen mode)");
        if (retVal != 0) {
          sendPort.send({'generateStop': true, 'error': 'Failed to start generation'});
          continue;
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
      } else if (command == 'stop') {
        if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1) {
          retVal = rwkvMobile.rwkvmobile_runtime_stop_generation(runtime);
          if (retVal != 0) {
            sendPort.send({'generateStop': false, 'error': 'Failed to stop generation'});
          }
          while (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1) {
            if (kDebugMode) print("💬 Waiting for generation to stop...");
            await Future.delayed(const Duration(milliseconds: 10));
            rwkvMobile.rwkvmobile_runtime_stop_generation(runtime);
          }
          if (kDebugMode) print("💬 Generation stopped");
          sendPort.send({'generateStop': true});
        }
      } else if (command == 'getResponseBufferContent') {
        final responseBufferContent = rwkvMobile.rwkvmobile_runtime_get_response_buffer_content(runtime);
        int length = responseBufferContent.length;
        // TODO: @molly 有没有可能有一个回调函数, 每次只返回一个字符?
        final Uint8List byteList = responseBufferContent.content.cast<ffi.Uint8>().asTypedList(length);
        final String str = _codec.decode(byteList);
        sendPort.send({'responseBufferContent': str});
      } else if (command == 'getPrefillAndDecodeSpeed') {
        final prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime);
        final decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime);
        sendPort.send({'prefillSpeed': prefillSpeed, 'decodeSpeed': decodeSpeed});
      } else if (command == 'getResponseBufferIds') {
        final responseBufferIds = rwkvMobile.rwkvmobile_runtime_get_response_buffer_ids(runtime);
        final responseBufferIdsList = responseBufferIds.ids.asTypedList(responseBufferIds.len).toList();
        rwkvMobile.rwkvmobile_runtime_free_token_ids(responseBufferIds);
        sendPort.send({'responseBufferIds': responseBufferIdsList});
      } else if (command == 'loadTTSModels') {
        final args = message.$2 as Map<String, dynamic>;
        final campPlusPath = args['campPlusPath'] as String;
        final flowDecoderEstimatorPath = args['flowDecoderEstimatorPath'] as String;
        final flowEncoderPath = args['flowEncoderPath'] as String;
        final hiftGeneratorPath = args['hiftGeneratorPath'] as String;
        final speechTokenizerPath = args['speechTokenizerPath'] as String;
        final ttsTokenizerPath = args['ttsTokenizerPath'] as String;
        retVal = rwkvMobile.rwkvmobile_runtime_cosyvoice_load_models(runtime, speechTokenizerPath.toNativeUtf8().cast<ffi.Char>(), campPlusPath.toNativeUtf8().cast<ffi.Char>(), flowEncoderPath.toNativeUtf8().cast<ffi.Char>(), flowDecoderEstimatorPath.toNativeUtf8().cast<ffi.Char>(), hiftGeneratorPath.toNativeUtf8().cast<ffi.Char>(), ttsTokenizerPath.toNativeUtf8().cast<ffi.Char>());
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to load TTS models'});
        }
      } else if (command == 'releaseTTSModels') {
        retVal = rwkvMobile.rwkvmobile_runtime_cosyvoice_release_models(runtime);
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to release TTS models'});
        }
      } else if (command == 'runTTSZeroshot') {
        final args = message.$2 as Map<String, dynamic>;
        final ttsText = args['ttsText'] as String;
        final instructionText = args['instructionText'] as String;
        final promptWavPath = args['promptWavPath'] as String;
        final outputWavPath = args['outputWavPath'] as String;
        retVal = rwkvMobile.rwkvmobile_runtime_tts_zero_shot(runtime, ttsText.toNativeUtf8().cast<ffi.Char>(), instructionText.toNativeUtf8().cast<ffi.Char>(), promptWavPath.toNativeUtf8().cast<ffi.Char>(), outputWavPath.toNativeUtf8().cast<ffi.Char>());
        if (retVal != 0) {
          sendPort.send({'error': 'Failed to run TTS zeroshot'});
        } else {
          sendPort.send({'ttsDone': true, 'outputWavPath': outputWavPath});
        }
      } else {
        if (kDebugMode) print("😡 unknown command: $command");
      }
    }
  }
}
