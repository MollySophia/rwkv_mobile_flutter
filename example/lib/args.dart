abstract class Args {
  static const enableChatDebugger = bool.fromEnvironment("enableChatDebugger");
  static const enableOthelloDebugger = bool.fromEnvironment("enable_othello_debugger");
  static const othelloTestCase = int.fromEnvironment("othello_test_case", defaultValue: -1);
  static const demoType = String.fromEnvironment("demoType", defaultValue: "__chat__");
  static const isChat = demoType == "__chat__";
  static const maxTokens = int.fromEnvironment("maxTokens", defaultValue: -1);
  static const disableRemoteConfig = bool.fromEnvironment("disableRemoteConfig", defaultValue: false);
}
