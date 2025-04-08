enum WorldType {
  engVisualQAReason,
  engVisualQA,
  engAudioQA,
  chineseASR,
  engASR,
  ;

  String get displayName {
    switch (this) {
      case WorldType.engVisualQA:
        return "English Visual QA";
      case WorldType.engVisualQAReason:
        return "English Visual QA Reasoning";
      case WorldType.engAudioQA:
        return "English Audio QA";
      case WorldType.chineseASR:
        return "Chinese ASR";
      case WorldType.engASR:
        return "English ASR";
    }
  }

  String get taskDescription {
    switch (this) {
      case WorldType.engVisualQA:
        return "Visual Question Answering";
      case WorldType.engVisualQAReason:
        return "Visual Question Answering (Reasoning)";
      case WorldType.engAudioQA:
        return "Audio Question Answering";
      case WorldType.chineseASR:
        return "Automatic Speech Recognition";
      case WorldType.engASR:
        return "Automatic Speech Recognition";
    }
  }

  // TODO: Use it in the future @wangce
  bool get isAudioDemo {
    switch (this) {
      case WorldType.engAudioQA:
      case WorldType.chineseASR:
      case WorldType.engASR:
        return true;
      case WorldType.engVisualQA:
      case WorldType.engVisualQAReason:
        return false;
    }
  }

  // TODO: Use it in the future @wangce
  bool get isVisualDemo {
    switch (this) {
      case WorldType.engVisualQA:
      case WorldType.engVisualQAReason:
        return true;
      case WorldType.engAudioQA:
      case WorldType.chineseASR:
      case WorldType.engASR:
        return false;
    }
  }

  bool get isReasoning => switch (this) {
        WorldType.engVisualQAReason => true,
        _ => false,
      };
}
