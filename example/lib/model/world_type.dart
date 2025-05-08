enum WorldType {
  engVisualQAReason,
  visualQA,
  engVisualQA,
  engAudioQA,
  chineseASR,
  engASR,
  ;

  String get displayName => switch (this) {
        WorldType.engVisualQAReason => "🇺🇸 English Visual QA Reasoning",
        WorldType.visualQA => "Visual QA (🇨🇳 Chinese & 🇺🇸 English)",
        WorldType.engVisualQA => "Visual QA (🇺🇸 English)",
        WorldType.engAudioQA => "Audio QA (🇺🇸 English)",
        WorldType.chineseASR => "ASR (🇨🇳 Chinese)",
        WorldType.engASR => "ASR (🇺🇸 English)",
      };

  String get taskDescription => switch (this) {
        WorldType.engVisualQA => "Visual Question Answering",
        WorldType.visualQA => "Visual Question Answering",
        WorldType.engVisualQAReason => "Visual Question Answering (Reasoning)",
        WorldType.engAudioQA => "Audio Question Answering",
        WorldType.chineseASR => "Automatic Speech Recognition",
        WorldType.engASR => "Automatic Speech Recognition",
      };

  bool get isAudioDemo => switch (this) {
        WorldType.engAudioQA || WorldType.chineseASR || WorldType.engASR => true,
        WorldType.engVisualQA || WorldType.engVisualQAReason || WorldType.visualQA => false,
      };

  bool get isVisualDemo => switch (this) {
        WorldType.engVisualQA || WorldType.engVisualQAReason || WorldType.visualQA => true,
        WorldType.engAudioQA || WorldType.chineseASR || WorldType.engASR => false,
      };

  bool get isReasoning => switch (this) {
        WorldType.engVisualQAReason => true,
        _ => false,
      };

  bool get isVisual => switch (this) {
        WorldType.engVisualQA || WorldType.engVisualQAReason || WorldType.visualQA => true,
        _ => false,
      };
}
