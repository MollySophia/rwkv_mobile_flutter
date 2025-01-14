import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:hub/state/p.dart';

class PageOthello extends ConsumerWidget {
  const PageOthello({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: T("Othello"),
      ),
      body: Center(
        child: T("Othello"),
      ),
    );
  }
}

class _Othello extends ConsumerWidget {
  const _Othello();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(P.othello.state);
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final paddingTop = ref.watch(P.app.paddingTop);
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final paddingLeft = ref.watch(P.app.paddingLeft);
    final paddingRight = ref.watch(P.app.paddingRight);
    final isPortrait = ref.watch(P.app.isPortrait);
    return SB(
      width: screenWidth,
      height: screenHeight,
      // padding: EdgeInsets.all(paddingTop),
      // child: Column(
      //   children: [],
      // ),
    );
  }
}
