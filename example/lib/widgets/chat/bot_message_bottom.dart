// ignore: unused_import

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/config.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/branch_switcher.dart';

class BotMessageBottom extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const BotMessageBottom(this.msg, this.index, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (msg.isMine) return const SizedBox.shrink();
    final demoType = ref.watch(P.app.demoType);
    if (demoType == DemoType.tts) return const SizedBox.shrink();

    final receiveId = ref.watch(P.chat.receiveId);

    final paused = msg.paused;

    final changing = msg.changing;

    final primaryColor = Theme.of(context).colorScheme.primary;

    final worldType = ref.watch(P.rwkv.currentWorldType);

    bool showBotEditButton = true;
    bool showBotCopyButton = true;
    bool showBotRegenerateButton = true;
    bool showDownloadButton = false;
    bool showResumeButton = true;

    switch (worldType) {
      case null:
        break;
      default:
        showBotEditButton = false;
        showBotCopyButton = false;
    }

    switch (demoType) {
      case DemoType.tts:
        showBotEditButton = false;
        showBotCopyButton = false;
        showBotRegenerateButton = false;
        showDownloadButton = true;
        showResumeButton = false;
      default:
        break;
    }

    if (msg.isSensitive) {
      showResumeButton = false;
      showBotCopyButton = false;
      showBotEditButton = false;
    }

    return Ro(
      m: MAA.start,
      children: [
        if (Config.enableChain) BranchSwitcher(msg, index),
        if (changing)
          Padding(
            padding: const EI.o(v: 12, r: 4),
            child: TweenAnimationBuilder(
              tween: Tween(begin: .0, end: 1.0),
              duration: const Duration(milliseconds: 1000000000),
              builder: (context, value, child) => Transform.rotate(
                angle: value * 2 * math.pi * 1000000,
                child: child,
              ),
              child: Icon(
                Icons.hourglass_top,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
        if (showBotCopyButton)
          GD(
            onTap: _onCopyPressed,
            child: Padding(
              padding: const EI.o(v: 12, r: 4, l: 4),
              child: Icon(
                Icons.copy,
                color: primaryColor.q(.8),
                size: 20,
              ),
            ),
          ),
        if (showBotRegenerateButton)
          GD(
            onTap: _onRegeneratePressed,
            child: Padding(
              padding: const EI.o(v: 12, r: 4, l: 4),
              child: Icon(
                Icons.refresh,
                color: primaryColor.q(.8),
                size: 20,
              ),
            ),
          ),
        if (showBotEditButton)
          GD(
            onTap: _onBotEditPressed,
            child: Padding(
              padding: const EI.o(v: 12, r: 4, l: 4),
              child: Icon(
                Icons.edit,
                color: primaryColor.q(.8),
                size: 20,
              ),
            ),
          ),
        if (showResumeButton && paused && receiveId == msg.id) const Spacer(),
        if (showResumeButton && paused && receiveId == msg.id)
          GD(
            onTap: _onResumePressed,
            child: C(
              padding: const EI.o(v: 9, l: 12),
              child: C(
                padding: const EI.s(v: 1, h: 8),
                decoration: BD(
                  color: kC,
                  border: Border.all(color: primaryColor.q(.67)),
                  borderRadius: 4.r,
                ),
                child: T(
                  S.current.chat_resume,
                  s: TS(c: primaryColor, w: FW.w600, s: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onResumePressed() {
    P.chat.resumeMessageById(id: msg.id);
  }

  void _onBotEditPressed() async {
    await P.chat.onTapEditInBotMessageBubble(index: index);
  }

  void _onRegeneratePressed() async {
    await P.chat.onRegeneratePressed(index: index);
  }

  void _onCopyPressed() {
    Alert.success(S.current.chat_copied_to_clipboard);
    Clipboard.setData(ClipboardData(text: msg.content));
  }
}
