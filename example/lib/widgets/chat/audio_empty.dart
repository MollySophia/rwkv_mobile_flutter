// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class AudioEmpty extends ConsumerWidget {
  const AudioEmpty({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final paddingTop = ref.watch(P.app.paddingTop);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final primary = Theme.of(context).colorScheme.primary;

    final imagePath = ref.watch(P.world.imagePath);
    if (imagePath != null) {
      return Positioned(child: IgnorePointer(child: C()));
    }

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    if (currentWorldType != WorldType.engAudioQA && currentWorldType != WorldType.chineseASR && currentWorldType != WorldType.engASR) {
      return Positioned(child: IgnorePointer(child: C()));
    }

    final messages = ref.watch(P.chat.messages);

    bool show = true;
    if (messages.isNotEmpty) {
      show = false;
    }

    return AnimatedPositioned(
      duration: 200.ms,
      curve: Curves.easeInOutBack,
      bottom: show ? inputHeight : -screenHeight,
      left: 0,
      width: screenWidth,
      top: paddingTop + kToolbarHeight,
      child: IgnorePointer(
        ignoring: true,
        child: AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: 200.ms,
          curve: Curves.easeInOutBack,
          child: C(
            decoration: BD(color: kC),
            child: Co(
              c: CAA.center,
              m: MAA.center,
              children: [
                C(
                  padding: EI.s(h: 24),
                  child: T(
                    "Please tap the microphone button below to chat to RWKV",
                    s: TS(s: 20, c: primary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
