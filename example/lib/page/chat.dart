// ignore: unused_import
import 'dart:developer';

import 'package:halo_state/halo_state.dart';
import 'package:zone/args.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/model/world_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/app_bar.dart';
import 'package:zone/widgets/chat/audio_empty.dart';
import 'package:zone/widgets/chat/audio_input.dart';
import 'package:zone/widgets/chat/empty.dart';
import 'package:zone/widgets/chat/bottom_bar.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/chat/suggestions.dart';
import 'package:zone/widgets/chat/visual_empty.dart';
import 'package:zone/widgets/menu.dart';
import 'package:zone/widgets/pager.dart';
import 'package:zone/widgets/screenshot.dart';

class PageChat extends ConsumerWidget {
  const PageChat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Screenshot(
      child: const Pager(
        drawer: Menu(),
        child: _Page(),
      ),
    );
  }
}

class _Page extends ConsumerWidget {
  const _Page();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: kW,
      body: Stack(
        children: [
          List(),
          Empty(),
          VisualEmpty(),
          AudioEmpty(),
          ChatAppBar(),
          _NavigationBarBottomLine(),
          Suggestions(),
          BottomBar(),
          AudioInput(),
        ],
      ),
    );
  }
}

class _NavigationBarBottomLine extends ConsumerWidget {
  const _NavigationBarBottomLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final kB = ref.watch(P.app.qb);
    return Positioned(
      top: paddingTop + kToolbarHeight,
      left: 0,
      right: 0,
      height: .5,
      child: C(
        height: kToolbarHeight,
        color: kB.q(.1),
      ),
    );
  }
}

final GlobalKey keyChatList = GlobalKey(debugLabel: "chatListShot");

class List extends ConsumerWidget {
  const List({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(P.chat.messages);
    final paddingTop = ref.watch(P.app.paddingTop);
    final paddingLeft = ref.watch(P.app.paddingLeft);
    final paddingRight = ref.watch(P.app.paddingRight);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final demoType = ref.watch(P.app.demoType);

    double top = paddingTop + kToolbarHeight + 4;
    double bottom = inputHeight + 12;
    double scrollBarBottom = inputHeight + 4;

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);

    switch (currentWorldType) {
      case null:
        break;
      case WorldType.engVisualQA:
      case WorldType.qa:
      case WorldType.reasoningQA:
      case WorldType.ocr:
        if (messages.length == 1 && messages.first.type == model.MessageType.userImage) {
          bottom += 46;
        }
      case WorldType.engAudioQA:
        bottom += 16;
        break;
      case WorldType.chineseASR:
        bottom += 16;
        break;
      case WorldType.engASR:
        bottom += 16;
        break;
    }

    switch (demoType) {
      case DemoType.chat:
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.world:
        break;
      case DemoType.tts:
        bottom += Suggestions.defaultHeight;
        scrollBarBottom += Suggestions.defaultHeight;
    }
    final kB = ref.watch(P.app.qb);

    // return Positioned.fill(child: C());

    return Positioned.fill(
      child: GD(
        onTap: P.chat.onTapMessageList,
        child: RawScrollbar(
          radius: 100.rr,
          thickness: 4,
          thumbColor: kB.q(.4),
          padding: EI.o(
            r: 4,
            b: scrollBarBottom,
            t: top,
          ),
          controller: P.chat.scrollController,
          child: ScrollShotArea(
            repaintBoundaryColor: kW,
            key: keyChatList,
            controller: P.chat.scrollController,
            child: ListView.separated(
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EI.o(t: top, b: bottom, l: paddingLeft, r: paddingRight),
              controller: P.chat.scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final finalIndex = messages.length - 1 - index;
                final msg = messages[finalIndex];
                return Message(msg, finalIndex);
              },
              separatorBuilder: (context, index) {
                return const SB(height: 15);
              },
            ),
          ),
        ),
      ),
    );
  }
}
