import 'package:rwkv_mobile_flutter/to_rwkv.dart';

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
  final ToRWKV? toRWKV;

  FromRWKV({this.toRWKV});
}

class CurrentPrompt extends FromRWKV {
  final String prompt;

  CurrentPrompt({required this.prompt, super.toRWKV});
}

class EnableReasoning extends FromRWKV {}

class Error extends FromRWKV {
  final String message;

  /// 用于追踪产生该 response 的 request
  final ToRWKV? to;
  final int? retVal;

  Error(this.message, [this.to, this.retVal]) : super(toRWKV: to);
}

class GenerateStart extends FromRWKV {
  GenerateStart({super.toRWKV});
}

class GenerateStop extends FromRWKV {
  final String? error;

  GenerateStop({this.error, super.toRWKV});
}

/// 重新加载新的 weights 时, 会调用该 response
class ReInitSteps extends FromRWKV {
  final bool done;
  final bool? success;
  final String? error;
  final String? step;

  ReInitSteps({
    required this.done,
    this.success,
    this.error,
    this.step,
    super.toRWKV,
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
    super.toRWKV,
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
    super.toRWKV,
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
    super.toRWKV,
  });
}

class LoadedModelPathByID extends FromRWKV {
  final String loadedModelPath;
  final int modelID;
  LoadedModelPathByID({required this.loadedModelPath, required this.modelID, super.toRWKV});
}

class LoadedModelIDs extends FromRWKV {
  final List<int> loadedModelIDs;
  LoadedModelIDs({required this.loadedModelIDs, super.toRWKV});
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
    super.toRWKV,
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
    super.toRWKV,
  });
}

class TTSGenerationStart extends FromRWKV {
  final bool start;

  TTSGenerationStart({required this.start, super.toRWKV});
}

@Deprecated('Use TTSResult instead')
class TTSGenerationProgress extends FromRWKV {
  final double overallProgress;
  final double perWavProgress;

  TTSGenerationProgress({required this.overallProgress, required this.perWavProgress, super.toRWKV});
}

@Deprecated('Use TTSResult instead')
class TTSOutputFileList extends FromRWKV {
  final List<String> outputFileList;

  TTSOutputFileList({required this.outputFileList, super.toRWKV});
}

/// 调用 [GetTTSGenerationProgress] 或 [GetTTSOutputFileList] 后，返回的结果
///
/// 调用 [StartTTS] 时，response 会被重置
@Deprecated('Use TTSStreamingBuffer instead')
class TTSResult extends FromRWKV {
  /// 每个文件的路径
  ///
  /// e.g. ["/path/to/file.0.wav", "/path/to/file.1.wav", ...]
  ///
  /// 每次重新调用 [StartTTS] 时，该值会重置为 `[""]` 或 `[]`
  final List<String> filePaths;

  /// 每个文件的进度
  ///
  /// 0.0 ~ 1.0
  ///
  /// e.g. [1.0, 1.0, 1.0, 0.65]
  ///
  /// 每次重新调用 [StartTTS] 时，该值会重置为 `[0.0]` 或 `[]`
  final List<double> perWavProgress;

  /// 整体进度
  ///
  /// 可能值 0.0 ~ 1.0
  ///
  /// - 0.0 表示次次最新的一次 [StartTTS] 还没有产出, 或者, 还没有调用过 [StartTTS]
  /// - 1.0 表示次次最新的一次 [StartTTS] 已经完成了
  ///
  /// 每次重新调用 [StartTTS] 时，该值会重置为 0.0
  final double overallProgress;

  TTSResult({
    required this.filePaths,
    required this.perWavProgress,
    required this.overallProgress,
    super.toRWKV,
  });
}

class TTSCFMSteps extends FromRWKV {}

@Deprecated("Backend can't use this")
class LatestRuntimeAddress extends FromRWKV {
  final int latestRuntimeAddress;

  LatestRuntimeAddress({required this.latestRuntimeAddress, super.toRWKV});
}

class RuntimeLog extends FromRWKV {
  final String runtimeLog;

  RuntimeLog({required this.runtimeLog, super.toRWKV});
}

class IsGenerating extends FromRWKV {
  final bool isGenerating;

  IsGenerating({required this.isGenerating, super.toRWKV});
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
    super.toRWKV,
  });
}
