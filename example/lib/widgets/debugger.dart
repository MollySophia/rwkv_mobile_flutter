import 'package:flutter/foundation.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';

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
                m: MAA.center,
                c: CAA.start,
                children: [
                  const T("Debugger"),
                  T("${"demoType".codeToName}\n" + demoType.toString()),
                  T("${"currentWorldType".codeToName}\n" + currentWorldType.toString()),
                  T("${"currentModel".codeToName}\n" + currentModel.toString()),
                  T("${"visualFloatHeight".codeToName}\n" + visualFloatHeight.toString()),
                  T("${"loading".codeToName}\n" + loading.toString()),
                  T("${"streaming".codeToName}\n" + streaming.toString()),
                  T("${"playing".codeToName}\n" + playing.toString()),
                  T("${"latestClickedMessage".codeToName}\n" + (latestClickedMessage?.id.toString() ?? "null")),
                  T("${"inputHeight".codeToName}\n" + inputHeight.toString()),
                ].m((e) {
                  return C(
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
