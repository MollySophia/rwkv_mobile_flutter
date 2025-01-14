import 'package:hub/config.dart';
import 'package:hub/func/gen_fake_messages.dart';
import 'package:hub/route/method.dart';
import 'package:hub/route/page_key.dart';
import 'package:hub/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageHome extends ConsumerWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Config.useFakeMessages) {
            genFakeMessages().then((messages) {
              P.chat.messages.u(messages);
            });
          }
          push(PageKey.chat);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
