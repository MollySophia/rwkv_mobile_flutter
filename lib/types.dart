import 'dart:isolate';
import 'dart:ui';

enum SocBrand {
  snapdragon,
  unknown;

  static SocBrand fromString(String value) {
    if (value.toLowerCase().contains('snapdragon')) return SocBrand.snapdragon;
    return SocBrand.unknown;
  }
}

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

  /// dummy mnn backend string
  mnn;

  String get asArgument => switch (this) {
    Backend.ncnn => 'ncnn',
    Backend.webRwkv => 'web-rwkv',
    Backend.llamacpp => 'llama.cpp',
    Backend.qnn => 'qnn',
    Backend.mnn => 'mnn',
  };

  static Backend fromString(String value) {
    final toLower = value.toLowerCase();
    if (toLower.contains('ncnn')) return Backend.ncnn;
    if (toLower.contains('web') && toLower.contains('rwkv')) return Backend.webRwkv;
    if (toLower.contains('llama')) return Backend.llamacpp;
    if (toLower.contains('qnn')) return Backend.qnn;
    if (toLower.contains('mnn')) return Backend.mnn;
    throw Exception('Unknown backend: $value');
  }
}

class StartOptions {
  final String modelPath;
  final String tokenizerPath;
  final Backend backend;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  /// 这样就可以得到runtime的地址了，然后再在start isolate的时候加一个runtime地址的参数，正常启动时传0，hot reload后传保存好的地址
  final int latestRuntimeAddress;

  const StartOptions({
    required this.modelPath,
    required this.tokenizerPath,
    required this.backend,
    required this.sendPort,
    required this.rootIsolateToken,
    required this.latestRuntimeAddress,
  });
}
