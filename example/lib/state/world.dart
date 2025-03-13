part of 'p.dart';

enum WorldType {
  engVisualQA,
  engAudioQA,
  chineseASR,
}

class _World {
  late final type = _gs(WorldType.engVisualQA);
  late final imagePath = _gsn<String>();
}

/// Public methods
extension $World on _World {}

/// Private methods
extension _$World on _World {
  FV _init() async {
    logTrace();
  }
}
