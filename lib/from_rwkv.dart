import 'package:rwkv_mobile_flutter/to_rwkv.dart';
import 'package:rwkv_mobile_flutter/types.dart';

/// Send response from rwkv isolate to frontend isolate
///
/// 可以使用 switch case 来处理各个 response
///
/// 每个 response 可以携带自己需要的响应参数
///
/// 可以在该文件中使用 cursor tab 来快速生成各个 request
///
/// 建议同时打开 lib/rwkv_mobile_flutter.dart 文件以获得快速智能提示
sealed class FromRWKV {
  /// 用于追踪产生该 response 的 request
  final ToRWKV? req;

  FromRWKV({this.req});
}

class CurrentPrompt extends FromRWKV {
  final String prompt;

  CurrentPrompt({required this.prompt, super.req});
}

class EnableReasoning extends FromRWKV {}

class Error extends FromRWKV {
  final String message;

  /// 用于追踪产生该 response 的 request
  final ToRWKV? to;
  final int? retVal;

  Error(this.message, [this.to, this.retVal]) : super(req: to);
}

class GenerateStart extends FromRWKV {
  GenerateStart({super.req});
}

class GenerateStop extends FromRWKV {
  final String? error;

  GenerateStop({this.error, super.req});
}

class SupportedBatchSizes extends FromRWKV {
  final List<int> supportedBatchSizes;
  SupportedBatchSizes({required this.supportedBatchSizes, super.req});
}

class LoadModelSteps extends FromRWKV {
  final int? modelID;
  final String? info;
  final LoadingStatus status;
  final double? progress;

  LoadModelSteps({
    required this.status,
    required super.req,
    this.info,
    this.modelID,
    this.progress,
  });
}

class Speed extends FromRWKV {
  final double prefillSpeed;
  final double decodeSpeed;
  final double prefillProgress;

  Speed({
    required this.prefillProgress,
    required this.prefillSpeed,
    required this.decodeSpeed,
    super.req,
  });
}

/// 获取本次推理已生成的 tokens 被 decode 为普通字符串的值
///
/// 目前, 前端通过周期性调用该方法, 来获取 decode 的值渲染到 UI 上
///
/// 1. stop 之后 responseBufferContent 还保留着
/// 2. 然后 resume 之后 responseBufferContent 会先短暂清空
/// 3. 然后变成 stop 前已经生成了的内容并接着生成
class ResponseBufferContent extends FromRWKV {
  /// 当前已生成的 tokens 被 decode 为普通字符串的值
  final String responseBufferContent;

  /// 是否已生成 EOS token, 代表本次生成是否已完结
  final bool eosFound;

  ResponseBufferContent({
    required this.responseBufferContent,
    required this.eosFound,
    super.req,
  });
}

class ResponseBatchBufferContent extends FromRWKV {
  /// 当前已生成的 tokens 被 decode 为普通字符串的值
  final List<String> responseBufferContent;

  /// 是否已生成 EOS token, 代表本次生成是否已完结
  final List<bool> eosFound;

  final int batchSize;

  ResponseBatchBufferContent({
    required this.responseBufferContent,
    required this.eosFound,
    required this.batchSize,
    super.req,
  });
}

class LoadedModelPathByID extends FromRWKV {
  final String loadedModelPath;
  final int modelID;

  LoadedModelPathByID({
    required this.loadedModelPath,
    required this.modelID,
    super.req,
  });
}

class LoadedModelIDs extends FromRWKV {
  final List<int> loadedModelIDs;

  LoadedModelIDs({required this.loadedModelIDs, super.req});
}

class SamplerParams extends FromRWKV {
  final num temperature;
  final num topK;
  final num topP;
  final num presencePenalty;
  final num frequencyPenalty;
  final num penaltyDecay;

  SamplerParams({
    required this.temperature,
    required this.topK,
    required this.topP,
    required this.presencePenalty,
    required this.frequencyPenalty,
    required this.penaltyDecay,
    super.req,
  });
}

class SpksNames extends FromRWKV {}

/// 在每次新生成 token 的时候, 都会被调用
class StreamResponse extends FromRWKV {
  static const requestType = SudokuOthelloGenerate;

  /// 调用 [SudokuOthelloGenerate] 后, 生成的所有解码后的字符串
  final String streamResponse;

  /// 新生成的 token
  final int streamResponseToken;

  /// 新生成的 token, decode 了之后字符串
  final String streamResponseNewText;

  /// 预填充速度
  final double prefillSpeed;

  /// 解码速度
  final double decodeSpeed;

  StreamResponse({
    required this.streamResponse,
    required this.streamResponseToken,
    required this.streamResponseNewText,
    required this.prefillSpeed,
    required this.decodeSpeed,
    super.req,
  });
}

class EvaluationResults extends FromRWKV {
  final List<double> logits;
  final List<bool> corrects;
  final List<String> outputTexts;

  EvaluationResults({required this.logits, required this.corrects, required this.outputTexts, super.req});
}

class TTSGenerationStart extends FromRWKV {
  final bool start;

  TTSGenerationStart({required this.start, super.req});
}

class TTSCFMSteps extends FromRWKV {}

class RuntimeLog extends FromRWKV {
  final String runtimeLog;

  RuntimeLog({required this.runtimeLog, super.req});
}

class StateInfo extends FromRWKV {
  final String stateInfo;

  StateInfo({required this.stateInfo, super.req});
}

class IsGenerating extends FromRWKV {
  final bool isGenerating;
  final int modelID;

  IsGenerating({
    required this.isGenerating,
    required this.modelID,
    super.req,
  });
}

// rwkvmobile_runtime_get_tts_streaming_buffer获取到音频buffer以及它当前的长度（单位为样本数不是字节数，即是float数组长度）
// 转成16bit pcm的话只要for i in len(samples): data = static_cast<int16_t>(samples[i] * 32768.0f)就
// 是单声道的16000采样率的浮点数
// final class tts_streaming_buffer extends ffi.Struct {
//   external ffi.Pointer<ffi.Float> samples;

//   @ffi.Int()
//   external int length;
// }
class TTSStreamingBuffer extends FromRWKV {
  // TODO: 不通过 ffi 传递, 而是直接传递内存块的权限
  final List<int> ttsStreamingBuffer;
  final List<double> rawFloatList;
  final int ttsStreamingBufferLength;
  final bool generating;

  TTSStreamingBuffer({
    required this.ttsStreamingBuffer,
    required this.ttsStreamingBufferLength,
    required this.generating,
    required this.rawFloatList,
    super.req,
  });
}

class CurrentSeed extends FromRWKV {
  final int seed;
  final int modelID;

  CurrentSeed({required this.seed, required this.modelID, super.req});
}

class SamplerAndPenaltyParams extends FromRWKV {
  final List<double> temperatures;
  final List<double> topKs;
  final List<double> topPs;
  final List<double> presencePenalties;
  final List<double> frequencyPenalties;
  final List<double> penaltyDecays;

  SamplerAndPenaltyParams({
    required this.temperatures,
    required this.topKs,
    required this.topPs,
    required this.presencePenalties,
    required this.frequencyPenalties,
    required this.penaltyDecays,
    super.req,
  });
}
