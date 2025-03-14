// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

const _kButtonSize = 56.0;
const _kButtonBottom = 20.0;

class AudioInput extends ConsumerWidget {
  const AudioInput({super.key});

  FV _onTapDown(TapDownDetails details) async {
    Gaimon.light();
    await P.world.startStreaming();
  }

  FV _onPanCancel() async {
    Gaimon.light();
    await P.world.stopStreaming();
  }

  FV _onPanEnd(DragEndDetails details) async {
    Gaimon.light();
    await P.world.stopStreaming();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final screenWidth = ref.watch(P.app.screenWidth);
    final primary = Theme.of(context).colorScheme.primary;
    final demoType = ref.watch(P.app.demoType);
    final worldType = ref.watch(P.rwkv.currentWorldType);
    final shouldShow = demoType == DemoType.world && (worldType == WorldType.engAudioQA || worldType == WorldType.chineseASR);

    return AnimatedPositioned(
      duration: 250.ms,
      curve: Curves.easeInOutBack,
      bottom: shouldShow ? paddingBottom + _kButtonBottom : -_kButtonSize,
      left: (screenWidth - _kButtonSize) / 2,
      height: _kButtonSize,
      width: _kButtonSize,
      child: GD(
        onTapDown: _onTapDown,
        onPanCancel: _onPanCancel,
        onPanEnd: _onPanEnd,
        child: ClipRRect(
          borderRadius: 1000.r,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: C(
              decoration: BD(
                color: primary.wo(0.5),
                border: Border.all(color: primary.wo(0.5)),
                borderRadius: 1000.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
