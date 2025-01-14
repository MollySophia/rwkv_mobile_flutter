abstract class Config {
  static final debuggingChannelRects = false;
  static final localeString = const String.fromEnvironment("locale");
  static final offlineChat = false;
  static final firstPageIsHome = const bool.fromEnvironment("first_page_is_home", defaultValue: true);
  static final firstPageIsChat = const bool.fromEnvironment("first_page_is_chat", defaultValue: false);
  static final firstPageIsOthello = const bool.fromEnvironment("first_page_is_othello", defaultValue: false);
  static final useFakeMessages = const bool.fromEnvironment("use_fake_messages");
  static final enableDebugger = const bool.fromEnvironment("enable_debugger");
}
