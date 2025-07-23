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
}

class ClearStates extends ToRWKV {}

class DumpLog extends ToRWKV {}

class GenerateAsync extends ToRWKV {
  final String prompt;

  GenerateAsync(this.prompt);
}

class SudokuOthelloGenerate extends ToRWKV {
  final String prompt;
  final bool decodeStream;
  final bool wantRawJSON;

  SudokuOthelloGenerate(this.prompt, {this.decodeStream = true, this.wantRawJSON = true});

  static const responseType = StreamResponse;
}

class GetIsGenerating extends ToRWKV {}

class GetPrefillAndDecodeSpeed extends ToRWKV {
  static const responseType = Speed;
}

class GetPrompt extends ToRWKV {}

@Deprecated('Use sparktts instead')
class GetTTSGenerationProgress extends ToRWKV {
  static const responseType = TTSGenerationProgress;
}

/// 查询本次"已经"生成的wav文件名列表
///
/// - TODO: 每次重新调用生成语音会置空吗? @WangCe
/// - TODO: 在单次生成中会不断变化吗? @WangCe
@Deprecated('Use sparktts instead')
class GetTTSOutputFileList extends ToRWKV {
  // TODO: 其实改成类似于 protoBuffer 那种形式也行
  static const responseType = TTSOutputFileList;
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

  GetResponseBufferContent([this.messages = const []]);

  static const responseType = ResponseBufferContent;
}

/// stop之后responseBufferContent还保留着，然后resume之后responseBufferContent会先短暂清空，然后变成stop前已经生成了的内容并接着生成
class Stop extends ToRWKV {}

class GetResponseBufferIds extends ToRWKV {}

class GetSamplerParams extends ToRWKV {}

class ReInitRuntime extends ToRWKV {
  final String modelPath;
  final Backend backend;
  final String tokenizerPath;
  @Deprecated("Backend can't use this")
  final int latestRuntimeAddress;

  static const responseType = ReInitSteps;

  ReInitRuntime({
    required this.modelPath,
    required this.backend,
    required this.tokenizerPath,
    required this.latestRuntimeAddress,
  });
}

@Deprecated('Use sparktts instead')
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

  LoadTTSTextNormalizer(this.fstPath);
}

class LoadVisionEncoder extends ToRWKV {
  final String encoderPath;

  LoadVisionEncoder(this.encoderPath);
}

class LoadVisionEncoderAndAdapter extends ToRWKV {
  final String encoderPath;
  final String adapterPath;

  LoadVisionEncoderAndAdapter(this.encoderPath, this.adapterPath);
}

class LoadWhisperEncoder extends ToRWKV {
  final String encoderPath;

  LoadWhisperEncoder(this.encoderPath);
}

class ReleaseModel extends ToRWKV {}

class ReleaseTTSModels extends ToRWKV {}

class ReleaseVisionEncoder extends ToRWKV {}

class ReleaseWhisperEncoder extends ToRWKV {}

class ChatAsync extends ToRWKV {
  final List<String> messages;
  final bool reasoning;

  ChatAsync(this.messages, {required this.reasoning});
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

  StartTTS({
    required this.ttsText,
    required this.instructionText,
    required this.promptWavPath,
    required this.outputWavPath,
    required this.promptSpeechText,
  });
}

class SetAudioPrompt extends ToRWKV {
  final String audioPathPtr;

  SetAudioPrompt(this.audioPathPtr);
}

class SetBosToken extends ToRWKV {
  final String bosToken;

  SetBosToken(this.bosToken);
}

class SetEosToken extends ToRWKV {
  final String eosToken;

  SetEosToken(this.eosToken);
}

class SetGenerationStopToken extends ToRWKV {
  final int stopToken;

  SetGenerationStopToken(this.stopToken);
}

class SetMaxLength extends ToRWKV {
  final int maxLength;

  SetMaxLength(this.maxLength);
}

class SetPrompt extends ToRWKV {
  final String prompt;

  SetPrompt(this.prompt);
}

class SetSamplerParams extends ToRWKV {
  final num temperature;
  final num topK;
  final num topP;
  final num presencePenalty;
  final num frequencyPenalty;
  final num penaltyDecay;

  SetSamplerParams({
    required this.temperature,
    required this.topK,
    required this.topP,
    required this.presencePenalty,
    required this.frequencyPenalty,
    required this.penaltyDecay,
  });
}

/// decoder steps 的 api
///
/// 范围3～10吧，越高越慢越精细，可以做成参数
///
/// args['cfmSteps'] as int
@Deprecated('Use sparktts instead')
class SetTTSCFMSteps extends ToRWKV {
  final int cfmSteps;

  SetTTSCFMSteps(this.cfmSteps);
}

class SetThinkingToken extends ToRWKV {
  final String thinkingToken;

  SetThinkingToken(this.thinkingToken);
}

class SetTokenBanned extends ToRWKV {
  final List<int> tokenBanned;

  SetTokenBanned(this.tokenBanned);
}

class SetUserRole extends ToRWKV {
  final String userRole;

  SetUserRole(this.userRole);
}

class SetVisionPrompt extends ToRWKV {
  final String imagePathPtr;

  SetVisionPrompt(this.imagePathPtr);
}

class GetLatestRuntimeAddress extends ToRWKV {}

// rwkvmobile_runtime_set_response_role
// rwkvmobile_runtime_set_user_role

/// 把user role设置成English
///
/// response role设置成Chinese 然后像聊天一样用户输入英文就行
///
/// 原本的格式是User: xxx\n\nAssistant:，现在是English: xxx\n\nChinese:，可以直接换
class SetResponseRole extends ToRWKV {
  final String responseRole;

  SetResponseRole([this.responseRole = 'Assistant']);
}
