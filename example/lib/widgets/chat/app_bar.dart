// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/arguments_panel.dart';
import 'package:zone/widgets/pager.dart';

class ChatAppBar extends ConsumerWidget {
  const ChatAppBar({super.key});

  void _onTunePressed() async {
    final loaded = P.rwkv.loaded.q;

    if (!loaded) {
      P.fileManager.modelSelectorShown.q = false;
      P.fileManager.modelSelectorShown.q = true;
      return;
    }

    final demoType = P.app.demoType.q;
    if (demoType == DemoType.tts) {
      await P.tts.showTTSCFMStepsSelector();
      return;
    }

    await ArgumentsPanel.show(getContext()!);
    return;
  }

  void _onTitlePressed() async {
    P.fileManager.modelSelectorShown.q = false;
    P.fileManager.modelSelectorShown.q = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final loaded = ref.watch(P.rwkv.loaded);

    final demoType = ref.watch(P.app.demoType);
    final primary = Theme.of(context).colorScheme.primary;
    final currentModel = ref.watch(P.rwkv.currentModel);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final currentGroupInfo = ref.watch(P.rwkv.currentGroupInfo);

    String displayName = s.click_to_select_model;
    if (currentGroupInfo != null) {
      displayName = currentGroupInfo.displayName;
    } else if (currentModel != null) {
      displayName = currentModel.name;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: kW.q(.6),
            elevation: 0,
            centerTitle: true,
            title: GD(
              onTap: _onTitlePressed,
              child: C(
                decoration: const BD(
                  color: kC,
                ),
                child: Co(
                  c: CAA.center,
                  children: [
                    const T(
                      Config.appTitle,
                      s: TS(s: 18),
                    ),
                    2.h,
                    C(
                      padding: const EI.o(l: 4, r: 4, t: 1, b: 1),
                      decoration: BD(
                        color: kB.q(.1),
                        borderRadius: 10.r,
                      ),
                      child: Ro(
                        mainAxisSize: MainAxisSize.min,
                        c: CAA.center,
                        m: MAA.center,
                        children: [
                          T(
                            displayName,
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
            ),
            leading: const Ro(
              children: [
                _MenuButton(),
              ],
            ),
            actions: [
              if (demoType == DemoType.chat)
                IconButton(
                  onPressed: loaded
                      ? () {
                          P.chat.showingCharacterSelector.q = false;
                          P.chat.showingCharacterSelector.q = true;
                          P.chat.loadSuggestions();
                        }
                      : null,
                  icon: (Platform.isIOS || Platform.isMacOS) ? const Icon(CupertinoIcons.bubble_left_bubble_right) : const Icon(Icons.message_outlined),
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

class _MenuButton extends ConsumerWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childOpacity = ref.watch(Pager.childOpacity);
    return Opacity(
      opacity: childOpacity,
      child: const IconButton(
        onPressed: Pager.toggle,
        icon: Icon(Icons.menu),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.q(.667)
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
