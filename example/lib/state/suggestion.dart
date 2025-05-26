part of 'p.dart';

class Suggestion {
  final String display;
  final String prompt;

  Suggestion({required this.display, required this.prompt});
}

class SuggestionCategory {
  final String name;
  final List<Suggestion> suggestions;

  const SuggestionCategory({required this.name, required this.suggestions});
}

class SuggestionConfig {
  final List<SuggestionCategory> chat;
  final List<String> tts;
  final List<String> seeReasoningQa;
  final List<String> seeOcr;

  const SuggestionConfig({
    required this.chat,
    required this.tts,
    required this.seeReasoningQa,
    required this.seeOcr,
  });

  static const SuggestionConfig def = SuggestionConfig(
    chat: [],
    tts: [],
    seeReasoningQa: [
      "请向我描述这张图片",
      "Please describe this image for me~",
    ],
    seeOcr: [
      "请向我描述这张图片",
      "Please describe this image for me~",
      "图片上的文字是什么意思？",
      "可以帮我识别一下这张图片上的文字吗？",
      "图片里的文字内容是什么？",
      "这张图片里写了什么？",
      "What does the text in the image mean?",
      "Can you help me recognize the text on this image?",
      "What is the text content in this image?",
      "What is written in this image?",
      "What do you see in this picture?",
    ],
  );

  SuggestionConfig copyWith({
    List<SuggestionCategory>? chat,
    List<String>? tts,
    List<String>? seeReasoningQa,
    List<String>? seeOcr,
  }) {
    return SuggestionConfig(
      chat: chat ?? this.chat,
      tts: tts ?? this.tts,
      seeReasoningQa: seeReasoningQa ?? this.seeReasoningQa,
      seeOcr: seeOcr ?? this.seeOcr,
    );
  }
}

class _Suggestion {
  final config = qs<SuggestionConfig>(SuggestionConfig.def);

  FV loadSuggestions() async {
    final demoType = P.app.demoType.q;
    final isChat = demoType == DemoType.chat;
    if (!isChat && demoType != DemoType.tts) return;
    final shouldUseEn = P.preference.preferredLanguage.q.resolved.locale.languageCode != "zh";

    // TODO load suggestions from server

    const head = "assets/config/chat/suggestions";
    final lang = shouldUseEn ? ".en-US" : ".zh-hans";
    final suffix = kDebugMode ? ".debug" : "";

    final assetPath = "$head$lang$suffix.json";

    final jsonString = await rootBundle.loadString(assetPath);
    final list = HF.list(jsonDecode(jsonString));
    final suggestions = list //
        .map((e) => Suggestion(display: e['display'], prompt: e['prompt']))
        .toList();
    config.q = config.q.copyWith(
      chat: [
        SuggestionCategory(
          name: 'Default',
          suggestions: suggestions,
        ),
      ],
    );
  }
}

/// Private methods
extension _$Suggestion on _Suggestion {
  FV _init() async {
    qq;
  }
}

/// Public methods
extension $Suggestion on _Suggestion {}
