import 'package:hub/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';

class Debugger extends ConsumerWidget {
  const Debugger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editingIndex = ref.watch(P.chat.editingIndex);
    final messages = ref.watch(P.chat.messages);
    return Positioned(
      left: 0,
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
              decoration: BD(color: kB.wo(0.5)),
              child: Co(
                m: MAA.center,
                children: [
                  T("Debugger"),
                  T("${"editingIndex".codeToName}\n" + editingIndex.toString()),
                  T("${"messages".codeToName}\n\n" +
                      messages.map((e) => e.toString()).join("\n\n")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
