// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/arguments_panel.dart';

class ChatAppBar extends ConsumerWidget {
  const ChatAppBar({super.key});

  void _onTunePressed() async {
    final demoType = P.app.demoType.v;
    final loaded = P.rwkv.loaded.v;

    if (!loaded) {
      P.chat.showingModelSelector.u(false);
      P.chat.showingModelSelector.u(true);
      return;
    }
    await ArgumentsPanel.show(getContext()!);
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(P.rwkv.loaded);

    final demoType = ref.watch(P.app.demoType);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final primary = Theme.of(context).colorScheme.primary;
    final currentModel = ref.watch(P.rwkv.currentModel);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: kW.wo(0.6),
            elevation: 0,
            centerTitle: true,
            title: GD(
              onTap: () {
                P.chat.showingModelSelector.u(false);
                P.chat.showingModelSelector.u(true);
              },
              child: Co(
                c: CAA.center,
                children: [
                  const T(
                    "RWKV Othello",
                    s: TS(s: 18),
                  ),
                  2.h,
                  C(
                    padding: const EI.o(l: 4, r: 4, t: 1, b: 1),
                    decoration: BD(
                      color: kB.wo(0.1),
                      borderRadius: 10.r,
                    ),
                    child: Ro(
                      mainAxisSize: MainAxisSize.min,
                      c: CAA.center,
                      m: MAA.center,
                      children: [
                        T(
                          currentModel?.weights?.name ?? currentWorldType?.displayName ?? "Click to select a model",
                          s: TS(s: 10, c: primary),
                        ),
                        4.w,
                        Transform.rotate(
                          angle: 0, // 90度
                          child: SB(
                            width: 10,
                            height: 5,
                            child: CustomPaint(
                              painter: _TrianglePainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: Ro(
              children: [
                4.w,
                if (demoType == DemoType.chat)
                  IconButton(
                    onPressed: loaded
                        ? () {
                            P.chat.showingCharacterSelector.u(false);
                            P.chat.showingCharacterSelector.u(true);
                          }
                        : null,
                    icon: (Platform.isIOS || Platform.isMacOS) ? const Icon(CupertinoIcons.bubble_left_bubble_right) : const Icon(Icons.message_outlined),
                  ),
                if (demoType == DemoType.world)
                  IconButton(
                    onPressed: () {
                      P.chat.showingModelSelector.u(false);
                      P.chat.showingModelSelector.u(true);
                    },
                    icon: const Icon(CupertinoIcons.cube_box),
                  ),
              ],
            ),
            actions: [
              if (demoType == DemoType.chat)
                IconButton(
                  onPressed: () {
                    P.chat.showingModelSelector.u(false);
                    P.chat.showingModelSelector.u(true);
                  },
                  icon: const Icon(CupertinoIcons.cube_box),
                ),
              IconButton(
                onPressed: _onTunePressed,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.wo(0.667)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
