// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// TODO: 由前端提供各个路径 @WangCe @Molly
import 'package:path_provider/path_provider.dart';
import 'package:rwkv_mobile_flutter/from_rwkv.dart';
import 'package:rwkv_mobile_flutter/to_rwkv.dart';
import 'package:rwkv_mobile_flutter/types.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

typedef _FromFrontend = ToRWKV;

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
    if (Platform.isWindows) {
      final abi = ffi.Abi.current();
      if (abi == ffi.Abi.windowsX64) return ffi.DynamicLibrary.open('rwkv_mobile.dll');
      if (abi == ffi.Abi.windowsArm64) return ffi.DynamicLibrary.open('rwkv_mobile-arm64.dll');
      throw Exception('😡 Unsupported ABI: ${abi.toString()}');
    }
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
    ffi.Pointer<ffi.Char> responseBuffer = malloc.allocate<ffi.Char>(backendNamesLength);
    rwkvMobile.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  static String getPlatformName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final platformName = rwkvMobile.rwkvmobile_get_platform_name();
    return platformName.cast<Utf8>().toDartString();
  }

  static String getSocName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final socName = rwkvMobile.rwkvmobile_get_soc_name();
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

    if (kDebugMode) {
      const logLevel = int.fromEnvironment('logLevel', defaultValue: RWKV_LOG_LEVEL_DEBUG);
      rwkvMobile.rwkvmobile_set_loglevel(logLevel);
    }

    // definitions
    int maxLength = 2000;
    int maxMessages = 1000;
    int generationStopToken = 0; // Takes effect in 'generation' mode; not used in 'chat' mode
    int retVal = 0;
    int maxBatchSize = 20;

    ffi.Pointer<ffi.Pointer<ffi.Char>> inputsPtr = malloc.allocate<ffi.Pointer<ffi.Char>>(
      maxMessages * ffi.sizeOf<ffi.Pointer<ffi.Char>>(),
    );
    ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Char>>> inputsBatchPtr = malloc.allocate<ffi.Pointer<ffi.Pointer<ffi.Char>>>(
      maxBatchSize * ffi.sizeOf<ffi.Pointer<ffi.Pointer<ffi.Char>>>(),
    );
    ffi.Pointer<ffi.Int> numInputsBatchPtr = malloc.allocate<ffi.Int>(maxBatchSize * ffi.sizeOf<ffi.Int>());
    for (var i = 0; i < maxBatchSize; i++) {
      inputsBatchPtr[i] = malloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages * ffi.sizeOf<ffi.Pointer<ffi.Char>>());
    }
    ffi.Pointer<ffi.Pointer<ffi.Char>> inputsBatchPtrCompletionAsync = malloc.allocate<ffi.Pointer<ffi.Char>>(
      maxBatchSize * ffi.sizeOf<ffi.Pointer<ffi.Char>>(),
    );
    List<int> ttsStreamingBufferList = [];
    List<double> ttsStreamingBufferListDouble = [];

    var modelPath = options.modelPath;
    final backend = options.backend;
    var modelBackendString = backend.asArgument;
    var tokenizerPath = options.tokenizerPath;

    rwkvmobile_runtime_t runtime = rwkvMobile.rwkvmobile_runtime_init();

    if (runtime.address == 0) throw Exception('😡 Failed to initialize runtime');

    int model_id = 0;

    // @HaloWang 目前load_model实际上已经和runtime_init解耦了，这一部分的load_model其实可以去掉（靠_FromFrontend.ReInitRuntime来加载模型）
    switch (backend) {
      case Backend.qnn:
        // TODO: better solution for this
        final tempDir = await getTemporaryDirectory();

        rwkvMobile.rwkvmobile_runtime_set_qnn_library_path(runtime, (tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());
        model_id = rwkvMobile.rwkvmobile_runtime_load_model_with_extra(
          runtime,
          modelPath.toNativeUtf8().cast<ffi.Char>(),
          modelBackendString.toNativeUtf8().cast<ffi.Char>(),
          tokenizerPath.toNativeUtf8().cast<ffi.Char>(),
          (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>(),
        );
      case Backend.ncnn:
      case Backend.llamacpp:
      case Backend.webRwkv:
      case Backend.mnn:
      case Backend.coreml:
      case Backend.mlx:
        model_id = rwkvMobile.rwkvmobile_runtime_load_model(
          runtime,
          modelPath.toNativeUtf8().cast<ffi.Char>(),
          modelBackendString.toNativeUtf8().cast<ffi.Char>(),
          tokenizerPath.toNativeUtf8().cast<ffi.Char>(),
        );
    }

    if (model_id < 0) {
      throw Exception('😡 Failed to load model, model path: $modelPath, model backend: $backend, tokenizer path: $tokenizerPath');
    }

    final tempDir = await getTemporaryDirectory();
    rwkvMobile.rwkvmobile_set_cache_dir(runtime, tempDir.path.toNativeUtf8().cast<ffi.Char>());

    // TODO: @WangCe 逐渐地迁移到 handler 方法中, 最好不要在该方法声明局部变量
    await for (final _FromFrontend message in receivePort) {
      switch (message) {
        // 🟥 setMaxLength
        case SetMaxLength req:
          final arg = req.maxLength;
          if (arg > 0) maxLength = arg;

        // 🟥 clearStates
        case ClearStates _:
          rwkvMobile.rwkvmobile_runtime_clear_state(runtime, model_id);

        // 🟥 unloadInitialStates
        case UnloadInitialStates req:
          rwkvMobile.rwkvmobile_runtime_unload_initial_state(runtime, model_id, req.statePath.toNativeUtf8().cast<ffi.Char>());

        // 🟥 loadInitialStates
        case LoadInitialStates req:
          final statePathPtr = req.statePath.toNativeUtf8().cast<ffi.Char>();
          rwkvMobile.rwkvmobile_runtime_load_initial_state(runtime, model_id, statePathPtr);

        // 🟥 setGenerationStopToken
        case SetGenerationStopToken req:
          final arg = req.stopToken;
          if (arg >= 0) generationStopToken = arg;

        // 🟥 setPrompt
        case SetPrompt req:
          final promptPtr = req.prompt.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_prompt(runtime, model_id, promptPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set prompt: return value: $retVal', req));

        // 🟥 getPrompt
        case GetPrompt req:
          final stringBuffer = malloc.allocate<ffi.Char>(maxLength);
          rwkvMobile.rwkvmobile_runtime_get_prompt(runtime, model_id, stringBuffer, maxLength);
          final prompt = stringBuffer.cast<Utf8>().toDartString();
          sendPort.send(CurrentPrompt(prompt: prompt, toRWKV: req));
          malloc.free(stringBuffer);

        // 🟥 setSamplerParams
        case SetSamplerParams req:
          final samplerParams = ffi.Struct.create<sampler_params>();
          final penaltyParams = ffi.Struct.create<penalty_params>();
          samplerParams.temperature = req.temperature.toDouble();
          samplerParams.top_k = req.topK.toInt();
          samplerParams.top_p = req.topP.toDouble();
          penaltyParams.presence_penalty = req.presencePenalty.toDouble();
          penaltyParams.frequency_penalty = req.frequencyPenalty.toDouble();
          penaltyParams.penalty_decay = req.penaltyDecay.toDouble();
          rwkvMobile.rwkvmobile_runtime_set_sampler_params(runtime, model_id, samplerParams);
          rwkvMobile.rwkvmobile_runtime_set_penalty_params(runtime, model_id, penaltyParams);

        // 🟥 getSamplerParams
        case GetSamplerParams req:
          final samplerParams = rwkvMobile.rwkvmobile_runtime_get_sampler_params(runtime, model_id);
          final penaltyParams = rwkvMobile.rwkvmobile_runtime_get_penalty_params(runtime, model_id);
          sendPort.send(
            SamplerParams(
              temperature: samplerParams.temperature,
              topK: samplerParams.top_k,
              topP: samplerParams.top_p,
              presencePenalty: penaltyParams.presence_penalty,
              frequencyPenalty: penaltyParams.frequency_penalty,
              penaltyDecay: penaltyParams.penalty_decay,
              toRWKV: req,
            ),
          );

        // 🟥 setSeed
        case SetSeed req:
          final seed = req.seed;
          retVal = rwkvMobile.rwkvmobile_runtime_set_seed(runtime, req.modelID ?? model_id, seed);
          if (retVal != 0) sendPort.send(Error('Failed to set seed: retVal: $retVal', req, retVal));

        // 🟥 getSeed
        case GetSeed req:
          final seed = rwkvMobile.rwkvmobile_runtime_get_seed(runtime, req.modelID ?? model_id);
          sendPort.send(CurrentSeed(seed: seed, modelID: req.modelID ?? model_id, toRWKV: req));

        // 🟥 getIsGenerating
        case GetIsGenerating req:
          final modelID = req.modelID ?? model_id;
          bool isGeneratingBool = (rwkvMobile.rwkvmobile_runtime_is_generating(runtime, modelID) != 0);
          sendPort.send(IsGenerating(isGenerating: isGeneratingBool, modelID: modelID, toRWKV: req));
          sendPort.send({'isGenerating': isGeneratingBool});

        // 🟥 setThinkingToken
        case SetThinkingToken req:
          final thinkingTokenPtr = req.thinkingToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_thinking_token(runtime, model_id, thinkingTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set thinking token', req));

        // 🟥 setEosToken
        case SetEosToken req:
          final eosTokenPtr = req.eosToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_eos_token(runtime, model_id, eosTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set eos token', req));

        // 🟥 setBosToken
        case SetBosToken req:
          final bosTokenPtr = req.bosToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_bos_token(runtime, model_id, bosTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set bos token', req));

        // 🟥 setTokenBanned
        case SetTokenBanned req:
          ffi.Pointer<ffi.Int> tokenBannedPtr = malloc.allocate<ffi.Int>(req.tokenBanned.length * ffi.sizeOf<ffi.Int>());
          for (var i = 0; i < req.tokenBanned.length; i++) {
            tokenBannedPtr[i] = req.tokenBanned[i];
          }
          retVal = rwkvMobile.rwkvmobile_runtime_set_token_banned(runtime, model_id, tokenBannedPtr, req.tokenBanned.length);
          malloc.free(tokenBannedPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set token banned: retVal: $retVal', req, retVal));

        // 🟥 setUserRole
        case SetUserRole req:
          final userRolePtr = req.userRole.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_user_role(runtime, model_id, userRolePtr);
          if (retVal != 0) sendPort.send(Error('Failed to set user role: retVal: $retVal', req, retVal));

        // 🟥 setResponseRole
        case SetResponseRole req:
          final responseRolePtr = req.responseRole.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_response_role(runtime, model_id, responseRolePtr);
          if (retVal != 0) sendPort.send(Error('Failed to set response role: retVal: $retVal', req, retVal));

        // 🟥 setSpaceAfterRoles
        case SetSpaceAfterRoles req:
          retVal = rwkvMobile.rwkvmobile_runtime_set_space_after_roles(runtime, model_id, req.spaceAfterRoles ? 1 : 0);
          if (retVal != 0) sendPort.send(Error('Failed to set space after roles: retVal: $retVal', req, retVal));

        case SetImageUniqueIdentifier req:
          final uniqueIdentifierPtr = req.uniqueIdentifier.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_image_unique_identifier(runtime, uniqueIdentifierPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set image unique identifier: retVal: $retVal', req, retVal));

        // 🟥 loadVisionEncoder
        case LoadVisionEncoder req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder(runtime, model_id, encoderPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load vision encoder: retVal: $retVal', req, retVal));

        // 🟥 loadVisionEncoderAndAdapter
        case LoadVisionEncoderAndAdapter req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          final adapterPathPtr = req.adapterPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder_and_adapter(runtime, model_id, encoderPathPtr, adapterPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load vision encoder and adapter: retVal: $retVal', req, retVal));

        // 🟥 releaseVisionEncoder
        case ReleaseVisionEncoder req:
          retVal = rwkvMobile.rwkvmobile_runtime_release_vision_encoder(runtime, model_id);
          if (retVal != 0) sendPort.send(Error('Failed to release vision encoder', req, retVal));

        // 🟥 setVisionPrompt
        case SetVisionPrompt req:
          // final imagePathPtr = req.imagePathPtr.toNativeUtf8().cast<ffi.Char>();
          // retVal = rwkvMobile.rwkvmobile_runtime_set_image_prompt(runtime, model_id, imagePathPtr);
          sendPort.send(Error('Failed to set image prompt', req, retVal));

        // 🟥 loadWhisperEncoder
        case LoadWhisperEncoder req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_whisper_encoder(runtime, model_id, encoderPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load whisper encoder', req, retVal));

        // 🟥 releaseWhisperEncoder
        case ReleaseWhisperEncoder req:
          retVal = rwkvMobile.rwkvmobile_runtime_release_whisper_encoder(runtime, model_id);
          if (retVal != 0) sendPort.send(Error('Failed to release whisper encoder', req, retVal));

        // 🟥 setAudioPrompt
        case SetAudioPrompt req:
          final audioPathPtr = req.audioPathPtr.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_audio_prompt(runtime, model_id, audioPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set audio prompt', req, retVal));

        // 🟥 message
        case ChatAsync req:
          for (var i = 0; i < req.messages.length; i++) {
            inputsPtr[i] = req.messages[i].toNativeUtf8().cast<ffi.Char>();
          }
          final numInputs = req.messages.length;

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) != 0) {
            sendPort.send(Error('LLM is already generating', req, retVal));
            break;
          }

          sendPort.send(GenerateStart(toRWKV: req));
          retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history_async(
            runtime,
            model_id,
            inputsPtr,
            numInputs,
            maxLength,
            ffi.nullptr,
            req.reasoning ? 1 : 0,
          );
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation thread: retVal: $retVal', toRWKV: req));

        case ChatBatchAsync req:
          final batchSize = req.batchSize;

          if (batchSize != req.messages.length) {
            sendPort.send(Error('Batch size does not match messages length', req, -1));
            break;
          }

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) != 0) {
            sendPort.send(Error('LLM is already generating', req, retVal));
            break;
          }

          for (var i = 0; i < batchSize; i++) {
            if (inputsBatchPtr[i] == ffi.nullptr) {
              inputsBatchPtr[i] = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);
            }
            for (var j = 0; j < req.messages[i].length; j++) {
              final raw = req.messages[i][j];
              print(raw);
              inputsBatchPtr[i][j] = raw.toNativeUtf8().cast<ffi.Char>();
            }
            numInputsBatchPtr[i] = req.messages[i].length;
          }

          sendPort.send(GenerateStart(toRWKV: req));
          retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_batch_with_history_async(
            runtime,
            model_id,
            inputsBatchPtr,
            numInputsBatchPtr,
            batchSize,
            maxLength,
            ffi.nullptr,
            req.reasoning ? 1 : 0,
          );
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation thread: retVal: $retVal', toRWKV: req));

        // 🟥 getSupportedBatchSizes
        case GetSupportedBatchSizes req:
          final supportedBatchSizes = rwkvMobile.rwkvmobile_runtime_get_supported_batch_sizes(runtime, model_id);
          final List<int> batchSizes = [];
          for (var i = 0; i < supportedBatchSizes.length; i++) {
            if (supportedBatchSizes.sizes[i] > 1) {
              // we don't actually need to use batch size 1, so we skip it
              batchSizes.add(supportedBatchSizes.sizes[i]);
            }
          }
          sendPort.send(SupportedBatchSizes(supportedBatchSizes: batchSizes, toRWKV: req));

        // 🟥 generateAsync
        case GenerateAsync req:
          final promptPtr = req.prompt.toNativeUtf8().cast<ffi.Char>();

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) != 0) {
            sendPort.send(Error('LLM is already generating', req));
            break;
          }

          sendPort.send(GenerateStart(toRWKV: req));
          if (req.batch <= 1) {
            retVal = rwkvMobile.rwkvmobile_runtime_gen_completion_async(
              runtime,
              model_id,
              promptPtr,
              maxLength,
              generationStopToken,
              ffi.nullptr,
            );
          } else {
            for (var i = 0; i < req.batch; i++) {
              inputsBatchPtrCompletionAsync[i] = promptPtr;
            }
            retVal = rwkvMobile.rwkvmobile_runtime_gen_completion_batch_async(
              runtime,
              model_id,
              inputsBatchPtrCompletionAsync,
              req.batch,
              maxLength,
              generationStopToken,
              ffi.nullptr,
            );
          }
          if (retVal != 0) {
            sendPort.send(GenerateStop(error: 'Failed to start generation: retVal: $retVal', toRWKV: req));
          }

        // 🟥 runEvaluation
        case RunEvaluation req:
          final sourceTextPtr = req.sourceText.toNativeUtf8().cast<ffi.Char>();
          final targetTextPtr = req.targetText.toNativeUtf8().cast<ffi.Char>();
          final evaluationResults = rwkvMobile.rwkvmobile_runtime_run_evaluation(runtime, model_id, sourceTextPtr, targetTextPtr);
          final List<double> logits = evaluationResults.logits_vals.asTypedList(evaluationResults.count).toList();
          final List<bool> corrects = evaluationResults.corrects
              .cast<ffi.Int32>()
              .asTypedList(evaluationResults.count)
              .toList()
              .map((e) => e != 0)
              .toList();
          sendPort.send(EvaluationResults(logits: logits, corrects: corrects, toRWKV: req));
          rwkvMobile.rwkvmobile_runtime_free_evaluation_results(evaluationResults);

        // 🟥 generate
        case SudokuOthelloGenerate req:
          final promptPtr = req.prompt.toNativeUtf8().cast<ffi.Char>();
          String responseStr = req.prompt;
          final randon = Random();
          final wantRawJSON = req.wantRawJSON;
          final decodeStream = req.decodeStream;

          callbackFunction(ffi.Pointer<ffi.Char> cppStream, int idx, ffi.Pointer<ffi.Char> cppNewText) {
            // final start = DateTime.now().microsecondsSinceEpoch;
            final showQuerySpeed = (randon.nextDouble() * 100) <= 3;
            final prefillSpeed = showQuerySpeed ? rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime, model_id) : -1.0;
            final decodeSpeed = showQuerySpeed ? rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime, model_id) : -1.0;

            final newText = cppNewText.cast<Utf8>().toDartString();

            late final String stream;

            if (decodeStream) {
              stream = cppStream.cast<Utf8>().toDartString();
              responseStr = stream;
            } else {
              stream = '';
            }

            // TODO: @wangce 移除该调用
            if (wantRawJSON) {
              sendPort.send({
                'streamResponse': stream,
                'streamResponseToken': idx,
                'streamResponseNewText': newText,
                'prefillSpeed': prefillSpeed,
                'decodeSpeed': decodeSpeed,
              });
            }

            sendPort.send(
              StreamResponse(
                streamResponse: stream,
                streamResponseToken: idx,
                streamResponseNewText: newText,
                prefillSpeed: prefillSpeed,
                decodeSpeed: decodeSpeed,
                toRWKV: req,
              ),
            );
          }

          final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>)>.isolateLocal(
            callbackFunction,
          );
          sendPort.send(GenerateStart(toRWKV: req));
          retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(
            runtime,
            model_id,
            promptPtr,
            maxLength,
            generationStopToken,
            nativeCallable.nativeFunction,
          );
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation: retVal: $retVal', toRWKV: req));

          sendPort.send({'sudokuOthelloResponse': responseStr});
          if (retVal == 0) sendPort.send(GenerateStop(toRWKV: req));

        // 🟥 releaseModel
        case ReleaseModel req:
          rwkvMobile.rwkvmobile_runtime_release_model(runtime, req.modelID ?? model_id);

        case AddTTSModel req:
          final modelPath = req.modelPath;
          final backend = req.backend;
          final tokenizerPath = req.tokenizerPath;
          final modelID = rwkvMobile.rwkvmobile_runtime_load_model(
            runtime,
            modelPath.toNativeUtf8().cast<ffi.Char>(),
            backend.asArgument.toNativeUtf8().cast<ffi.Char>(),
            tokenizerPath.toNativeUtf8().cast<ffi.Char>(),
          );
          if (modelID < 0) {
            sendPort.send(Error('Failed to add TTS model', req));
            break;
          }
          final wav2vec2Path = req.wav2vec2Path;
          final bicodecTokenizerPath = req.bicodecTokenizerPath;
          final bicodecDetokenizerPath = req.bicodecDetokenizerPath;
          retVal = rwkvMobile.rwkvmobile_runtime_sparktts_load_models(
            runtime,
            wav2vec2Path.toNativeUtf8().cast<ffi.Char>(),
            bicodecTokenizerPath.toNativeUtf8().cast<ffi.Char>(),
            bicodecDetokenizerPath.toNativeUtf8().cast<ffi.Char>(),
          );
          if (retVal != 0) sendPort.send(Error('Failed to add TTS model', req));
          if (retVal != 0) break;
          sendPort.send(LoadSteps(done: true, modelID: modelID, toRWKV: req));

        // 🟥 initRuntime
        case ReInitRuntime req:
          String modelPath = req.modelPath;
          final modelBackendString = req.backend.asArgument;
          final backend = req.backend;
          final tokenizerPath = req.tokenizerPath;

          // TODO: @HaloWang rename ReInitRuntime to LoadModel, and move this relaseModel logic out
          rwkvMobile.rwkvmobile_runtime_release_model(runtime, model_id);

          switch (backend) {
            case Backend.ncnn:
            case Backend.llamacpp:
            case Backend.webRwkv:
            case Backend.mnn:
            case Backend.coreml:
            case Backend.mlx:
              sendPort.send(ReInitSteps(done: false, step: 'load model', toRWKV: req));
              model_id = rwkvMobile.rwkvmobile_runtime_load_model(
                runtime,
                modelPath.toNativeUtf8().cast<ffi.Char>(),
                modelBackendString.toNativeUtf8().cast<ffi.Char>(),
                tokenizerPath.toNativeUtf8().cast<ffi.Char>(),
              );
            case Backend.qnn:
              // TODO: better solution for this
              final tempDir = await getTemporaryDirectory();
              sendPort.send(ReInitSteps(done: false, step: 'set qnn library path', toRWKV: req));
              rwkvMobile.rwkvmobile_runtime_set_qnn_library_path(runtime, (tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());

              sendPort.send(ReInitSteps(done: false, step: 'load model with extra', toRWKV: req));
              model_id = rwkvMobile.rwkvmobile_runtime_load_model_with_extra(
                runtime,
                modelPath.toNativeUtf8().cast<ffi.Char>(),
                modelBackendString.toNativeUtf8().cast<ffi.Char>(),
                tokenizerPath.toNativeUtf8().cast<ffi.Char>(),
                (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>(),
              );
          }

          if (model_id < 0) {
            sendPort.send(
              ReInitSteps(
                done: false,
                error: 'Failed to load model: model_path: $modelPath, model_backend: $modelBackendString, tokenizer_path: $tokenizerPath',
                toRWKV: req,
                success: false,
              ),
            );
            break;
          }

          sendPort.send(ReInitSteps(done: true, success: true, toRWKV: req));

        // 🟥 stop
        case Stop req:
          bool generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) == 1;
          while (generating) {
            rwkvMobile.rwkvmobile_runtime_stop_generation(runtime, model_id);
            await Future.delayed(const Duration(milliseconds: 5));
            generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) == 1;
            if (!generating) sendPort.send(GenerateStop(toRWKV: req));
          }

        // 🟥 getResponseBufferContent
        case GetResponseBufferContent req:
          final responseBufferContent = rwkvMobile.rwkvmobile_runtime_get_response_buffer_content(runtime, model_id);
          int length = responseBufferContent.length;
          final Uint8List byteList = responseBufferContent.content.cast<ffi.Uint8>().asTypedList(length);
          final String str = _codec.decode(byteList);
          final eosFound = responseBufferContent.eos_found == 1;
          sendPort.send(ResponseBufferContent(responseBufferContent: str, eosFound: eosFound, toRWKV: req));

        // 🟥 getBatchResponseBufferContent
        case GetBatchResponseBufferContent req:
          final responseBufferContent = rwkvMobile.rwkvmobile_runtime_get_response_buffer_content_batch(runtime, model_id);
          int batchSize = responseBufferContent.batch_size;
          List<String> responseBufferContentList = [];
          List<bool> eosFoundList = [];

          for (int i = 0; i < batchSize; i++) {
            int length = responseBufferContent.lengths[i];
            final Uint8List byteList = responseBufferContent.contents[i].cast<ffi.Uint8>().asTypedList(length);
            final String str = _codec.decode(byteList);
            final eosFound = responseBufferContent.eos_founds[i] == 1;
            responseBufferContentList.add(str);
            eosFoundList.add(eosFound);
          }
          rwkvMobile.rwkvmobile_runtime_free_response_buffer_batch(responseBufferContent);
          sendPort.send(
            ResponseBatchBufferContent(
              responseBufferContent: responseBufferContentList,
              eosFound: eosFoundList,
              batchSize: batchSize,
              toRWKV: req,
            ),
          );

        // 🟥 getPrefillAndDecodeSpeed
        case GetPrefillAndDecodeSpeed req:
          final modelID = req.modelID ?? model_id;
          final prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime, modelID);
          final decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime, modelID);
          final progress = rwkvMobile.rwkvmobile_runtime_get_prefill_progress(runtime, modelID);
          sendPort.send(Speed(prefillSpeed: prefillSpeed, decodeSpeed: decodeSpeed, prefillProgress: progress, toRWKV: req));

        // 🟥 getResponseBufferIds
        case GetResponseBufferIds _:
          final responseBufferIds = rwkvMobile.rwkvmobile_runtime_get_response_buffer_ids(runtime, model_id);
          final responseBufferIdsList = responseBufferIds.ids.asTypedList(responseBufferIds.len).toList();
          rwkvMobile.rwkvmobile_runtime_free_token_ids(responseBufferIds);
          sendPort.send({'responseBufferIds': responseBufferIdsList});

        // 🟥 getLoadedModelIDs
        case GetLoadedModelIDs req:
          final modelIDs = malloc.allocate<ffi.Int32>(16 * ffi.sizeOf<ffi.Int32>());
          final loadedModelIDsList = rwkvMobile.rwkvmobile_runtime_get_loaded_model_ids(runtime, modelIDs.cast<ffi.Int>(), 16);
          final loadedModelIDsListList = modelIDs.asTypedList(loadedModelIDsList).toList();
          malloc.free(modelIDs);
          sendPort.send(LoadedModelIDs(loadedModelIDs: loadedModelIDsListList, toRWKV: req));

        // 🟥 getLoadedModelPathByID
        case GetLoadedModelPathByID req:
          final modelID = req.modelID;
          final loadedModelPath = rwkvMobile.rwkvmobile_runtime_get_model_path_by_id(runtime, modelID);
          final loadedModelPathString = loadedModelPath.cast<Utf8>().toDartString();
          sendPort.send(LoadedModelPathByID(loadedModelPath: loadedModelPathString, modelID: modelID, toRWKV: req));

        case LoadSparkTTSModels req:
          final wav2vec2Path = req.wav2vec2Path;
          final bicodecTokenizerPath = req.bicodecTokenizerPath;
          final bicodecDetokenizerPath = req.bicodecDetokenizerPath;

          retVal = rwkvMobile.rwkvmobile_runtime_sparktts_load_models(
            runtime,
            wav2vec2Path.toNativeUtf8().cast<ffi.Char>(),
            bicodecTokenizerPath.toNativeUtf8().cast<ffi.Char>(),
            bicodecDetokenizerPath.toNativeUtf8().cast<ffi.Char>(),
          );
          if (retVal != 0) sendPort.send(Error('Failed to load Spark TTS models', req));

        // 🟥 loadTTSTextNormalizer
        case LoadTTSTextNormalizer req:
          final fstPath = req.fstPath;
          retVal = rwkvMobile.rwkvmobile_runtime_tts_register_text_normalizer(runtime, fstPath.toNativeUtf8().cast<ffi.Char>());
          if (retVal != 0) sendPort.send(Error('Failed to load TTS Text Normalizer file $fstPath', req));

        // 🟥 releaseTTSModels
        case ReleaseTTSModels req:
          retVal = rwkvMobile.rwkvmobile_runtime_sparktts_release_models(runtime);
          if (retVal != 0) sendPort.send(Error('Failed to release TTS models', req));

        // 🟥 runTTSAsync
        case StartTTS req:
          final ttsText = req.ttsText;
          final promptSpeechText = req.promptSpeechText;
          final promptWavPath = req.promptWavPath;
          final outputWavPath = req.outputWavPath;
          ttsStreamingBufferList.clear();
          ttsStreamingBufferListDouble.clear();
          retVal = rwkvMobile.rwkvmobile_runtime_run_spark_tts_streaming_async(
            runtime,
            req.modelID ?? model_id,
            ttsText.toNativeUtf8().cast<ffi.Char>(),
            promptSpeechText.toNativeUtf8().cast<ffi.Char>(),
            promptWavPath.toNativeUtf8().cast<ffi.Char>(),
            outputWavPath.toNativeUtf8().cast<ffi.Char>(),
          );

          if (retVal != 0) sendPort.send(Error('Failed to run TTS', req));
          if (retVal != 0) break;

          sendPort.send(TTSGenerationStart(start: true, toRWKV: req));

        // 🟥 runTTSWithGlobalTokensAsync
        case StartTTSWithGlobalTokens req:
          final ttsText = req.ttsText;
          final outputWavPath = req.outputWavPath;
          ttsStreamingBufferList.clear();
          ttsStreamingBufferListDouble.clear();
          if (req.globalTokens.length != 32) throw Exception('😡 globalTokens length must be 32');
          ffi.Pointer<ffi.Int32> globalTokensPtr = malloc.allocate<ffi.Int32>(req.globalTokens.length * ffi.sizeOf<ffi.Int32>());
          for (int i = 0; i < req.globalTokens.length; i++) {
            globalTokensPtr[i] = req.globalTokens[i];
          }
          retVal = rwkvMobile.rwkvmobile_runtime_run_spark_tts_with_global_tokens_streaming_async(
            runtime,
            model_id,
            ttsText.toNativeUtf8().cast<ffi.Char>(),
            outputWavPath.toNativeUtf8().cast<ffi.Char>(),
            globalTokensPtr.cast<ffi.Int>(),
          );
          malloc.free(globalTokensPtr);

          if (retVal != 0) sendPort.send(Error('Failed to run TTS', req));
          if (retVal != 0) break;

          sendPort.send(TTSGenerationStart(start: true, toRWKV: req));

        // 🟥 runTTSWithPropertiesAsync
        case StartTTSWithProperties req:
          final ttsText = req.ttsText;
          final outputWavPath = req.outputWavPath;
          ttsStreamingBufferList.clear();
          ttsStreamingBufferListDouble.clear();
          retVal = rwkvMobile.rwkvmobile_runtime_run_spark_tts_with_properties_streaming_async(
            runtime,
            model_id,
            ttsText.toNativeUtf8().cast<ffi.Char>(),
            outputWavPath.toNativeUtf8().cast<ffi.Char>(),
            req.age.asArgument.toNativeUtf8().cast<ffi.Char>(),
            req.gender.asArgument.toNativeUtf8().cast<ffi.Char>(),
            req.emotion.asArgument.toNativeUtf8().cast<ffi.Char>(),
            req.speed.asArgument.toNativeUtf8().cast<ffi.Char>(),
            req.pitch.asArgument.toNativeUtf8().cast<ffi.Char>(),
          );

          if (retVal != 0) sendPort.send(Error('Failed to run TTS', req));
          if (retVal != 0) break;

          sendPort.send(TTSGenerationStart(start: true, toRWKV: req));

        // 🟥 getCurrentTTSGlobalTokens
        case GetCurrentTTSGlobalTokens _:
          final ttsGlobalTokensPtr = rwkvMobile.rwkvmobile_runtime_get_tts_global_tokens_output(runtime);
          final ttsGlobalTokensList = ttsGlobalTokensPtr.cast<ffi.Int32>().asTypedList(32).toList();
          sendPort.send({'ttsGlobalTokens': ttsGlobalTokensList});

        // 🟥 getTTSStreamingBuffer
        case GetTTSStreamingBuffer req:
          final generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime, model_id) == 1;
          final currentLength = rwkvMobile.rwkvmobile_runtime_get_tts_streaming_buffer_length(runtime);
          if (currentLength != ttsStreamingBufferList.length) {
            final ttsStreamingBuffer = rwkvMobile.rwkvmobile_runtime_get_tts_streaming_buffer(runtime);
            ttsStreamingBufferListDouble = ttsStreamingBuffer.samples.asTypedList(ttsStreamingBuffer.length).toList();
            ttsStreamingBufferList = ttsStreamingBufferListDouble.map((e) {
              return (e * 32768.0).toInt();
            }).toList();
            rwkvMobile.rwkvmobile_runtime_free_tts_streaming_buffer(ttsStreamingBuffer);
            sendPort.send(
              TTSStreamingBuffer(
                generating: generating,
                ttsStreamingBuffer: ttsStreamingBufferList,
                ttsStreamingBufferLength: ttsStreamingBufferList.length,
                rawFloatList: ttsStreamingBufferListDouble,
                toRWKV: req,
              ),
            );
          }

        // 🟥 dumpLog
        case DumpLog req:
          final log = rwkvMobile.rwkvmobile_dump_log();
          sendPort.send(RuntimeLog(runtimeLog: log.cast<Utf8>().toDartString(), toRWKV: req));

        // 🟥 dumpStateInfo
        case DumpStateInfo req:
          final stateInfo = rwkvMobile.rwkvmobile_get_state_cache_info(runtime, req.modelID ?? model_id);
          sendPort.send(StateInfo(stateInfo: stateInfo.cast<Utf8>().toDartString(), toRWKV: req));
          rwkvMobile.rwkvmobile_free_state_cache_info(stateInfo);

        // 🟥 saveRuntimeStateByHistory
        case SaveRuntimeStateByHistory req:
          for (var i = 0; i < req.messages.length; i++) {
            inputsPtr[i] = req.messages[i].toNativeUtf8().cast<ffi.Char>();
          }
          final numInputs = req.messages.length;
          final stateSavePathPtr = req.stateSavePath.toNativeUtf8().cast<ffi.Char>();
          final retVal = rwkvMobile.rwkvmobile_runtime_save_history_to_state(
            runtime,
            req.modelID ?? model_id,
            inputsPtr,
            numInputs,
            stateSavePathPtr,
          );
          if (retVal != 0) sendPort.send(Error('Failed to save runtime state by history', req, retVal));

        // 🟥 loadRuntimeStateToMemory
        case LoadRuntimeStateToMemory req:
          final stateLoadPathPtr = req.stateLoadPath.toNativeUtf8().cast<ffi.Char>();
          final retVal = rwkvMobile.rwkvmobile_runtime_load_history_state_to_memory(runtime, req.modelID ?? model_id, stateLoadPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load runtime state to memory', req, retVal));

        case SetSamplerAndPenaltyParams req:
          final samplerParams = ffi.Struct.create<sampler_params>();
          final penaltyParams = ffi.Struct.create<penalty_params>();

          for (var i = 0; i < req.temperatures.length; i++) {
            samplerParams.temperature = req.temperatures[i].toDouble();
            samplerParams.top_k = req.topKs[i].toInt();
            samplerParams.top_p = req.topPs[i].toDouble();

            penaltyParams.presence_penalty = req.presencePenalties[i].toDouble();
            penaltyParams.frequency_penalty = req.frequencyPenalties[i].toDouble();
            penaltyParams.penalty_decay = req.penaltyDecays[i].toDouble();

            rwkvMobile.rwkvmobile_runtime_set_sampler_params_on_batch_slot(runtime, model_id, i, samplerParams);
            rwkvMobile.rwkvmobile_runtime_set_penalty_params_on_batch_slot(runtime, model_id, i, penaltyParams);
          }

        case GetSamplerAndPenaltyParams req:
          final List<double> temperatures = [];
          final List<double> topKs = [];
          final List<double> topPs = [];
          final List<double> presencePenalties = [];
          final List<double> frequencyPenalties = [];
          final List<double> penaltyDecays = [];

          for (var i = 0; i < req.batchSize; i++) {
            final samplerParams = rwkvMobile.rwkvmobile_runtime_get_sampler_params_on_batch_slot(runtime, model_id, i);
            final penaltyParams = rwkvMobile.rwkvmobile_runtime_get_penalty_params_on_batch_slot(runtime, model_id, i);
            temperatures.add(samplerParams.temperature);
            topKs.add(samplerParams.top_k.toDouble());
            topPs.add(samplerParams.top_p);
            presencePenalties.add(penaltyParams.presence_penalty);
            frequencyPenalties.add(penaltyParams.frequency_penalty);
            penaltyDecays.add(penaltyParams.penalty_decay);
          }

          sendPort.send(
            SamplerAndPenaltyParams(
              temperatures: temperatures,
              topKs: topKs,
              topPs: topPs,
              presencePenalties: presencePenalties,
              frequencyPenalties: frequencyPenalties,
              penaltyDecays: penaltyDecays,
              toRWKV: req,
            ),
          );
      }
    }

    for (var i = 0; i < maxBatchSize; i++) {
      if (inputsBatchPtr[i] != ffi.nullptr) {
        malloc.free(inputsBatchPtr[i]);
      }
    }
    malloc.free(inputsPtr);
    malloc.free(inputsBatchPtr);
    malloc.free(numInputsBatchPtr);
    malloc.free(inputsBatchPtrCompletionAsync);
  }
}
