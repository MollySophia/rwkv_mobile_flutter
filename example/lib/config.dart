abstract class Config {
  static final debuggingChannelRects = false;
  static final localeString = const String.fromEnvironment("locale");
  static final offlineChat = false;
  static final showHome = const bool.fromEnvironment("show_home");
  static final useFakeMessages = const bool.fromEnvironment("use_fake_messages");
}
