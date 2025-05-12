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

class CurrentPrompt extends FromRWKV {}

class EnableReasoning extends FromRWKV {}

class Error extends FromRWKV {
  final String message;

  /// 用于追踪产生该 response 的 request
  final ToRWKV? to;

  Error(this.message, [this.to]) : super(toRWKV: to);
}

class GenerateStart extends FromRWKV {}

class GenerateStop extends FromRWKV {}

class InitRuntimeDone extends FromRWKV {}

class PrefillSpeed extends FromRWKV {}

class ResponseBufferContent extends FromRWKV {}

class SamplerParams extends FromRWKV {}

class SpksNames extends FromRWKV {}

class StreamResponse extends FromRWKV {}

class TTSDone extends FromRWKV {}

class TTSGenerationStart extends FromRWKV {
  final bool start;

  TTSGenerationStart({required this.start, super.toRWKV});
}

class TTSGenerationProgress extends FromRWKV {
  final double overallProgress;
  final double perWavProgress;

  TTSGenerationProgress({required this.overallProgress, required this.perWavProgress, super.toRWKV})
      : assert((overallProgress >= 0 && overallProgress <= 1) || overallProgress == -1, 'overallProgress must be between 0 and 1 or -1'),
        assert((perWavProgress >= 0 && perWavProgress <= 1) || perWavProgress == -1, 'perWavProgress must be between 0 and 1 or -1');
}

class TTSOutputFileList extends FromRWKV {
  final List<String> outputFileList;

  TTSOutputFileList({required this.outputFileList, super.toRWKV});
}

class TTSCFMSteps extends FromRWKV {}
