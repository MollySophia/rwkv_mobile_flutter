import 'package:rwkv_mobile_flutter/from_rwkv.dart';
import 'package:rwkv_mobile_flutter/types.dart';

/// Send request from frontend isolate to rwkv isolate
///
/// 可以使用 switch case 来处理各个 response
///
/// 每个 request 可以携带自己需要的响应参数
///
/// 可以在该文件中使用 cursor tab 来快速生成各个 request
///
/// 建议同时打开 lib/rwkv_mobile_flutter.dart 文件以获得快速智能提示
sealed class ToRWKV {
  final int requestId;

  ToRWKV() : requestId = DateTime.now().microsecondsSinceEpoch;

  @override
  bool operator ==(Object other) {
    return other is ToRWKV && other.requestId == requestId && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => requestId.hashCode;
}

class ClearStates extends ToRWKV {
  final int modelID;

  ClearStates({required this.modelID});
}

class DumpLog extends ToRWKV {}

class DumpStateInfo extends ToRWKV {
  final int modelID;

  DumpStateInfo({required this.modelID});
}

class SaveRuntimeStateByHistory extends ToRWKV {
  final List<String> messages;
  final String stateSavePath;
  final int modelID;

  SaveRuntimeStateByHistory({required this.messages, required this.stateSavePath, required this.modelID});
}

class LoadRuntimeStateToMemory extends ToRWKV {
  final String stateLoadPath;
  final int modelID;

  LoadRuntimeStateToMemory({required this.stateLoadPath, required this.modelID});
}

class GenerateAsync extends ToRWKV {
  final String prompt;
  final int batch;
  final int modelID;

  final int? maxLength;
  final int? stopToken;
  final bool? disableCache;

  GenerateAsync(this.prompt, {required this.modelID, this.batch = 1, this.maxLength, this.stopToken, this.disableCache}) : super();
}

class RunEvaluation extends ToRWKV {
  final String sourceText;
  final String targetText;
  final int modelID;

  RunEvaluation(this.sourceText, this.targetText, {required this.modelID}) : super();
  static const responseType = EvaluationResults;
}

class SudokuOthelloGenerate extends ToRWKV {
  final String prompt;
  final bool decodeStream;
  final bool wantRawJSON;
  final int modelID;

  SudokuOthelloGenerate(this.prompt, {required this.modelID, this.decodeStream = true, this.wantRawJSON = true});

  static const responseType = StreamResponse;
}

class GetIsGenerating extends ToRWKV {
  final int modelID;

  GetIsGenerating({required this.modelID});
}

class GetPrefillAndDecodeSpeed extends ToRWKV {
  final int modelID;

  GetPrefillAndDecodeSpeed({required this.modelID});

  static const responseType = Speed;
}

class GetPrompt extends ToRWKV {
  final int modelID;

  GetPrompt({required this.modelID});
}

// rwkvmobile_runtime_get_tts_streaming_buffer获取到音频buffer以及它当前的长度（单位为样本数不是字节数，即是float数组长度）
class GetTTSStreamingBuffer extends ToRWKV {
  final int modelID;

  GetTTSStreamingBuffer({required this.modelID});

  static const responseType = TTSStreamingBuffer;
}

/// 获取本次推理已生成的 tokens 被 decode 为普通字符串的值
///
/// 目前, 前端通过周期性调用该方法, 来获取 decode 的值渲染到 UI 上
///
/// 1. stop 之后 responseBufferContent 还保留着
/// 2. 然后 resume 之后 responseBufferContent 会先短暂清空
/// 3. 然后变成 stop 前已经生成了的内容并接着生成
class GetResponseBufferContent extends ToRWKV {
  /// 发起 `GetResponseBufferContent` 请求时, 是为的哪些 messages 发起的
  final List<String> messages;
  final int modelID;

  GetResponseBufferContent({required this.messages, required this.modelID});

  static const responseType = ResponseBufferContent;
}

class GetResponseBufferTokensCount extends ToRWKV {
  final int modelID;

  GetResponseBufferTokensCount({required this.modelID});

  static const responseType = TokensCount;
}

class GetResponseBufferTokensCountBatch extends ToRWKV {
  final int modelID;

  GetResponseBufferTokensCountBatch({required this.modelID});

  static const responseType = TokensCountBatch;
}

class GetBatchResponseBufferContent extends ToRWKV {
  /// 发起 `GetBatchResponseBufferContent` 请求时, 是为的哪些 messages 发起的
  final List<String> messages;
  final int modelID;

  GetBatchResponseBufferContent({required this.messages, required this.modelID});

  static const responseType = ResponseBatchBufferContent;
}

class GetLoadedModelPathByID extends ToRWKV {
  final int modelID;

  GetLoadedModelPathByID(this.modelID);

  static const responseType = LoadedModelPathByID;
}

class GetLoadedModelIDs extends ToRWKV {
  static const responseType = LoadedModelIDs;
}

/// stop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
class Stop extends ToRWKV {
  final int modelID;

  Stop({required this.modelID});
}

class GetResponseBufferIds extends ToRWKV {
  final int modelID;

  GetResponseBufferIds({required this.modelID});
}

class GetSamplerParams extends ToRWKV {
  final int modelID;

  GetSamplerParams({required this.modelID});
}

class AddTTSModel extends ToRWKV {
  final String modelPath;
  final Backend backend;
  final String tokenizerPath;
  final String wav2vec2Path;
  final String bicodecTokenizerPath;
  final String bicodecDetokenizerPath;

  static const responseType = LoadModelSteps;

  AddTTSModel({
    required this.modelPath,
    required this.backend,
    required this.tokenizerPath,
    required this.wav2vec2Path,
    required this.bicodecTokenizerPath,
    required this.bicodecDetokenizerPath,
  });
}

class LoadRWKVModel extends ToRWKV {
  final String modelPath;
  final Backend backend;
  final String tokenizerPath;

  /// Extra data for loading model
  ///
  /// Used for mark with [FileInfo] is loading
  ///
  /// [FileInfo]: Check github repo: RWKV_APP
  final dynamic extra;

  static const responseType = LoadModelSteps;

  LoadRWKVModel({
    required this.modelPath,
    required this.backend,
    required this.tokenizerPath,
    this.extra,
  });
}

class LoadSparkTTSModels extends ToRWKV {
  final String wav2vec2Path;
  final String bicodecTokenizerPath;
  final String bicodecDetokenizerPath;

  LoadSparkTTSModels({required this.wav2vec2Path, required this.bicodecTokenizerPath, required this.bicodecDetokenizerPath});
}

class LoadTTSTextNormalizer extends ToRWKV {
  final String fstPath;

  LoadTTSTextNormalizer(this.fstPath);
}

class LoadVisionEncoder extends ToRWKV {
  final String encoderPath;
  final int modelID;

  LoadVisionEncoder(this.encoderPath, {required this.modelID});
}

class LoadVisionEncoderAndAdapter extends ToRWKV {
  final String encoderPath;
  final String adapterPath;
  final int modelID;

  LoadVisionEncoderAndAdapter(this.encoderPath, this.adapterPath, {required this.modelID});
}

class LoadWhisperEncoder extends ToRWKV {
  final String encoderPath;
  final int modelID;

  LoadWhisperEncoder(this.encoderPath, {required this.modelID});
}

class LoadInitialStates extends ToRWKV {
  final String statePath;
  final int modelID;

  LoadInitialStates(this.statePath, {required this.modelID});
}

class UnloadInitialStates extends ToRWKV {
  final String statePath;
  final int modelID;

  UnloadInitialStates(this.statePath, {required this.modelID});
}

class ReleaseRWKVModel extends ToRWKV {
  final int modelID;

  /// Extra data for loading model
  ///
  /// Used for mark with [FileInfo] is loading
  ///
  /// [FileInfo]: Check github repo: RWKV_APP
  final dynamic extra;

  ReleaseRWKVModel({required this.modelID, this.extra});
}

class ReleaseTTSModels extends ToRWKV {}

class ReleaseVisionEncoder extends ToRWKV {
  final int modelID;

  ReleaseVisionEncoder({required this.modelID});
}

class ReleaseWhisperEncoder extends ToRWKV {
  final int modelID;

  ReleaseWhisperEncoder({required this.modelID});
}

class ChatAsync extends ToRWKV {
  final int modelID;

  final List<String> messages;
  final bool enableReasoning;
  final bool forceReasoning;
  final bool addGenerationPrompt;

  final int? maxLength;

  /// 约束模型输出的第一个 token
  ///
  /// 0 或者 null: 无限制, 1: 中文字符
  final int? forceLang;

  ChatAsync(
    this.messages, {
    required this.enableReasoning,
    required this.forceReasoning,
    required this.addGenerationPrompt,
    required this.modelID,
    this.maxLength,
    this.forceLang,
  });
}

class ChatBatchAsync extends ToRWKV {
  final int modelID;

  final List<List<String>> messages;
  final bool enableReasoning;
  final bool forceReasoning;
  final bool addGenerationPrompt;

  final int batchSize;

  final int? maxLength;

  /// 约束模型输出的第一个 token
  ///
  /// 0 或者 null: 无限制, 1: 中文字符
  final int? forceLang;

  ChatBatchAsync(
    this.messages, {
    required this.enableReasoning,
    required this.forceReasoning,
    required this.addGenerationPrompt,
    required this.batchSize,
    required this.modelID,
    this.maxLength,
    this.forceLang,
  });
}

class GetSupportedBatchSizes extends ToRWKV {
  final int modelID;

  GetSupportedBatchSizes({required this.modelID});
}

/// 开始 TTS 任务
///
/// 发送消息给 ffi thread
///
/// 在 cpp side 开启新线程
///
/// 通过轮训的方式获取 response
class StartTTS extends ToRWKV {
  final String ttsText;
  final String instructionText;
  final String promptWavPath;
  final String outputWavPath;
  final String promptSpeechText;
  final int modelID;

  StartTTS({
    required this.ttsText,
    required this.instructionText,
    required this.promptWavPath,
    required this.outputWavPath,
    required this.promptSpeechText,
    required this.modelID,
  });
}

class StartTTSWithGlobalTokens extends ToRWKV {
  final String ttsText;
  final String outputWavPath;
  final List<int> globalTokens;
  final int modelID;

  StartTTSWithGlobalTokens({
    required this.ttsText,
    required this.outputWavPath,
    required this.globalTokens,
    required this.modelID,
  });
}

class StartTTSWithProperties extends ToRWKV {
  final String ttsText;
  final String outputWavPath;
  final TTSPropertyAge age;
  final TTSPropertyGender gender;
  final TTSPropertyEmotion emotion;
  final TTSPropertySpeed speed;
  final TTSPropertyPitch pitch;
  final int modelID;

  StartTTSWithProperties({
    required this.ttsText,
    required this.outputWavPath,
    required this.age,
    required this.gender,
    required this.emotion,
    required this.speed,
    required this.pitch,
    required this.modelID,
  });
}

class GetCurrentTTSGlobalTokens extends ToRWKV {}

class SetAudioPrompt extends ToRWKV {
  final String audioPathPtr;
  final int modelID;

  SetAudioPrompt(this.audioPathPtr, {required this.modelID});
}

class SetBosToken extends ToRWKV {
  final String bosToken;
  final int modelID;

  SetBosToken(this.bosToken, {required this.modelID});
}

class SetEosToken extends ToRWKV {
  final String eosToken;
  final int modelID;

  SetEosToken(this.eosToken, {required this.modelID});
}

class SetGenerationStopToken extends ToRWKV {
  final int stopToken;
  final int modelID;

  SetGenerationStopToken(this.stopToken, {required this.modelID});
}

class SetMaxLength extends ToRWKV {
  final int maxLength;
  final int modelID;

  SetMaxLength(this.maxLength, {required this.modelID});
}

class SetPrompt extends ToRWKV {
  final String prompt;
  final int modelID;

  SetPrompt(this.prompt, {required this.modelID});
}

class SetSamplerParams extends ToRWKV {
  final num temperature;
  final num topK;
  final num topP;
  final num presencePenalty;
  final num frequencyPenalty;
  final num penaltyDecay;
  final int modelID;

  SetSamplerParams({
    required this.temperature,
    required this.topK,
    required this.topP,
    required this.presencePenalty,
    required this.frequencyPenalty,
    required this.penaltyDecay,
    required this.modelID,
  });
}

class SetSeed extends ToRWKV {
  final int seed;
  final int modelID;

  SetSeed(this.seed, {required this.modelID});
}

class GetSeed extends ToRWKV {
  final int modelID;

  GetSeed({required this.modelID});

  static const responseType = CurrentSeed;
}

class SetThinkingToken extends ToRWKV {
  final String thinkingToken;
  final int modelID;

  SetThinkingToken(this.thinkingToken, {required this.modelID});
}

class SetTokenBanned extends ToRWKV {
  final List<int> tokenBanned;
  final int modelID;

  SetTokenBanned(this.tokenBanned, {required this.modelID});
}

class SetUserRole extends ToRWKV {
  final String userRole;
  final int modelID;

  SetUserRole(this.userRole, {required this.modelID});
}

@Deprecated('Already replaced by new Vision Model API')
class SetVisionPrompt extends ToRWKV {
  final String imagePathPtr;
  final int modelID;

  SetVisionPrompt(this.imagePathPtr, {required this.modelID});
}

// rwkvmobile_runtime_set_response_role
// rwkvmobile_runtime_set_user_role

/// 把user role设置成English
///
/// response role设置成Chinese 然后像聊天一样用户输入英文就行
///
/// 原本的格式是User: xxx\n\nAssistant:，现在是English: xxx\n\nChinese:，可以直接换
class SetResponseRole extends ToRWKV {
  final String responseRole;
  final int modelID;

  SetResponseRole({this.responseRole = 'Assistant', required this.modelID});
}

/// Modrwkv v3模型要求"User:" "Assistant:" 之后没有空格，用这个api设置False表示不加空格。
class SetSpaceAfterRoles extends ToRWKV {
  final bool spaceAfterRoles;
  final int modelID;

  SetSpaceAfterRoles(this.spaceAfterRoles, {required this.modelID});
}

class SetImageUniqueIdentifier extends ToRWKV {
  final String uniqueIdentifier;

  SetImageUniqueIdentifier(this.uniqueIdentifier);
}

class SetSamplerAndPenaltyParams extends ToRWKV {
  final List<double> temperatures;
  final List<double> topKs;
  final List<double> topPs;
  final List<double> presencePenalties;
  final List<double> frequencyPenalties;
  final List<double> penaltyDecays;
  final int modelID;

  SetSamplerAndPenaltyParams({
    required this.temperatures,
    required this.topKs,
    required this.topPs,
    required this.presencePenalties,
    required this.frequencyPenalties,
    required this.penaltyDecays,
    required this.modelID,
  });
}

class GetSamplerAndPenaltyParams extends ToRWKV {
  final int modelID;
  final int batchSize;

  GetSamplerAndPenaltyParams({required this.modelID, this.batchSize = 1});

  static const responseType = SamplerAndPenaltyParams;
}

class CalculateTokensCountFromMessages extends ToRWKV {
  final int modelID;

  final List<String> messages;

  CalculateTokensCountFromMessages(
    this.messages, {
    required this.modelID,
  });
}

class CalculateTokensCountRaw extends ToRWKV {
  final int modelID;
  final String text;

  CalculateTokensCountRaw(this.text, {required this.modelID});
}
