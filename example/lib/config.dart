import 'dart:ui';

import 'package:zone/route/page_key.dart';

const kBG = Color(0xFFF4F8FF);

abstract class Config {
  // TODO: 根据 args 决定
  static final firstPage = PageKey.chat.name;

  // TODO: @wangce 需要有一个统一的标识来决定当前的 App 正在运行什么逻辑
}
