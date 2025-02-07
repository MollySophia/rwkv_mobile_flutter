import 'package:halo/halo.dart';
import 'package:zone/func/gen_fake_messages.dart';
import 'package:zone/launch_arguments.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/page_key.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageHome extends ConsumerWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: T("RWKV Zone"),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              push(PageKey.othello);
            },
            child: Text("RWKV Othello"),
          ),
          TextButton(
            onPressed: () {
              push(PageKey.chat);
            },
            child: Text("RWKV Chat v7"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (LaunchArgs.useFakeMessages) {
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
