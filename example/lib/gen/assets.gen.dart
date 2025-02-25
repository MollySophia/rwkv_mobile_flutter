/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsConfigGen {
  const $AssetsConfigGen();

  /// Directory path: assets/config/chat
  $AssetsConfigChatGen get chat => const $AssetsConfigChatGen();
}

class $AssetsImgGen {
  const $AssetsImgGen();

  /// Directory path: assets/img/chat
  $AssetsImgChatGen get chat => const $AssetsImgChatGen();
}

class $AssetsModelGen {
  const $AssetsModelGen();

  /// Directory path: assets/model/chat
  $AssetsModelChatGen get chat => const $AssetsModelChatGen();
}

class $AssetsConfigChatGen {
  const $AssetsConfigChatGen();

  /// File path: assets/config/chat/b_rwkv_vocab_v20230424.txt
  String get bRwkvVocabV20230424 =>
      'assets/config/chat/b_rwkv_vocab_v20230424.txt';

  /// File path: assets/config/chat/prompts.en-US.json
  String get promptsEnUS => 'assets/config/chat/prompts.en-US.json';

  /// File path: assets/config/chat/prompts.zh-hans.json
  String get promptsZhHans => 'assets/config/chat/prompts.zh-hans.json';

  /// File path: assets/config/chat/weights.json
  String get weights => 'assets/config/chat/weights.json';

  /// List of all assets
  List<String> get values =>
      [bRwkvVocabV20230424, promptsEnUS, promptsZhHans, weights];
}

class $AssetsImgChatGen {
  const $AssetsImgChatGen();

  /// File path: assets/img/chat/.gitkeep
  String get aGitkeep => 'assets/img/chat/.gitkeep';

  /// File path: assets/img/chat/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/img/chat/logo.png');

  /// File path: assets/img/chat/logo.square.png
  AssetGenImage get logoSquare =>
      const AssetGenImage('assets/img/chat/logo.square.png');

  /// List of all assets
  List<dynamic> get values => [aGitkeep, logo, logoSquare];
}

class $AssetsModelChatGen {
  const $AssetsModelChatGen();

  /// File path: assets/model/chat/.gitkeep
  String get aGitkeep => 'assets/model/chat/.gitkeep';

  /// List of all assets
  List<String> get values => [aGitkeep];
}

class Assets {
  Assets._();

  static const $AssetsConfigGen config = $AssetsConfigGen();
  static const $AssetsImgGen img = $AssetsImgGen();
  static const $AssetsModelGen model = $AssetsModelGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
