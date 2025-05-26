// ignore: unused_import

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/func/show_image_selector.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/reasoning_option_button.dart';
import 'package:zone/widgets/chat/reason_button.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  void _onRightButtonPressed() async {
    qq;

    final currentWorldType = P.rwkv.currentWorldType.q;
    final imagePath = P.world.imagePath.q;

    if (currentWorldType != null && imagePath == null) {
      await showImageSelector();
      return;
    }

    await P.chat.onInputRightButtonPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiving = ref.watch(P.chat.receivingTokens);
    final canSend = ref.watch(P.chat.canSend);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);
    final color = Theme.of(context).colorScheme.primary;
    final prefillSpeed = ref.watch(P.rwkv.prefillSpeed);
    final decodeSpeed = ref.watch(P.rwkv.decodeSpeed);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final demoType = ref.watch(P.app.demoType);
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final usingReasoningModel = ref.watch(P.rwkv.usingReasoningModel);
    final s = S.of(context);
    final kB = ref.watch(P.app.qb);

    return Ro(
      children: [
        if (currentWorldType?.isVisualDemo ?? false)
          GD(
            onTap: () async {
              await showImageSelector();
            },
            child: C(
              decoration: BD(
                color: primaryContainer,
                border: Border.all(
                  color: color.q(.5),
                ),
                borderRadius: 12.r,
              ),
              padding: const EI.o(l: 8, r: 8, t: 8, b: 8),
              child: T(
                s.select_new_image,
                s: TS(c: color),
              ),
            ),
          ),
        if (demoType == DemoType.chat) const ReasonButton(),
        if (usingReasoningModel) 4.w,
        if (usingReasoningModel)
          if (demoType == DemoType.chat) const ReasoningOptionButton(option: ReasoningOption.language),
        if (usingReasoningModel) 4.w,
        if (usingReasoningModel)
          if (demoType == DemoType.chat) const ReasoningOptionButton(option: ReasoningOption.pseudo),
        8.w,
        Co(
          c: CAA.start,
          children: [
            T("Prefill: ${prefillSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.q(.6), s: 10)),
            T("Decode: ${decodeSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.q(.6), s: 10)),
          ],
        ),
        const Spacer(),
        if (receiving)
          GD(
            onTap: P.chat.onStopButtonPressed,
            child: C(
              decoration: const BD(color: kC),
              child: Stack(
                children: [
                  SizedBox(
                    width: 46,
                    height: 34,
                    child: Center(
                      child: C(
                        decoration: BD(color: color, borderRadius: 2.r),
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                  SB(
                    width: 46,
                    height: 34,
                    child: Center(
                      child: SB(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: color.q(.5),
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!receiving)
          AnimatedOpacity(
            opacity: canSend ? 1 : .333,
            duration: 250.ms,
            child: GD(
              onTap: _onRightButtonPressed,
              child: C(
                padding: const EI.s(h: 10, v: 5),
                child: Icon(
                  (Platform.isIOS || Platform.isMacOS)
                      ? editingBotMessage
                            ? CupertinoIcons.pencil_circle_fill
                            : CupertinoIcons.arrow_up_circle_fill
                      : editingBotMessage
                      ? Icons.edit
                      : Icons.send,
                  color: color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
