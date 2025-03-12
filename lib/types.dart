import 'dart:isolate';
import 'dart:ui';

/// Runtime backend of RWKV flutter
enum Backend {
  /// Currently we use it on Android, Windows and Linux
  ///
  /// https://github.com/Tencent/ncnn
  ///
  /// This is suitable for running small puzzle models on various platforms
  /// Not really optimal for larger chat models
  ncnn,

  /// Supports Android, Windows, Linux and macOS (iOS maybe in the future. not used for now)
  llamacpp,

  /// Currently only support iOS and macOS
  ///
  /// https://github.com/cryscan/web-rwkv
  webRwkv,

  /// Qualcomm Neural Network
  ///
  /// Currently only support Qualcomm Snapdragon 8 Gen 3
  qnn,
  ;

  String get asArgument {
    switch (this) {
      case Backend.ncnn:
        return 'ncnn';
      case Backend.webRwkv:
        return 'web-rwkv';
      case Backend.llamacpp:
        return 'llama.cpp';
      case Backend.qnn:
        return 'qnn';
    }
  }
}

enum Command {
  setMaxLength,
  clearStates,
  setGenerationStopToken,
  setPrompt,
  getPrompt,
  setSamplerParams,
  getSamplerParams,
  message,
  generate,
  releaseModel,
  initRuntime,
}

class StartOptions {
  final String modelPath;
  final String tokenizerPath;
  final Backend backend;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  const StartOptions(this.modelPath, this.tokenizerPath, this.backend, this.sendPort, this.rootIsolateToken);
}
