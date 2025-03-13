import 'package:flutter/foundation.dart';
import 'package:zone/route/page_key.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';

class Debugger extends ConsumerWidget {
  const Debugger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    final editingIndex = ref.watch(P.chat.editingIndex);
    final messages = ref.watch(P.chat.messages);
    final demoType = ref.watch(P.app.demoType);

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
              decoration: BD(color: kC),
              child: Co(
                m: MAA.center,
                c: CAA.start,
                children: [
                  const T("Debugger"),
                  T("${"editingIndex".codeToName}\n" + editingIndex.toString()),
                  T("${"messages".codeToName}\n\n" + messages.map((e) => e.toString()).join("\n\n")),
                  T("${"demoType".codeToName}\n" + demoType.toString()),
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
