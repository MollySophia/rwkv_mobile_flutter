// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/pager.dart';

class ConversationList extends ConsumerWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(P.conversation.conversations);

    if (conversations.isEmpty) {
      return const _Empty();
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return C(
          decoration: BD(),
          child: Text(conversation.id.toString()),
        );
      },
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty();

  void _onPressed() {
    Pager.toggle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Co(
      m: MAA.center,
      c: CAA.stretch,
      children: [
        IconButton(
          onPressed: _onPressed,
          icon: Co(
            mainAxisSize: MainAxisSize.min,
            c: CAA.center,
            children: [
              Icon(Icons.add),
              T("New Chat", s: TS(s: 20)),
              T("Create a new one by clicking the button above.", s: TS(s: 10, c: kB.wo(0.5))),
            ],
          ),
        ),
      ],
    );
  }
}
