// ignore_for_file: prefer_interpolation_to_compose_strings

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
import 'package:archive/archive_io.dart';

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
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(backendNamesLength);
    rwkvMobile.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  static String getPlatformName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final platformName = rwkvMobile.rwkvmobile_get_platform_name();
    if (kDebugMode) print('💬 platformName: ${platformName.cast<Utf8>().toDartString()}');
    return platformName.cast<Utf8>().toDartString();
  }

  static String getSocName() {
    final rwkvMobile = rwkv_mobile(_getDynamicLibrary());
    final socName = rwkvMobile.rwkvmobile_get_soc_name();
    if (kDebugMode) print('💬 socName: ${socName.cast<Utf8>().toDartString()}');
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
    if (kDebugMode) print('💬 snapdragonHtpArch: ${snapdragonHtpArch.cast<Utf8>().toDartString()}');
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

    final inputsPtr = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);

    var modelPath = options.modelPath;
    final backend = options.backend;
    var modelBackendString = backend.asArgument;
    var tokenizerPath = options.tokenizerPath;

    rwkvmobile_runtime_t runtime;

    // runtime initializations
    switch (backend) {
      case Backend.qnn:
        // TODO: better solution for this
        final tempDir = await getTemporaryDirectory();
        if (kDebugMode) print('💬 tempDir: ${tempDir.path}');

        runtime = rwkvMobile.rwkvmobile_runtime_init_with_name_extra(
          modelBackendString.toNativeUtf8().cast<ffi.Char>(),
          (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>(),
        );
        rwkvMobile.rwkvmobile_runtime_set_qnn_library_path(runtime, (tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());
      case Backend.ncnn:
      case Backend.llamacpp:
      case Backend.webRwkv:
      case Backend.mnn:
      case Backend.coreml:
        runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackendString.toNativeUtf8().cast<ffi.Char>());
    }

    if (runtime.address == 0) throw Exception('😡 Failed to initialize runtime');

    retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) throw Exception('😡 Failed to load tokenizer, tokenizer path: $tokenizerPath');

    if (backend == Backend.coreml) {
      final modelDir = modelPath.substring(0, modelPath.lastIndexOf('/'));
      final modelPathWithoutZip = modelPath.substring(0, modelPath.lastIndexOf('.zip'));
      // delete modelPathWithoutZip directory if exists
      if (File(modelPathWithoutZip).existsSync()) {
        File(modelPathWithoutZip).deleteSync();
      }

      final inputStream = InputFileStream(modelPath);
      // Decode the zip from the InputFileStream. The archive will have the contents of the
      // zip, without having stored the data in memory.
      final archive = ZipDecoder().decodeStream(inputStream);
      final symbolicLinks = []; // keep a list of the symbolic link entities, if any.
      // For all of the entries in the archive
      for (final file in archive) {
        // You should create symbolic links **after** the rest of the archive has been
        // extracted, otherwise the file being linked might not exist yet.
        if (file.isSymbolicLink) {
          symbolicLinks.add(file);
          continue;
        }
        if (file.isFile) {
          // Write the file content to a directory called 'out'.
          // In practice, you should make sure file.name doesn't include '..' paths
          // that would put it outside of the extraction directory.
          // An OutputFileStream will write the data to disk.
          final outputStream = OutputFileStream(modelDir + '/' + file.name);
          // The writeContent method will decompress the file content directly to disk without
          // storing the decompressed data in memory.
          file.writeContent(outputStream);
          // Make sure to close the output stream so the File is closed.
          outputStream.closeSync();
        } else {
          // If the entity is a directory, create it. Normally writing a file will create
          // the directories necessary, but sometimes an archive will have an empty directory
          // with no files.
          Directory(modelDir + '/' + file.name).createSync(recursive: true);
        }
      }
      // Create symbolic links **after** the rest of the archive has been extracted to make sure
      // the file being linked exists.
      for (final entity in symbolicLinks) {
        // Before using this in production code, you should ensure the symbolicLink path
        // points to a file within the archive, otherwise it could be a security issue.
        final link = Link(modelDir + '/' + entity.fullPathName);
        link.createSync(entity.symbolicLink!, recursive: true);
      }
      modelPath = modelPathWithoutZip;
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) throw Exception('😡 Failed to load model, model path: $modelPath');

    final tempDir = await getTemporaryDirectory();
    rwkvMobile.rwkvmobile_set_cache_dir(runtime, tempDir.path.toNativeUtf8().cast<ffi.Char>());

    // TODO: @WangCe 逐渐地迁移到 handler 方法中, 最好不要在该方法声明局部变量
    await for (final _FromFrontend message in receivePort) {
      switch (message) {
        // 🟥 getLatestRuntimeAddress
        case GetLatestRuntimeAddress req:
          if (kDebugMode) print('✅ getLatestRuntimeAddress: ${runtime.address}');
          sendPort.send(LatestRuntimeAddress(latestRuntimeAddress: runtime.address, toRWKV: req));

        // 🟥 setMaxLength
        case SetMaxLength req:
          final arg = req.maxLength;
          if (arg > 0) maxLength = arg;

        // 🟥 clearStates
        case ClearStates _:
          rwkvMobile.rwkvmobile_runtime_clear_state(runtime);

        // 🟥 clearInitialStates
        case ClearInitialStates _:
          rwkvMobile.rwkvmobile_runtime_clear_initial_state(runtime);

        // 🟥 loadInitialStates
        case LoadInitialStates req:
          final statePathPtr = req.statePath.toNativeUtf8().cast<ffi.Char>();
          rwkvMobile.rwkvmobile_runtime_load_initial_state(runtime, statePathPtr);

        // 🟥 setGenerationStopToken
        case SetGenerationStopToken req:
          final arg = req.stopToken;
          if (arg >= 0) generationStopToken = arg;

        // 🟥 setPrompt
        case SetPrompt req:
          final promptPtr = req.prompt.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_prompt(runtime, promptPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set prompt: return value: $retVal', req));

        // 🟥 getPrompt
        case GetPrompt req:
          final stringBuffer = calloc.allocate<ffi.Char>(maxLength);
          rwkvMobile.rwkvmobile_runtime_get_prompt(runtime, stringBuffer, maxLength);
          final prompt = stringBuffer.cast<Utf8>().toDartString();
          sendPort.send(CurrentPrompt(prompt: prompt, toRWKV: req));
          calloc.free(stringBuffer);

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
          rwkvMobile.rwkvmobile_runtime_set_sampler_params(runtime, samplerParams);
          rwkvMobile.rwkvmobile_runtime_set_penalty_params(runtime, penaltyParams);

        // 🟥 getSamplerParams
        case GetSamplerParams req:
          final samplerParams = rwkvMobile.rwkvmobile_runtime_get_sampler_params(runtime);
          final penaltyParams = rwkvMobile.rwkvmobile_runtime_get_penalty_params(runtime);
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

        // 🟥 getIsGenerating
        case GetIsGenerating req:
          bool isGeneratingBool = (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0);
          sendPort.send(IsGenerating(isGenerating: isGeneratingBool, toRWKV: req));
          sendPort.send({'isGenerating': isGeneratingBool});

        // 🟥 setThinkingToken
        case SetThinkingToken req:
          final thinkingTokenPtr = req.thinkingToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_thinking_token(runtime, thinkingTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set thinking token', req));

        // 🟥 setEosToken
        case SetEosToken req:
          final eosTokenPtr = req.eosToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_eos_token(runtime, eosTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set eos token', req));

        // 🟥 setBosToken
        case SetBosToken req:
          final bosTokenPtr = req.bosToken.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_bos_token(runtime, bosTokenPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set bos token', req));

        // 🟥 setTokenBanned
        case SetTokenBanned req:
          final tokenBannedPtr = calloc.allocate<ffi.Int>(req.tokenBanned.length);
          for (var i = 0; i < req.tokenBanned.length; i++) {
            tokenBannedPtr[i] = req.tokenBanned[i];
          }
          retVal = rwkvMobile.rwkvmobile_runtime_set_token_banned(runtime, tokenBannedPtr, req.tokenBanned.length);
          calloc.free(tokenBannedPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set token banned: retVal: $retVal', req, retVal));

        // 🟥 setUserRole
        case SetUserRole req:
          final userRolePtr = req.userRole.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_user_role(runtime, userRolePtr);
          if (retVal != 0) sendPort.send(Error('Failed to set user role: retVal: $retVal', req, retVal));

        // 🟥 setResponseRole
        case SetResponseRole req:
          final responseRolePtr = req.responseRole.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_response_role(runtime, responseRolePtr);
          if (retVal != 0) sendPort.send(Error('Failed to set response role: retVal: $retVal', req, retVal));

        // 🟥 loadVisionEncoder
        case LoadVisionEncoder req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder(runtime, encoderPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load vision encoder: retVal: $retVal', req, retVal));

        // 🟥 loadVisionEncoderAndAdapter
        case LoadVisionEncoderAndAdapter req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          final adapterPathPtr = req.adapterPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_vision_encoder_and_adapter(runtime, encoderPathPtr, adapterPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load vision encoder and adapter: retVal: $retVal', req, retVal));

        // 🟥 releaseVisionEncoder
        case ReleaseVisionEncoder req:
          retVal = rwkvMobile.rwkvmobile_runtime_release_vision_encoder(runtime);
          if (retVal != 0) sendPort.send(Error('Failed to release vision encoder', req, retVal));

        // 🟥 setVisionPrompt
        case SetVisionPrompt req:
          final imagePathPtr = req.imagePathPtr.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_image_prompt(runtime, imagePathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set image prompt', req, retVal));

        // 🟥 loadWhisperEncoder
        case LoadWhisperEncoder req:
          final encoderPathPtr = req.encoderPath.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_load_whisper_encoder(runtime, encoderPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to load whisper encoder', req, retVal));

        // 🟥 releaseWhisperEncoder
        case ReleaseWhisperEncoder req:
          retVal = rwkvMobile.rwkvmobile_runtime_release_whisper_encoder(runtime);
          if (retVal != 0) sendPort.send(Error('Failed to release whisper encoder', req, retVal));

        // 🟥 setAudioPrompt
        case SetAudioPrompt req:
          final audioPathPtr = req.audioPathPtr.toNativeUtf8().cast<ffi.Char>();
          retVal = rwkvMobile.rwkvmobile_runtime_set_audio_prompt(runtime, audioPathPtr);
          if (retVal != 0) sendPort.send(Error('Failed to set audio prompt', req, retVal));

        // 🟥 message
        case ChatAsync req:
          for (var i = 0; i < req.messages.length; i++) {
            inputsPtr[i] = req.messages[i].toNativeUtf8().cast<ffi.Char>();
          }
          final numInputs = req.messages.length;

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
            sendPort.send(Error('LLM is already generating', req, retVal));
            break;
          }

          sendPort.send(GenerateStart(toRWKV: req));
          retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history_async(
            runtime,
            inputsPtr,
            numInputs,
            maxLength,
            ffi.nullptr,
            req.reasoning ? 1 : 0,
          );
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation thread: retVal: $retVal', toRWKV: req));

        // 🟥 generateAsync
        case GenerateAsync req:
          final promptPtr = req.prompt.toNativeUtf8().cast<ffi.Char>();

          if (rwkvMobile.rwkvmobile_runtime_is_generating(runtime) != 0) {
            sendPort.send(Error('LLM is already generating', req));
            break;
          }

          sendPort.send(GenerateStart(toRWKV: req));
          if (kDebugMode) print('🔥 Starting LLM generation thread (gen mode), maxlength = $maxLength');
          retVal = rwkvMobile.rwkvmobile_runtime_gen_completion_async(runtime, promptPtr, maxLength, generationStopToken, ffi.nullptr);
          if (kDebugMode) print('🔥 Started LLM generation thread (gen mode)');
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation: retVal: $retVal', toRWKV: req));

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
            final prefillSpeed = showQuerySpeed ? rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime) : -1.0;
            final decodeSpeed = showQuerySpeed ? rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime) : -1.0;

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

            // final end = DateTime.now().microsecondsSinceEpoch;
            // final duration = end - start;
            // if (kDebugMode) print("🔥 duration: $duration");
          }

          final nativeCallable = ffi.NativeCallable<ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>)>.isolateLocal(
            callbackFunction,
          );
          sendPort.send(GenerateStart(toRWKV: req));
          if (kDebugMode) print('🔥 Start to call LLM (gen mode), maxlength = $maxLength');
          retVal = rwkvMobile.rwkvmobile_runtime_gen_completion(
            runtime,
            promptPtr,
            maxLength,
            generationStopToken,
            nativeCallable.nativeFunction,
          );
          if (kDebugMode) print('🔥 Call LLM done (gen mode)');
          if (retVal != 0) sendPort.send(GenerateStop(error: 'Failed to start generation: retVal: $retVal', toRWKV: req));

          sendPort.send({'sudokuOthelloResponse': responseStr});
          if (retVal == 0) sendPort.send(GenerateStop(toRWKV: req));

        // 🟥 releaseModel
        case ReleaseModel _:
          if (kDebugMode) print('💬 Releasing model');
          rwkvMobile.rwkvmobile_runtime_release(runtime);
          runtime = ffi.nullptr;

        // 🟥 initRuntime
        case ReInitRuntime req:
          String modelPath = req.modelPath;
          final modelBackendString = req.backend.asArgument;
          final backend = req.backend;
          final tokenizerPath = req.tokenizerPath;
          if (runtime.address != 0) {
            sendPort.send(ReInitSteps(done: false, step: 'release runtime if runtime.address != 0', toRWKV: req));
            rwkvMobile.rwkvmobile_runtime_release(runtime);
          }

          sendPort.send(ReInitSteps(done: false, step: 'init backend: ${backend.asArgument}', toRWKV: req));
          switch (backend) {
            case Backend.ncnn:
            case Backend.llamacpp:
            case Backend.webRwkv:
            case Backend.mnn:
            case Backend.coreml:
              runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackendString.toNativeUtf8().cast<ffi.Char>());
            case Backend.qnn:
              // TODO: better solution for this
              final tempDir = await getTemporaryDirectory();

              sendPort.send(ReInitSteps(done: false, step: 'init with name extra', toRWKV: req));
              runtime = rwkvMobile.rwkvmobile_runtime_init_with_name_extra(
                modelBackendString.toNativeUtf8().cast<ffi.Char>(),
                (tempDir.path + '/assets/lib/libQnnHtp.so').toNativeUtf8().cast<ffi.Void>(),
              );

              sendPort.send(ReInitSteps(done: false, step: 'set qnn library path', toRWKV: req));
              rwkvMobile.rwkvmobile_runtime_set_qnn_library_path(runtime, (tempDir.path + '/assets/lib/').toNativeUtf8().cast<ffi.Char>());
          }

          if (runtime.address == 0) {
            sendPort.send(
              ReInitSteps(
                done: false,
                error: 'Failed to initialize runtime: runtime.address: ${runtime.address}',
                toRWKV: req,
                success: false,
              ),
            );
            break;
          }

          retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
          if (retVal != 0) {
            sendPort.send(
              ReInitSteps(done: false, error: 'Failed to load tokenizer, tokenizer path: $tokenizerPath', toRWKV: req, success: false),
            );
            break;
          }

          if (backend == Backend.coreml) {
            final modelDir = modelPath.substring(0, modelPath.lastIndexOf('/'));
            final modelPathWithoutZip = modelPath.substring(0, modelPath.lastIndexOf('.zip'));
            // delete modelPathWithoutZip directory if exists
            if (File(modelPathWithoutZip).existsSync()) {
              File(modelPathWithoutZip).deleteSync();
            }

            final inputStream = InputFileStream(modelPath);
            // Decode the zip from the InputFileStream. The archive will have the contents of the
            // zip, without having stored the data in memory.
            final archive = ZipDecoder().decodeStream(inputStream);
            final symbolicLinks = []; // keep a list of the symbolic link entities, if any.
            // For all of the entries in the archive
            for (final file in archive) {
              // You should create symbolic links **after** the rest of the archive has been
              // extracted, otherwise the file being linked might not exist yet.
              if (file.isSymbolicLink) {
                symbolicLinks.add(file);
                continue;
              }
              if (file.isFile) {
                // Write the file content to a directory called 'out'.
                // In practice, you should make sure file.name doesn't include '..' paths
                // that would put it outside of the extraction directory.
                // An OutputFileStream will write the data to disk.
                final outputStream = OutputFileStream(modelDir + '/' + file.name);
                // The writeContent method will decompress the file content directly to disk without
                // storing the decompressed data in memory.
                file.writeContent(outputStream);
                // Make sure to close the output stream so the File is closed.
                outputStream.closeSync();
              } else {
                // If the entity is a directory, create it. Normally writing a file will create
                // the directories necessary, but sometimes an archive will have an empty directory
                // with no files.
                Directory(modelDir + '/' + file.name).createSync(recursive: true);
              }
            }
            // Create symbolic links **after** the rest of the archive has been extracted to make sure
            // the file being linked exists.
            for (final entity in symbolicLinks) {
              // Before using this in production code, you should ensure the symbolicLink path
              // points to a file within the archive, otherwise it could be a security issue.
              final link = Link(modelDir + '/' + entity.fullPathName);
              link.createSync(entity.symbolicLink!, recursive: true);
            }
            modelPath = modelPathWithoutZip;
          }

          retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPath.toNativeUtf8().cast<ffi.Char>());
          if (retVal != 0) {
            sendPort.send(ReInitSteps(done: false, error: 'Failed to load model, model path: $modelPath', toRWKV: req, success: false));
            break;
          }

          sendPort.send(ReInitSteps(done: true, success: true, toRWKV: req));

        // 🟥 stop
        case Stop req:
          bool generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1;
          while (generating) {
            rwkvMobile.rwkvmobile_runtime_stop_generation(runtime);
            await Future.delayed(const Duration(milliseconds: 5));
            generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1;
            if (!generating) sendPort.send(GenerateStop(toRWKV: req));
          }

        // 🟥 getResponseBufferContent
        case GetResponseBufferContent req:
          final responseBufferContent = rwkvMobile.rwkvmobile_runtime_get_response_buffer_content(runtime);
          int length = responseBufferContent.length;
          final Uint8List byteList = responseBufferContent.content.cast<ffi.Uint8>().asTypedList(length);
          final String str = _codec.decode(byteList);
          final eosFound = responseBufferContent.eos_found == 1;
          sendPort.send(ResponseBufferContent(responseBufferContent: str, eosFound: eosFound, toRWKV: req));

        // 🟥 getPrefillAndDecodeSpeed
        case GetPrefillAndDecodeSpeed req:
          final prefillSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_prefill_speed(runtime);
          final decodeSpeed = rwkvMobile.rwkvmobile_runtime_get_avg_decode_speed(runtime);
          final progress = rwkvMobile.rwkvmobile_runtime_get_prefill_progress(runtime);
          sendPort.send(Speed(prefillSpeed: prefillSpeed, decodeSpeed: decodeSpeed, prefillProgress: progress, toRWKV: req));

        // 🟥 getResponseBufferIds
        case GetResponseBufferIds _:
          final responseBufferIds = rwkvMobile.rwkvmobile_runtime_get_response_buffer_ids(runtime);
          final responseBufferIdsList = responseBufferIds.ids.asTypedList(responseBufferIds.len).toList();
          rwkvMobile.rwkvmobile_runtime_free_token_ids(responseBufferIds);
          sendPort.send({'responseBufferIds': responseBufferIdsList});

        // 🟥 loadTTSModels
        case LoadTTSModels req:
          throw UnimplementedError('TODO: rwkvmobile_runtime_sparktts_load_models');

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
          retVal = rwkvMobile.rwkvmobile_runtime_run_spark_tts_streaming_async(
            runtime,
            ttsText.toNativeUtf8().cast<ffi.Char>(),
            promptSpeechText.toNativeUtf8().cast<ffi.Char>(),
            promptWavPath.toNativeUtf8().cast<ffi.Char>(),
            outputWavPath.toNativeUtf8().cast<ffi.Char>(),
          );

          if (retVal != 0) sendPort.send(Error('Failed to run TTS', req));
          if (retVal != 0) break;

          sendPort.send(TTSGenerationStart(start: true, toRWKV: req));

        // 🟥 getTTSGenerationProgress
        case GetTTSGenerationProgress req:
          // int numCurrentGeneratedWavs = 0;
          // List<double> perWavProgress = [];
          // List<String> fileList = [];
          // try {
          //   final ttsOutputFiles = rwkvMobile.rwkvmobile_runtime_tts_get_current_output_files(runtime);
          //   final outputFiles = ttsOutputFiles.cast<Utf8>().toDartString();
          //   fileList = outputFiles.split(',').map((f) => f.replaceAll('"', '').trim()).toList();
          // } catch (_) {
          //   fileList = [];
          // }
          // // remove empty string from fileList
          // fileList = fileList.where((f) => f.isNotEmpty).toList();
          // numCurrentGeneratedWavs = fileList.length;
          // if (numCurrentGeneratedWavs > 0) perWavProgress = List.filled(numCurrentGeneratedWavs, 1.0).toList();
          // final numTotalWavs = rwkvMobile.rwkvmobile_runtime_tts_get_num_total_output_wavs(runtime);
          // final ttsPerWavProgress = rwkvMobile.rwkvmobile_runtime_tts_get_generation_progress(runtime);
          // if (ttsPerWavProgress < 1.0) perWavProgress.add(ttsPerWavProgress);
          // double ttsOverallProgress = numCurrentGeneratedWavs.toDouble();
          // if (ttsPerWavProgress < 1.0) ttsOverallProgress += ttsPerWavProgress;
          // ttsOverallProgress = ttsOverallProgress / numTotalWavs.toDouble();
          // // Range from 0.0 to 1.0
          // sendPort.send(TTSResult(filePaths: fileList, perWavProgress: perWavProgress, overallProgress: ttsOverallProgress, toRWKV: req));
          throw UnimplementedError('TODO: deprecated');

        // 🟥 getTTSOutputFileList
        case GetTTSOutputFileList req:
          // List<String> fileList = [];
          // try {
          //   final ttsOutputFiles = rwkvMobile.rwkvmobile_runtime_tts_get_current_output_files(runtime);
          //   final outputFiles = ttsOutputFiles.cast<Utf8>().toDartString();
          //   fileList = outputFiles.split(',').map((f) => f.replaceAll('"', '').trim()).toList();
          // } catch (_) {
          //   fileList = [];
          // }
          // sendPort.send(TTSOutputFileList(outputFileList: fileList, toRWKV: req));
          throw UnimplementedError('TODO: deprecated');

        // 🟥 getTTSStreamingBuffer
        case GetTTSStreamingBuffer req:
          final generating = rwkvMobile.rwkvmobile_runtime_is_generating(runtime) == 1;
          final ttsStreamingBuffer = rwkvMobile.rwkvmobile_runtime_get_tts_streaming_buffer(runtime);
          final rawFloatList = ttsStreamingBuffer.samples.asTypedList(ttsStreamingBuffer.length).toList();
          final ttsStreamingBufferList = rawFloatList.map((e) {
            // Handle Infinity and NaN values
            if (e.isInfinite || e.isNaN || e == 0 || e.isNegative) {
              return 0; // or another appropriate default value
            }
            return (e * 32768.0).toInt(); // convert to int16; remove this if you need raw float samples
          }).toList();
          sendPort.send(
            TTSStreamingBuffer(
              generating: generating,
              ttsStreamingBuffer: ttsStreamingBufferList,
              ttsStreamingBufferLength: ttsStreamingBuffer.length,
              rawFloatList: rawFloatList,
              toRWKV: req,
            ),
          );

        // 🟥 setTTSCFMSteps
        case SetTTSCFMSteps req:
          break;
        // 🟥 dumpLog
        case DumpLog req:
          final log = rwkvMobile.rwkvmobile_dump_log();
          sendPort.send(RuntimeLog(runtimeLog: log.cast<Utf8>().toDartString(), toRWKV: req));
      }
    }
  }
}
