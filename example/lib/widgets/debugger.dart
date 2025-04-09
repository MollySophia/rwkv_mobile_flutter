import 'package:flutter/foundation.dart';
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
    final demoType = ref.watch(P.app.demoType);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final currentModel = ref.watch(P.rwkv.currentModel);
    final visualFloatHeight = ref.watch(P.world.visualFloatHeight);
    final loading = ref.watch(P.rwkv.loading);
    final streaming = ref.watch(P.world.streaming);
    final playing = ref.watch(P.world.playing);
    final latestClickedMessage = ref.watch(P.chat.latestClickedMessage);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final hasFocus = ref.watch(P.chat.hasFocus);
    final isOthello = ref.watch(P.app.demoType) == DemoType.othello;
    final soc = ref.watch(P.rwkv.soc);
    final paddingTop = ref.watch(P.app.paddingTop);
    final page = ref.watch(Pager.page);
    final mainPageNotIgnoring = ref.watch(Pager.mainPageNotIgnoring);
    final conversation = ref.watch(P.conversation.current);
    final receivingTokens = ref.watch(P.chat.receivingTokens);
    final receiveId = ref.watch(P.chat.receiveId);
    final lifecycleState = ref.watch(P.app.lifecycleState);
    final autoPauseId = ref.watch(P.chat.autoPauseId);

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
                  const T("Debugger"),
                  T("demoType".codeToName),
                  T(demoType.toString()),
                  if (currentWorldType != null)
                    if (!isOthello) T("currentWorldType".codeToName),
                  if (currentWorldType != null) T(currentWorldType.toString()),
                  if (!isOthello) T("currentModel".codeToName),
                  T((currentModel?.name ?? "null")),
                  if (currentWorldType != null)
                    if (!isOthello) T("visualFloatHeight".codeToName),
                  if (currentWorldType != null) T(visualFloatHeight.toString()),
                  T("loading".codeToName),
                  T(loading.toString()),
                  T("streaming".codeToName),
                  T(streaming.toString()),
                  if (currentWorldType != null) T("playing".codeToName),
                  if (currentWorldType != null) T(playing.toString()),
                  if (!isOthello) T("latestClickedMessage".codeToName),
                  T((latestClickedMessage?.id.toString() ?? "null")),
                  if (!isOthello) T("inputHeight".codeToName),
                  T(inputHeight.toString()),
                  if (!isOthello) T("hasFocus".codeToName),
                  T(hasFocus.toString()),
                  if (!isOthello) T("soc".codeToName),
                  T(soc.toString()),
                  T("page".codeToName),
                  T(page.toString()),
                  T("mainPageNotIgnoring".codeToName),
                  T(mainPageNotIgnoring.toString()),
                  T("conversation".codeToName),
                  T(conversation?.name ?? "null"),
                  T("receivingTokens".codeToName),
                  T(receivingTokens.toString()),
                  T("receiveId".codeToName),
                  T(receiveId.toString()),
                  T("lifecycleState".codeToName),
                  T(lifecycleState.toString().split(".").last),
                  T("autoPauseId".codeToName),
                  T(autoPauseId.toString()),
                ].indexMap((index, e) {
                  return C(
                    margin: EI.o(t: index % 2 == 1 ? 0 : 1),
                    decoration: BD(color: kB.wo(0.67)),
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
