// ignore: unused_import
import 'dart:developer';

import 'package:zone/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/visual_empty.dart';

class Empty extends ConsumerWidget {
  const Empty({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final messages = ref.watch(P.chat.messages);
    if (messages.isNotEmpty) return Positioned.fill(child: IgnorePointer(child: Container()));
    final loaded = ref.watch(P.rwkv.loaded);
    final currentModel = ref.watch(P.rwkv.currentModel);

    final demoType = ref.watch(P.app.demoType);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    String logoPath = "assets/img/${demoType.name}/logo.square.png";

    if (demoType == DemoType.world && currentWorldType != null) {
      switch (currentWorldType) {
        case WorldType.engVisualQA:
          return const VisualEmpty();
        case WorldType.engAudioQA:
          return const VisualEmpty();
        case WorldType.chineseASR:
          return const VisualEmpty();
      }
    }

    return AnimatedPositioned(
      duration: 350.ms,
      curve: Curves.easeInOutBack,
      bottom: 0,
      left: 0,
      right: 0,
      top: 0,
      child: GD(
        onTap: () {
          P.chat.focusNode.unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              left: 32,
              right: 32,
              child: Co(
                c: CAA.center,
                children: [
                  const Spacer(),
                  Image.asset(logoPath, width: 140),
                  12.h,
                  T(S.current.chat_welcome_to_use("World RWKV"), s: const TS(s: 18, w: FW.w600)),
                  12.h,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: T(S.current.intro),
                  ),
                  12.h,
                  if (!loaded) T(S.current.start_a_new_chat_by_clicking_the_button_below),
                  if (!loaded) 12.h,
                  if (!loaded)
                    TextButton(
                      onPressed: () async {
                        P.chat.showingModelSelector.u(false);
                        P.chat.showingModelSelector.u(true);
                      },
                      child: T(demoType == DemoType.world ? S.current.select_a_world_type : S.current.select_a_model, s: const TS(s: 16, w: FW.w600)),
                    ),
                  if (!loaded) 12.h,
                  if (loaded) T(S.current.you_are_now_using(currentModel?.weights?.name ?? "")),
                  const Spacer(),
                ],
              ),
            ),
            Positioned(
              top: paddingTop + kToolbarHeight + 12,
              left: 0,
              right: 0,
              height: 200,
              child: Ro(
                c: CAA.start,
                children: [
                  12.w,
                  if (demoType == DemoType.chat)
                    Exp(
                      child: T(
                        S.current.click_here_to_start_a_new_chat,
                        s: TS(
                          c: loaded ? kB.wo(0.8) : kC,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (demoType == DemoType.chat)
                    Exp(
                      child: T(
                        S.current.click_here_to_select_a_new_model,
                        textAlign: TextAlign.end,
                        s: TS(
                          c: !loaded ? kB.wo(0.8) : kC,
                        ),
                      ),
                    ),
                  12.w,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
