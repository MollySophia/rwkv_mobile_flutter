import 'package:chat/page/chat.dart';
import 'package:chat/page/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum PageKey {
  home,
  chat;

  String get path => "/$name";

  Widget get widget {
    switch (this) {
      case PageKey.home:
        return const PageHome();
      case PageKey.chat:
        return const PageChat();
    }
  }

  GoRoute get route => GoRoute(path: path, builder: (_, __) => widget);
}
