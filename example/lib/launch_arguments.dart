abstract class LaunchArgs {
  static final localeString = const String.fromEnvironment("locale");
  static final firstPageIsHome = const bool.fromEnvironment("first_page_is_home", defaultValue: true);
  static final firstPageIsChat = const bool.fromEnvironment("first_page_is_chat", defaultValue: false);
  // TODO: @halo change it when chat integration is done
  static final firstPageIsOthello = const bool.fromEnvironment("first_page_is_othello", defaultValue: false);
  static final useFakeMessages = const bool.fromEnvironment("use_fake_messages");
  static final enableChatDebugger = const bool.fromEnvironment("enable_chat_debugger");
  static final enableOthelloDebugger = const bool.fromEnvironment("enable_othello_debugger");
  static final hideDebugBanner = const bool.fromEnvironment("hide_debug_banner");
  static final othelloTestCase = const int.fromEnvironment("othello_test_case", defaultValue: -1);
}
