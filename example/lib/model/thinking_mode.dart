sealed class ThinkingMode {
  abstract final String header;
  abstract final bool isReasoning;

  @override
  String toString() {
    return "ThinkingMode." + runtimeType.toString() + "\n" + header + "\n" + "isReasoning: " + isReasoning.toString();
  }
}

class Lighting extends ThinkingMode {
  @override
  final String header = '<think>\n</think>';
  @override
  final bool isReasoning = true;
}

class Free extends ThinkingMode {
  @override
  final String header = '<think';
  @override
  final bool isReasoning = true;
}

class PreferChinese extends ThinkingMode {
  @override
  final String header = '<think>嗯';
  @override
  final bool isReasoning = true;
}

class None extends ThinkingMode {
  @override
  String get header => throw UnsupportedError("None doen't have a header");
  @override
  final bool isReasoning = false;
}
