sealed class ThinkingMode {
  abstract final String header;
  abstract final bool hasThinkTag;

  const ThinkingMode();

  @override
  String toString() {
    return "ThinkingMode." + runtimeType.toString();
  }

  static ThinkingMode fromString(String? runningMode) {
    if (runningMode == "ThinkingMode.None") return None();
    if (runningMode == "ThinkingMode.Lighting") return Lighting();
    if (runningMode == "ThinkingMode.Free") return Free();
    if (runningMode == "ThinkingMode.PreferChinese") return PreferChinese();
    return None();
  }
}

class Lighting extends ThinkingMode {
  @override
  final String header = '<think>\n</think>';
  @override
  final bool hasThinkTag = true;

  const Lighting();
}

class Free extends ThinkingMode {
  @override
  final String header = '<think';
  @override
  final bool hasThinkTag = true;

  const Free();
}

class PreferChinese extends ThinkingMode {
  @override
  final String header = '<think>嗯';
  @override
  final bool hasThinkTag = true;

  const PreferChinese();
}

class None extends ThinkingMode {
  @override
  String get header => "";
  @override
  final bool hasThinkTag = false;

  const None();
}
