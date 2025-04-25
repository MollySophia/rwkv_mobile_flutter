// ignore_for_file: constant_identifier_names

import 'dart:ui';

enum Language {
  /// None
  none,

  /// English
  en,

  /// Japanese
  ja,

  /// Korean
  ko,

  /// generic simplified Chinese 'zh_Hans'
  zh_Hans,

  /// generic traditional Chinese 'zh_Hant'
  zh_Hant,
  ;

  String? get display => switch (this) {
        none => null,
        en => "English",
        ja => "日本語",
        ko => "한국어",
        zh_Hans => "简体中文",
        zh_Hant => "繁體中文",
      };

  bool get isCJK {
    return name.startsWith('zh') || this == ja || this == ko;
  }


  Language get resolved => switch (this) {
        none => fromSystemLocale(),
        _ => this,
      };

  Locale get locale {
    if (this == none) {
      return PlatformDispatcher.instance.locale;
    }

    final locale = name.split('_');
    final scriptCode = locale.length > 1 ? locale[1] : null;
    final countryCode = locale.length > 2 ? locale[2] : null;

    if (name.startsWith("zh")) {
      return Locale.fromSubtags(
        languageCode: locale[0],
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
    }

    if (name.startsWith("pt")) {
      return Locale.fromSubtags(
        languageCode: locale[0],
        countryCode: locale.length > 1 ? locale[1] : null,
      );
    }
    return Locale(locale[0]);
  }

  static Language fromSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode;
    final scriptCode = systemLocale.scriptCode;
    final countryCode = systemLocale.countryCode;

    // Handle Chinese variants
    if (languageCode == 'zh') {
      if (scriptCode == 'Hant') return Language.zh_Hant;
      if (scriptCode == 'Hans') return Language.zh_Hans;

      // If scriptCode is null, infer from countryCode
      if (countryCode == 'TW' || countryCode == 'HK' || countryCode == 'MO') {
        return Language.zh_Hant;
      }
      return Language.zh_Hans; // default to simplified
    }

    // Exact match to enum name
    for (final lang in Language.values) {
      if (lang.name == languageCode) {
        return lang;
      }
    }

    // Fallback
    return Language.en;
  }
}
