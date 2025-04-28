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
  qnn,

  /// dummy onnxruntime backend string
  onnxruntime,
  ;

  String get asArgument => switch (this) {
        Backend.ncnn => 'ncnn',
        Backend.webRwkv => 'web-rwkv',
        Backend.llamacpp => 'llama.cpp',
        Backend.qnn => 'qnn',
        Backend.onnxruntime => 'onnxruntime',
      };

  static Backend fromString(String value) {
    final toLower = value.toLowerCase();
    if (toLower.contains('ncnn')) {
      return Backend.ncnn;
    } else if (toLower.contains('web') && toLower.contains('rwkv')) {
      return Backend.webRwkv;
    } else if (toLower.contains('llama')) {
      return Backend.llamacpp;
    } else if (toLower.contains('qnn')) {
      return Backend.qnn;
    } else if (toLower.contains('onnxruntime')) {
      return Backend.onnxruntime;
    } else {
      throw Exception('Unknown backend: $value');
    }
  }
}

// TODO: Use it in the future
enum FromRWKV {
  currentPrompt,
  enableReasoning,
  generateStart,
  generateStop,
  initRuntimeDone,
  prefillSpeed,
  response,
  samplerParams,
  streamResponse,
  ;
}

class StartOptions {
  final String modelPath;
  final String tokenizerPath;
  final Backend backend;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  const StartOptions(
    this.modelPath,
    this.tokenizerPath,
    this.backend,
    this.sendPort,
    this.rootIsolateToken,
  );
}
