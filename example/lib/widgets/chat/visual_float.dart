// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/func/show_image_selector.dart';
import 'package:zone/state/p.dart';

class VisualFloat extends ConsumerWidget {
  const VisualFloat({super.key});

  void _onTapImageSelector() async {
    await showImageSelector();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Positioned(child: IgnorePointer(child: C()));
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);

    switch (currentWorldType) {
      case null:
      case WorldType.engAudioQA:
      case WorldType.chineseASR:
      case WorldType.engASR:
        return Positioned(child: IgnorePointer(child: C()));
      case WorldType.engVisualQA:
        break;
    }

    final demoType = ref.watch(P.app.demoType);
    final imagePath = ref.watch(P.world.imagePath);

    if (demoType != DemoType.world) return Positioned(child: IgnorePointer(child: C()));
    if (imagePath == null) return Positioned(child: IgnorePointer(child: C()));

    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final paddingTop = ref.watch(P.app.paddingTop);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final maxW = screenWidth;
    final maxH = screenHeight - paddingTop - kToolbarHeight - inputHeight;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final primary = Theme.of(context).colorScheme.primary;

    final width = math.min(maxW, maxH) - 16 - 2;
    final height = width * 0.75;

    final messages = ref.watch(P.chat.messages);
    final full = messages.isEmpty;

    return AnimatedPositioned(
      duration: 250.ms,
      curve: Curves.easeInOutBack,
      left: (screenWidth - width) / 2,
      top: paddingTop + kToolbarHeight + 8,
      height: full ? null : height,
      bottom: full ? inputHeight + 4 : null,
      width: width,
      child: MeasureSize(
        onChange: (Size size) {
          P.world.visualFloatHeight.u(size.height);
        },
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              height: height,
              left: 0,
              width: screenWidth,
              child: C(
                decoration: BD(color: Color(0xFFF4F8FF)),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              width: width,
              height: height - 20,
              child: C(
                decoration: BD(
                  color: primaryContainer.wo(0.5),
                  border: Border.all(
                    color: primary.wo(0.5),
                  ),
                  borderRadius: 12.r,
                ),
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: _onTapImageSelector,
                icon: C(
                  padding: EI.a(4),
                  decoration: BD(
                    color: kW,
                    border: Border.all(
                      color: primary.wo(0.5),
                    ),
                    borderRadius: 12.r,
                  ),
                  child: Co(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: primary,
                      ),
                      T(
                        "Re-upload",
                        s: TS(w: FW.w500, s: 10, c: primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: height,
              left: 4,
              right: 4,
              child: T(
                "Image uploaded",
                s: TS(w: FW.w700, s: 16, c: primary),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: height + 24,
              left: 4,
              right: 4,
              child: T(
                "Click bottom message bar to start chat",
                s: TS(w: FW.w500, s: 12, c: kB.wo(0.5)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
