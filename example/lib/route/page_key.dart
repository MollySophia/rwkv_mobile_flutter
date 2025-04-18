import 'package:zone/config.dart';
import 'package:zone/page/chat.dart';
import 'package:zone/page/file.dart';
import 'package:zone/page/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zone/page/othello.dart';
import 'package:zone/page/textfield_test.dart';

enum PageKey {
  home,
  chat,
  othello,
  file,
  test,
  ;

  String get path => "/$name";

  Widget get scaffold {
    switch (this) {
      case PageKey.home:
        return const PageHome();
      case PageKey.chat:
        return const PageChat();
      case PageKey.othello:
        return const PageOthello();
      case PageKey.file:
        return const PageFile();
      case PageKey.test:
        return const TextFieldTest();
    }
  }

  GoRoute get route => GoRoute(path: path, builder: (_, __) => scaffold);

  static String get initialLocation {
    return first.path;
    // return PageKey.test.path;
  }

  static PageKey get first {
    final pageKey = PageKey.values.byName(Config.firstPage);
    return pageKey;
  }
}
