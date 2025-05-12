import 'package:rwkv_mobile_flutter/to_rwkv.dart';

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

  TTSOutputFileList({required this.outputFileList});
}

class TTSCFMSteps extends FromRWKV {}
