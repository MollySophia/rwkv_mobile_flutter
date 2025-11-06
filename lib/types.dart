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
  mnn,

  /// Apple CoreML
  coreml,

  /// Apple MLX
  mlx;

  String get asArgument => switch (this) {
    Backend.ncnn => 'ncnn',
    Backend.webRwkv => 'web-rwkv',
    Backend.llamacpp => 'llama.cpp',
    Backend.qnn => 'qnn',
    Backend.mnn => 'mnn',
    Backend.coreml => 'coreml',
    Backend.mlx => 'mlx',
  };

  static Backend fromString(String value) {
    final toLower = value.toLowerCase();
    if (toLower.contains('ncnn')) return Backend.ncnn;
    if (toLower.contains('web') && toLower.contains('rwkv')) return Backend.webRwkv;
    if (toLower.contains('llama')) return Backend.llamacpp;
    if (toLower.contains('qnn')) return Backend.qnn;
    if (toLower.contains('mnn')) return Backend.mnn;
    if (toLower.contains('coreml')) return Backend.coreml;
    if (toLower.contains('mlx')) return Backend.mlx;
    throw Exception('Unknown backend: $value');
  }
}

class StartOptions {
  final String modelPath;
  final String tokenizerPath;
  final Backend backend;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  const StartOptions({
    required this.modelPath,
    required this.tokenizerPath,
    required this.backend,
    required this.sendPort,
    required this.rootIsolateToken,
  });
}

enum TTSPropertyAge {
  child,
  teenager,
  youthAdult,
  middleAged,
  elderly;

  String get asArgument => switch (this) {
    TTSPropertyAge.child => 'child',
    TTSPropertyAge.teenager => 'teenager',
    TTSPropertyAge.youthAdult => 'youth-adult',
    TTSPropertyAge.middleAged => 'middle-aged',
    TTSPropertyAge.elderly => 'elderly',
  };
}

enum TTSPropertyGender {
  male,
  female;

  String get asArgument => switch (this) {
    TTSPropertyGender.male => 'male',
    TTSPropertyGender.female => 'female',
  };
}

enum TTSPropertyEmotion {
  unknown,
  neutral,
  angry,
  happy,
  sad,
  fearful,
  disgusted,
  surprised,
  sarcastic,
  excited,
  sleepy,
  confused,
  emphasis,
  laughing,
  singing,
  worried,
  anxious,
  noAgreement,
  apologetic,
  concerned,
  enunciated,
  assertive,
  encouraging,
  contemptuous;

  String get asArgument => switch (this) {
    TTSPropertyEmotion.unknown => 'UNKNOWN',
    TTSPropertyEmotion.neutral => 'NEUTRAL',
    TTSPropertyEmotion.angry => 'ANGRY',
    TTSPropertyEmotion.happy => 'HAPPY',
    TTSPropertyEmotion.sad => 'SAD',
    TTSPropertyEmotion.fearful => 'FEARFUL',
    TTSPropertyEmotion.disgusted => 'DISGUSTED',
    TTSPropertyEmotion.surprised => 'SURPRISED',
    TTSPropertyEmotion.sarcastic => 'SARCASTIC',
    TTSPropertyEmotion.excited => 'EXCITED',
    TTSPropertyEmotion.sleepy => 'SLEEPY',
    TTSPropertyEmotion.confused => 'CONFUSED',
    TTSPropertyEmotion.emphasis => 'EMPHASIS',
    TTSPropertyEmotion.laughing => 'LAUGHING',
    TTSPropertyEmotion.singing => 'SINGING',
    TTSPropertyEmotion.worried => 'WORRIED',
    TTSPropertyEmotion.anxious => 'ANXIOUS',
    TTSPropertyEmotion.noAgreement => 'NO-AGREEMENT',
    TTSPropertyEmotion.apologetic => 'APOLOGETIC',
    TTSPropertyEmotion.concerned => 'CONCERNED',
    TTSPropertyEmotion.enunciated => 'ENUNCIATED',
    TTSPropertyEmotion.assertive => 'ASSERTIVE',
    TTSPropertyEmotion.encouraging => 'ENCOURAGING',
    TTSPropertyEmotion.contemptuous => 'CONTEMPT',
  };
}

enum TTSPropertySpeed {
  verySlow,
  slow,
  medium,
  fast,
  veryFast;

  String get asArgument => switch (this) {
    TTSPropertySpeed.verySlow => 'very_slow',
    TTSPropertySpeed.slow => 'slow',
    TTSPropertySpeed.medium => 'medium',
    TTSPropertySpeed.fast => 'fast',
    TTSPropertySpeed.veryFast => 'very_fast',
  };
}

enum TTSPropertyPitch {
  lowPitch,
  mediumPitch,
  highPitch,
  veryHighPitch;

  String get asArgument => switch (this) {
    TTSPropertyPitch.lowPitch => 'low_pitch',
    TTSPropertyPitch.mediumPitch => 'medium_pitch',
    TTSPropertyPitch.highPitch => 'high_pitch',
    TTSPropertyPitch.veryHighPitch => 'very_high_pitch',
  };
}
