import 'package:zone/launch_arguments.dart';
import 'package:zone/route/page_key.dart';

abstract class Config {
  static final debuggingChannelRects = false;
  static final offlineChat = false;
  static final firstPage = LaunchArgs.firstPage.isNotEmpty ? LaunchArgs.firstPage : PageKey.chat.name;
}
