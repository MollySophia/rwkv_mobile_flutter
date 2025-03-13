abstract class Args {
  static const localeString = String.fromEnvironment("locale");
  static const enableChatDebugger = bool.fromEnvironment("enableChatDebugger");
  static const enableOthelloDebugger = bool.fromEnvironment("enable_othello_debugger");
  static const othelloTestCase = int.fromEnvironment("othello_test_case", defaultValue: -1);
  static const demoType = String.fromEnvironment("demoType", defaultValue: "chat");
}
