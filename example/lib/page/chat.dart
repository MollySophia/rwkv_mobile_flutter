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
import 'package:zone/widgets/chat/input.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/chat/suggestions.dart';
import 'package:zone/widgets/chat/visual_empty.dart';
import 'package:zone/widgets/menu.dart';
import 'package:zone/widgets/model_selector.dart';
import 'package:zone/widgets/pager.dart';

class PageChat extends StatefulWidget {
  const PageChat({super.key});

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  @override
  void initState() {
    super.initState();
    P.fileManager.modelSelectorShown.l(_onShowingModelSelectorChanged);
    HF.wait(1000).then((_) {
      final loaded = P.rwkv.loaded.q;
      if (!loaded) {
        P.fileManager.modelSelectorShown.q = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Pager(
      drawer: Menu(),
      child: _Page(),
    );
  }

  @Deprecated("Use ModelSelector.show in the future")
  void _onShowingModelSelectorChanged(bool showing) async {
    if (!showing) return;
    P.fileManager.checkLocal();
    P.suggestion.loadSuggestions();

    if (!Args.disableRemoteConfig) {
      P.app.getConfig().then((_) async {
        await P.fileManager.syncAvailableModels();
        await P.fileManager.checkLocal();
      });
    } else {
      P.fileManager.syncAvailableModels().then((_) {
        P.fileManager.checkLocal();
      });
    }

    HF.wait(250).then((_) {
      P.device.sync();
    });
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: .8,
          maxChildSize: .9,
          expand: false,
          snap: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return ModelSelector(
              scrollController: scrollController,
            );
          },
        );
      },
    );
    P.fileManager.modelSelectorShown.q = false;
  }
}

class _Page extends ConsumerWidget {
  const _Page();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Stack(
        children: [
          List(),
          Empty(),
          VisualEmpty(),
          AudioEmpty(),
          ChatAppBar(),
          _NavigationBarBottomLine(),
          Suggestions(),
          Input(),
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

class List extends ConsumerWidget {
  const List({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: @wangce Use select to improve performance
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
          child: ListView.separated(
            reverse: true,
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
    );
  }
}
