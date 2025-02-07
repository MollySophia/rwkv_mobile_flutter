import 'package:halo/halo.dart';
import 'package:zone/func/gen_fake_messages.dart';
import 'package:zone/gen/l10n.dart';
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
        title: const T("RWKV Zone"),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              push(PageKey.othello);
            },
            child: T(S.current.othello_title),
          ),
          TextButton(
            onPressed: () {
              push(PageKey.chat);
            },
            child: T(S.current.chat_title),
          ),
        ],
      ),
    );
  }
}
