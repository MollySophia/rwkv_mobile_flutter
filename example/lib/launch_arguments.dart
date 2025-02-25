abstract class LaunchArgs {
  static const localeString = String.fromEnvironment("locale");
  static const useFakeMessages = bool.fromEnvironment("use_fake_messages");
  static const enableChatDebugger = bool.fromEnvironment("enableChatDebugger");
  static const enableOthelloDebugger = bool.fromEnvironment("enable_othello_debugger");
  static const hideDebugBanner = bool.fromEnvironment("hide_debug_banner", defaultValue: true);
  static const othelloTestCase = int.fromEnvironment("othello_test_case", defaultValue: -1);
  static const firstPage = String.fromEnvironment("first_page");
}
