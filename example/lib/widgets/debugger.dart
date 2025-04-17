import 'package:flutter/foundation.dart';
import 'package:zone/config.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/widgets/pager.dart';

class Debugger extends ConsumerWidget {
  const Debugger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return const SizedBox.shrink();
    if (!kDebugMode) return const SizedBox.shrink();
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final visualFloatHeight = ref.watch(P.world.visualFloatHeight);
    final loading = ref.watch(P.rwkv.loading);
    final playing = ref.watch(P.world.playing);
    final latestClickedMessage = ref.watch(P.chat.latestClickedMessage);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final hasFocus = ref.watch(P.chat.hasFocus);
    final isOthello = ref.watch(P.app.demoType) == DemoType.othello;
    final paddingTop = ref.watch(P.app.paddingTop);
    final page = ref.watch(Pager.page);
    final mainPageNotIgnoring = ref.watch(Pager.mainPageNotIgnoring);
    final conversation = ref.watch(P.conversation.current);
    final chains = ref.watch(P.chat.chains);
    final currentChain = ref.watch(P.chat.currentChain);
    final editingIndex = ref.watch(P.chat.editingIndex);
    final branchesCountList = ref.watch(P.chat.branchesCountList);
    final receiveId = ref.watch(P.chat.receiveId);
    final ttsDone = ref.watch(P.tts.ttsDone);
    final spkNames = ref.watch(P.tts.spkNames);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Material(
          textStyle: const TS(
            ff: "Monospace",
            c: kW,
            s: 8,
          ),
          color: kC,
          child: SB(
            child: C(
              decoration: const BD(color: kC),
              child: Co(
                m: MAA.start,
                c: CAA.end,
                children: [
                  paddingTop.h,
                  if (currentWorldType != null && !isOthello) T("currentWorldType".codeToName),
                  if (currentWorldType != null && !isOthello) T(currentWorldType.toString()),
                  if (currentWorldType != null && !isOthello) T("visualFloatHeight".codeToName),
                  if (currentWorldType != null) T(visualFloatHeight.toString()),
                  T("loading".codeToName),
                  T(loading.toString()),
                  if (currentWorldType != null) T("playing".codeToName),
                  if (currentWorldType != null) T(playing.toString()),
                  if (!isOthello) T("latestClickedMessage".codeToName),
                  T((latestClickedMessage?.id.toString() ?? "null")),
                  if (!isOthello) T("inputHeight".codeToName),
                  T(inputHeight.toString()),
                  if (!isOthello) T("hasFocus".codeToName),
                  T(hasFocus.toString()),
                  if (Config.enableConversation) T("page".codeToName),
                  if (Config.enableConversation) T(page.toString()),
                  if (Config.enableConversation) T("mainPageNotIgnoring".codeToName),
                  if (Config.enableConversation) T(mainPageNotIgnoring.toString()),
                  if (Config.enableConversation) T("conversation".codeToName),
                  if (Config.enableConversation) T(conversation?.name ?? "null"),
                  // T("receivingTokens".codeToName),
                  // T(receivingTokens.toString()),
                  T("receiveId".codeToName),
                  T(receiveId.toString()),
                  // T("lifecycleState".codeToName),
                  // T(lifecycleState.toString().split(".").last),
                  // T("autoPauseId".codeToName),
                  // T(autoPauseId.toString()),
                  T("editingIndex".codeToName),
                  T(editingIndex.toString()),
                  T("ttsDone".codeToName),
                  T(ttsDone.toString()),
                  T("spkNames length".codeToName),
                  T(spkNames.length.toString()),
                ].indexMap((index, e) {
                  return C(
                    margin: EI.o(t: index % 2 == 0 ? 0 : 1),
                    decoration: BD(color: kB.wo(0.33)),
                    child: e,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
