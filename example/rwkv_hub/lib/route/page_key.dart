import 'package:hub/page/chat.dart';
import 'package:hub/page/empty.dart';
import 'package:hub/page/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hub/page/othello.dart';

enum PageKey {
  home,
  chat,
  empty,
  othello;

  String get path => "/$name";

  Widget get widget {
    switch (this) {
      case PageKey.home:
        return const PageHome();
      case PageKey.chat:
        return const PageChat();
      case PageKey.othello:
        return const PageOthello();
      case PageKey.empty:
        return const PageEmpty();
    }
  }

  GoRoute get route => GoRoute(path: path, builder: (_, __) => widget);
}
