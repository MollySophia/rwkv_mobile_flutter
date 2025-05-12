import 'package:rwkv_mobile_flutter/from_rwkv.dart';

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
}

class ClearStates extends ToRWKV {}

class DumpLog extends ToRWKV {}

class GenerateAsync extends ToRWKV {}

class Generate extends ToRWKV {}

class GetEnableReasoning extends ToRWKV {}

class GetIsGenerating extends ToRWKV {}

class GetPrefillAndDecodeSpeed extends ToRWKV {}

class GetPrompt extends ToRWKV {}

class GetTTSGenerationProgress extends ToRWKV {
  static const responseType = TTSGenerationProgress;
}

/// 查询本次"已经"生成的wav文件名列表
///
/// - 每次重新调用生成语音会置空吗?
/// - 在单次生成中会不断变化吗?
class GetTTSOutputFileList extends ToRWKV {
  // TODO: 其实改成类似于 protoBuffer 那种形式也行
  static const responseType = TTSOutputFileList;
}

/// stop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
class GetResponseBufferContent extends ToRWKV {}

class GetResponseBufferIds extends ToRWKV {}

class GetSamplerParams extends ToRWKV {}

class InitRuntime extends ToRWKV {}

class LoadTTSModels extends ToRWKV {
  final String campPlusPath;
  final String flowDecoderEstimatorPath;
  final String flowEncoderPath;
  final String hiftGeneratorPath;
  final String speechTokenizerPath;
  final String ttsTokenizerPath;

  LoadTTSModels({
    required this.campPlusPath,
    required this.flowDecoderEstimatorPath,
    required this.flowEncoderPath,
    required this.hiftGeneratorPath,
    required this.speechTokenizerPath,
    required this.ttsTokenizerPath,
  });
}

class LoadTTSTextNormalizer extends ToRWKV {
  final String fstPath;

  LoadTTSTextNormalizer({required this.fstPath});
}

class LoadVisionEncoder extends ToRWKV {}

class LoadWhisperEncoder extends ToRWKV {}

class ReleaseModel extends ToRWKV {}

class ReleaseTTSModels extends ToRWKV {}

class ReleaseVisionEncoder extends ToRWKV {}

class ReleaseWhisperEncoder extends ToRWKV {}

class RunChatAsync extends ToRWKV {}

@Deprecated("use RequestRunTTSAsync instead")
class RunTTS extends ToRWKV {}

/// 执行 TTS 任务
///
/// 发送消息给 ffi thread
///
/// 在 cpp side 开启新线程
///
/// 通过轮训的方式获取 response
class RunTTSAsync extends ToRWKV {
  final String ttsText;
  final String instructionText;
  final String promptWavPath;
  final String outputWavPath;
  final String promptSpeechText;

  RunTTSAsync({
    required this.ttsText,
    required this.instructionText,
    required this.promptWavPath,
    required this.outputWavPath,
    required this.promptSpeechText,
  });
}

class SetAudioPrompt extends ToRWKV {}

class SetBosToken extends ToRWKV {}

class SetEnableReasoning extends ToRWKV {}

class SetEosToken extends ToRWKV {}

class SetGenerationStopToken extends ToRWKV {}

class SetMaxLength extends ToRWKV {}

class SetPrompt extends ToRWKV {}

class SetSamplerParams extends ToRWKV {}

/// decoder steps 的 api
///
/// 范围3～10吧，越高越慢越精细，可以做成参数
///
/// 默认值现在是5
///
/// args['cfmSteps'] as int
class SetTTSCFMSteps extends ToRWKV {
  final int cfmSteps;

  SetTTSCFMSteps({required this.cfmSteps});
}

class SetThinkingToken extends ToRWKV {}

class SetTokenBanned extends ToRWKV {}

class SetUserRole extends ToRWKV {}

class SetVisionPrompt extends ToRWKV {}

/// stop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
class Stop extends ToRWKV {}
