enum WorldType {
  engVisualQAReason,
  engVisualQA,
  engAudioQA,
  chineseASR,
  engASR,
  ;

  String get displayName => switch (this) {
        WorldType.engVisualQA => "English Visual QA",
        WorldType.engVisualQAReason => "English Visual QA Reasoning",
        WorldType.engAudioQA => "English Audio QA",
        WorldType.chineseASR => "Chinese ASR",
        WorldType.engASR => "English ASR",
      };

  String get taskDescription => switch (this) {
        WorldType.engVisualQA => "Visual Question Answering",
        WorldType.engVisualQAReason => "Visual Question Answering (Reasoning)",
        WorldType.engAudioQA => "Audio Question Answering",
        WorldType.chineseASR => "Automatic Speech Recognition",
        WorldType.engASR => "Automatic Speech Recognition",
      };

  bool get isAudioDemo => switch (this) {
        WorldType.engAudioQA || WorldType.chineseASR || WorldType.engASR => true,
        WorldType.engVisualQA || WorldType.engVisualQAReason => false,
      };

  bool get isVisualDemo => switch (this) {
        WorldType.engVisualQA || WorldType.engVisualQAReason => true,
        WorldType.engAudioQA || WorldType.chineseASR || WorldType.engASR => false,
      };

  bool get isReasoning => switch (this) {
        WorldType.engVisualQAReason => true,
        _ => false,
      };
}
