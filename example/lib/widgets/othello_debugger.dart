import 'package:zone/route/page_key.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';

class OthelloDebugger extends ConsumerWidget {
  const OthelloDebugger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageKey = ref.watch(P.app.pageKey);
    if (pageKey != PageKey.othello) return const SizedBox.shrink();
    final state = ref.watch(P.othello.state);
    final blackTurn = ref.watch(P.othello.blackTurn);
    final eatCountMatrixForBlack = ref.watch(P.othello.eatCountMatrixForBlack);
    final eatCountMatrixForWhite = ref.watch(P.othello.eatCountMatrixForWhite);
    final thinking = ref.watch(P.othello.thinking);
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final paddingTop = ref.watch(P.app.paddingTop);
    return Positioned(
      top: paddingTop,
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
                c: CAA.start,
                children: [
                  T("Debugger"),
                  T("${"blackTurn".codeToName}\n" + blackTurn.toString()),
                  T("${"thinking".codeToName}\n" + thinking.toString()),
                  T("${"screenWidth".codeToName}\n" + screenWidth.toString()),
                  T("${"screenHeight".codeToName}\n" + screenHeight.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
