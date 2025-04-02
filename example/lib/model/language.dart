// ignore_for_file: constant_identifier_names

import 'dart:ui';

enum Language {
  en,

  ja,

  ko,

  /// generic simplified Chinese 'zh_Hans'
  zh_Hans,

  /// generic traditional Chinese 'zh_Hant'
  zh_Hant,
  ;

  bool get isCJK {
    return name.startsWith('zh') || this == ja || this == ko;
  }

  Locale get locale {
    final locale = name.split('_');

    if (name.startsWith("zh")) {
      return Locale.fromSubtags(
        languageCode: locale[0],
        scriptCode: locale.length > 1 ? locale[1] : null,
        countryCode: locale.length > 2 ? locale[2] : null,
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
}
