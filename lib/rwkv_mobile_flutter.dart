// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkv_mobile_flutter/to_rwkv.dart';
import 'package:rwkv_mobile_flutter/types.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

typedef _FromFrontend = ToRWKV;

// TODO: Use it, depends on "options.sendPort"
typedef _ToFrontend = FromRWKV;

const _codec = Utf8Codec(allowMalformed: true);

class RWKVMobile {
  Isolate? _isolate;

  // TODO: 对 Frontend 隐藏 sendPort
  Future<void> runIsolate(StartOptions options) async {
    if (_isolate != null) throw Exception('😡 Isolate already running');
    _isolate = await Isolate.spawn(_isolateMain, options);
  }

  static ffi.DynamicLibrary _getDynamicLibrary() {
    if (Platform.isAndroid) return ffi.DynamicLibrary.open('librwkv_mobile.so');
    if (Platform.isIOS) return ffi.DynamicLibrary.process();
    if (Platform.isMacOS) return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    if (Platform.isWindows) return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    if (Platform.isLinux) {
      final abi = ffi.Abi.current();
      if (abi == ffi.Abi.linuxX64) return ffi.DynamicLibrary.open('librwkv_mobile-linux-x86_64.so');
      if (abi == ffi.Abi.linuxArm64) return ffi.DynamicLibrary.open('librwkv_mobile-linux-aarch64.so');
      throw Exception('😡 Unsupported ABI: ${abi.toString()}');
    }
    throw Exception('😡 Unsupported platform');
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

    if (kDebugMode) rwkvMobile.rwkvmobile_set_loglevel(RWKV_LOG_LEVEL_DEBUG);

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

    if (runtime.address == 0) throw Exception('😡 Failed to initialize runtime');

    retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) throw Exception('😡 Failed to load tokenizer, tokenizer path: $tokenizerPath');

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) throw Exception('😡 Failed to load model, model path: $modelPath');

    final tempDir = await getTemporaryDirectory();
    rwkvMobile.rwkvmobile_set_cache_dir(runtime, tempDir.path.toNativeUtf8().cast<ffi.Char>());

    await for (final (String, dynamic) message in receivePort) {
      // message: (String command, Dynamic args)
      final command = message.$1;
      final fromFrontend = _FromFrontend.values.byName(command);
      switch (fromFrontend) {
        // 🟥 setMaxLength
        case _FromFrontend.setMaxLength:
          final arg = message.$2 as int;
          if (arg > 0) maxLength = arg;

        // 🟥 clearStates
        case _FromFrontend.clearStates:
          rwkvMobile.rwkvmobile_runtime_clear_state(runtime);

        // 🟥 setGenerationStopToken
        case _FromFrontend.setGenerationStopToken:
          final arg = message.$2 as int;
          if (arg >= 0) generationStopToken = arg;

        // 🟥 setPrompt
        case _FromFrontend.setPrompt:
          final prompt = message.$2 as String;
          final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_prompt(runtime, promptPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set prompt: return value: $retVal'});

        // 🟥 getPrompt
        case _FromFrontend.getPrompt:
          final stringBuffer = calloc.allocate<ffi.Char>(maxLength);
          rwkvMobile.rwkvmobile_runtime_get_prompt(runtime, stringBuffer, maxLength);
          final prompt = stringBuffer.cast<Utf8>().toDartString();
          sendPort.send({'currentPrompt': prompt});
          calloc.free(stringBuffer);

        // 🟥 setSamplerParams
        case _FromFrontend.setSamplerParams:
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

        // 🟥 getSamplerParams
        case _FromFrontend.getSamplerParams:
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

        // 🟥 setEnableReasoning
        case _FromFrontend.setEnableReasoning:
          enableReasoning = message.$2 as bool ? 1 : 0;

        // 🟥 getEnableReasoning
        case _FromFrontend.getEnableReasoning:
          bool enableReasoningBool = (enableReasoning != 0);
          sendPort.send({'enableReasoning': enableReasoningBool});

        // 🟥 getIsGenerating
        case _FromFrontend.getIsGenerating:
          bool isGeneratingBool = (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0);
          sendPort.send({'isGenerating': isGeneratingBool});

        // 🟥 setThinkingToken
        case _FromFrontend.setThinkingToken:
          final arg = message.$2 as String;
          final thinkingTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_thinking_token(runtime, thinkingTokenPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set thinking token'});

        // 🟥 setEosToken
        case _FromFrontend.setEosToken:
          final arg = message.$2 as String;
          final eosTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_eos_token(runtime, eosTokenPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set eos token'});

        // 🟥 setBosToken
        case _FromFrontend.setBosToken:
          final arg = message.$2 as String;
          final bosTokenPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_bos_token(runtime, bosTokenPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set bos token'});

        // 🟥 setTokenBanned
        case _FromFrontend.setTokenBanned:
          final arg = message.$2 as List<int>;
          final tokenBannedPtr = calloc.allocate<ffi.Int>(arg.length);
          for (var i = 0; i < arg.length; i++) {
            tokenBannedPtr[i] = arg[i];
          }
          retVal = rwkvMobile.rwkvmobile_runtime_set_token_banned(runtime, tokenBannedPtr, arg.length);
          calloc.free(tokenBannedPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set token banned'});

        // 🟥 setUserRole
        case _FromFrontend.setUserRole:
          final arg = message.$2 as String;
          final userRolePtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_user_role(runtime, userRolePtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set user role'});

        // 🟥 loadVisionEncoder
        case _FromFrontend.loadVisionEncoder:
          final arg = message.$2 as String;
          final encoderPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder(runtime, encoderPathPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to load vision encoder'});

        // 🟥 releaseVisionEncoder
        case _FromFrontend.releaseVisionEncoder:
          retVal = rwkvMobile.rwkvmobile_runtime_release_vision_encoder(runtime);
          if (retVal != 0) sendPort.send({'error': 'Failed to release vision encoder'});

        // 🟥 setVisionPrompt
        case _FromFrontend.setVisionPrompt:
          final arg = message.$2 as String;
          final imagePathPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_image_prompt(runtime, imagePathPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set image prompt'});

        // 🟥 loadWhisperEncoder
        case _FromFrontend.loadWhisperEncoder:
          final arg = message.$2 as String;
          final encoderPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_whisper_encoder(runtime, encoderPathPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to load whisper encoder'});

        // 🟥 releaseWhisperEncoder
        case _FromFrontend.releaseWhisperEncoder:
          retVal = rwkvMobile.rwkvmobile_runtime_release_whisper_encoder(runtime);
          if (retVal != 0) sendPort.send({'error': 'Failed to release whisper encoder'});

        // 🟥 setAudioPrompt
        case _FromFrontend.setAudioPrompt:
          final arg = message.$2 as String;
          final audioPathPtr = arg.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_audio_prompt(runtime, audioPathPtr);
          if (retVal != 0) sendPort.send({'error': 'Failed to set audio prompt'});

        // 🟥 message
        case _FromFrontend.message:
          final messages = message.$2 as List<String>;
          for (var i = 0; i < messages.length; i++) {
            inputsPtr[i] = messages[i].toNativeUtf8().cast<ffi.Char>();
          }
          final numInputs = messages.length;

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
            sendPort.send({'error': 'LLM is already generating'});
          } else {
            sendPort.send({'generateStart': true});
            if (kDebugMode) print("💬 Starting LLM generation thread (chat mode)");
            retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history(runtime, inputsPtr, numInputs, maxLength, ffi.nullptr, enableReasoning);
            if (kDebugMode) print("💬 Started LLM generation thread (chat mode)");
            if (retVal != 0) sendPort.send({'generateStop': true, 'error': 'Failed to start generation thread: retVal: $retVal'});
          }

        // 🟥 generate
        case _FromFrontend.generate:
          final prompt = message.$2 as String;
          final promptPtr = prompt.toNativeUtf8().cast<ffi.Char>();

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
            sendPort.send({'error': 'LLM is already generating'});
          } else {
            sendPort.send({'generateStart': true});
            if (kDebugMode) print("🔥 Starting LLM generation thread (gen mode), maxlength = $maxLength");
            retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(runtime, promptPtr, maxLength, generationStopToken, ffi.nullptr);
            if (kDebugMode) print("🔥 Started LLM generation thread (gen mode)");
            if (retVal != 0) sendPort.send({'generateStop': true, 'error': 'Failed to start generation'});
          }

        // 🟥 generateBlocking
        case _FromFrontend.generateBlocking:
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
          if (retVal != 0) sendPort.send({'generateStop': true, 'error': 'Failed to start generation'});

          sendPort.send({'response': responseStr});
          sendPort.send({'generateStop': true});

        // 🟥 releaseModel
        case _FromFrontend.releaseModel:
          if (kDebugMode) print("💬 Releasing model");
          rwkvMobile.rwkvmobile_runtime_release(runtime);
          runtime = ffi.nullptr;

        // 🟥 initRuntime
        case _FromFrontend.initRuntime:
          final args = message.$2 as Map<String, dynamic>;
          modelPath = args['modelPath'] as String;
          modelBackend = args['backend'].asArgument;
          tokenizerPath = args['tokenizerPath'] as String;
          if (runtime.address != 0) rwkvMobile.rwkvmobile_runtime_release(runtime);

          if (modelBackend == 'qnn') {
            // TODO: better solution for this
            final tempDir = await getTemporaryDirectory();
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

        // 🟥 stop
        case _FromFrontend.stop:
          bool generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1;
          while (generating) {
            rwkvMobile.rwkvmobile_runtime_stop_generation(runtime);
            if (kDebugMode) print("💬 Waiting for generation to stop...");
            await Future.delayed(const Duration(milliseconds: 5));
            generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1;
            if (!generating) sendPort.send({'generateStop': true});
          }

        // 🟥 getResponseBufferContent
        case _FromFrontend.getResponseBufferContent:
          final responseBufferContent = rwkvMobile.rwkvmobile_runtime_get_response_buffer_content(runtime);
          int length = responseBufferContent.length;
          // TODO: @molly 有没有可能有一个回调函数, 每次只返回一个字符?
          final Uint8List byteList = responseBufferContent.content.cast<ffi.Uint8>().asTypedList(length);
          final String str = _codec.decode(byteList);
          sendPort.send({'responseBufferContent': str});

        // 🟥 getPrefillAndDecodeSpeed
        case _FromFrontend.getPrefillAndDecodeSpeed:
          final prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime);
          final decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime);
          sendPort.send({'prefillSpeed': prefillSpeed, 'decodeSpeed': decodeSpeed});

        // 🟥 getResponseBufferIds
        case _FromFrontend.getResponseBufferIds:
          final responseBufferIds = rwkvMobile.rwkvmobile_runtime_get_response_buffer_ids(runtime);
          final responseBufferIdsList = responseBufferIds.ids.asTypedList(responseBufferIds.len).toList();
          rwkvMobile.rwkvmobile_runtime_free_token_ids(responseBufferIds);
          sendPort.send({'responseBufferIds': responseBufferIdsList});

        // 🟥 loadTTSModels
        case _FromFrontend.loadTTSModels:
          final args = message.$2 as Map<String, dynamic>;
          final campPlusPath = args['campPlusPath'] as String;
          final flowDecoderEstimatorPath = args['flowDecoderEstimatorPath'] as String;
          final flowEncoderPath = args['flowEncoderPath'] as String;
          final hiftGeneratorPath = args['hiftGeneratorPath'] as String;
          final speechTokenizerPath = args['speechTokenizerPath'] as String;
          final ttsTokenizerPath = args['ttsTokenizerPath'] as String;
          retVal = rwkvMobile.rwkvmobile_runtime_cosyvoice_load_models(runtime, speechTokenizerPath.toNativeUtf8().cast<ffi.Char>(), campPlusPath.toNativeUtf8().cast<ffi.Char>(), flowEncoderPath.toNativeUtf8().cast<ffi.Char>(), flowDecoderEstimatorPath.toNativeUtf8().cast<ffi.Char>(), hiftGeneratorPath.toNativeUtf8().cast<ffi.Char>(), ttsTokenizerPath.toNativeUtf8().cast<ffi.Char>());
          if (retVal != 0) sendPort.send({'error': 'Failed to load TTS models'});
          rwkvMobile.rwkvmobile_runtime_cosyvoice_set_cfm_steps(runtime, 5);

        // 🟥 releaseTTSModels
        case _FromFrontend.releaseTTSModels:
          retVal = rwkvMobile.rwkvmobile_runtime_cosyvoice_release_models(runtime);
          if (retVal != 0) sendPort.send({'error': 'Failed to release TTS models'});

        // 🟥 runTTS
        case _FromFrontend.runTTS:
          final args = message.$2 as Map<String, dynamic>;
          final ttsText = args['ttsText'] as String;
          final instructionText = args['instructionText'] as String;
          final promptSpeechText = args['promptSpeechText'] as String;
          final promptWavPath = args['promptWavPath'] as String;
          final outputWavPath = args['outputWavPath'] as String;
          retVal = rwkvMobile.rwkvmobile_runtime_run_tts(
            runtime,
            ttsText.toNativeUtf8().cast<ffi.Char>(),
            instructionText.toNativeUtf8().cast<ffi.Char>(),
            promptSpeechText.toNativeUtf8().cast<ffi.Char>(),
            promptWavPath.toNativeUtf8().cast<ffi.Char>(),
            outputWavPath.toNativeUtf8().cast<ffi.Char>(),
          );
          if (retVal != 0) {
            sendPort.send({'error': 'Failed to run TTS'});
          } else {
            sendPort.send({'ttsDone': true, 'outputWavPath': outputWavPath});
          }

        // 🟥 setTTSCFMSteps
        case _FromFrontend.setTTSCFMSteps:
          final args = message.$2 as Map<String, dynamic>;
          final cfmSteps = args['cfmSteps'] as int;
          retVal = rwkvMobile.rwkvmobile_runtime_cosyvoice_set_cfm_steps(runtime, cfmSteps);
          if (retVal != 0) sendPort.send({'error': 'Failed to set TTS CFM steps'});

        // 🟥 dumpLog
        case _FromFrontend.dumpLog:
          final log = rwkvMobile.rwkvmobile_dump_log();
          sendPort.send({'runtimeLog': log.cast<Utf8>().toDartString()});
      }
    }
  }

  // TODO: Use them in the future
  // void _setMaxLength([dynamic args]) {}
  // void _clearStates([dynamic args]) {}
  // void _setGenerationStopToken([dynamic args]) {}
  // void _setPrompt([dynamic args]) {}
  // void _getPrompt([dynamic args]) {}
  // void _setSamplerParams([dynamic args]) {}
  // void _getSamplerParams([dynamic args]) {}
  // void _setEnableReasoning([dynamic args]) {}
  // void _getEnableReasoning([dynamic args]) {}
  // void _getIsGenerating([dynamic args]) {}
  // void _setThinkingToken([dynamic args]) {}
  // void _setEosToken([dynamic args]) {}
  // void _setBosToken([dynamic args]) {}
  // void _setTokenBanned([dynamic args]) {}
  // void _setUserRole([dynamic args]) {}
  // void _loadVisionEncoder([dynamic args]) {}
  // void _releaseVisionEncoder([dynamic args]) {}
  // void _setVisionPrompt([dynamic args]) {}
  // void _loadWhisperEncoder([dynamic args]) {}
  // void _releaseWhisperEncoder([dynamic args]) {}
  // void _setAudioPrompt([dynamic args]) {}
  // void _message([dynamic args]) {}
  // void _generate([dynamic args]) {}
  // void _generateBlocking([dynamic args]) {}
  // void _releaseModel([dynamic args]) {}
  // void _initRuntime([dynamic args]) {}
  // void _stop([dynamic args]) {}
  // void _getResponseBufferContent([dynamic args]) {}
  // void _getPrefillAndDecodeSpeed([dynamic args]) {}
  // void _getResponseBufferIds([dynamic args]) {}
  // void _loadTTSModels([dynamic args]) {}
  // void _releaseTTSModels([dynamic args]) {}
  // void _getTTSSpkNames([dynamic args]) {}
  // void _runTTS([dynamic args]) {}
  // void _runTTSWithPredefinedSpk([dynamic args]) {}
  // void _setTTSCFMSteps([dynamic args]) {}
  // void _dumpLog([dynamic args]) {}
}
