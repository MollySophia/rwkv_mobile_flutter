import 'package:zone/args.dart';
import 'package:zone/route/page_key.dart';

abstract class Config {
  static final debuggingChannelRects = false;
  static final offlineChat = false;
  static final firstPage = Args.firstPage.isNotEmpty ? Args.firstPage : PageKey.chat.name;
}
