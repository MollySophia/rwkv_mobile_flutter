// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo/halo.dart';
import 'package:zone/config.dart';
import 'package:zone/state/p.dart';

const _kButtonSize = 72.0;
const _kButtonBottom = 36.0;
const _kWidgetSize = _kButtonSize + _kButtonBottom;

class AudioInput extends ConsumerWidget {
  const AudioInput({super.key});

  FV _onTapDown(TapDownDetails details) async {
    final receiving = P.chat.receivingTokens.v;
    if (receiving) return;
    Gaimon.light();
    await P.world.startRecord();
  }

  FV _onPanCancel() async {
    final receiving = P.chat.receivingTokens.v;
    if (receiving) return;
    Gaimon.light();
    await P.world.stopRecord();
  }

  FV _onPanEnd(DragEndDetails details) async {
    final receiving = P.chat.receivingTokens.v;
    if (receiving) return;
    Gaimon.light();
    await P.world.stopRecord();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final primary = Theme.of(context).colorScheme.primary;
    final demoType = ref.watch(P.app.demoType);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final screenWidth = ref.watch(P.app.screenWidth);
    final receiving = ref.watch(P.chat.receivingTokens);

    bool shouldShow = false;

    if (demoType == DemoType.world) {
      switch (currentWorldType) {
        case null:
        case WorldType.engVisualQA:
          shouldShow = false;
        case WorldType.engAudioQA:
        case WorldType.chineseASR:
        case WorldType.engASR:
          shouldShow = true;
      }
    }

    String bottomMessage = "";

    if (demoType == DemoType.world) {
      switch (currentWorldType) {
        case null:
        case WorldType.engVisualQA:
          bottomMessage = "";
        case WorldType.engAudioQA:
          bottomMessage = "Press and hold the microphone button above\nrelease to send";
        case WorldType.chineseASR:
          bottomMessage = "长按下方麦克风按钮开始录音\n松开即可发送";
        case WorldType.engASR:
          bottomMessage = "Press and hold the microphone button above\nrelease to send";
      }
    }

    double bottomAdjust = 0;

    if (currentWorldType?.isAudioDemo == true) {
      bottomAdjust = 12;
    }

    return AnimatedPositioned(
      duration: 250.ms,
      curve: Curves.easeInOutBack,
      bottom: shouldShow ? (0 + paddingBottom + bottomAdjust) : -_kWidgetSize,
      left: 0,
      child: MeasureSize(
        onChange: (size) {
          if (currentWorldType != WorldType.chineseASR && currentWorldType != WorldType.engASR) {
            return;
          }
          P.chat.inputHeight.u(size.height + 30);
        },
        child: SB(
          height: _kWidgetSize + bottomAdjust,
          width: screenWidth,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                height: 50,
                bottom: 0,
                child: C(
                  decoration: BD(
                    gradient: LinearGradient(
                      colors: [
                        kBG.wo(0),
                        kBG,
                        kBG,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Co(
                  children: [
                    GD(
                      onTapDown: _onTapDown,
                      onPanCancel: _onPanCancel,
                      onPanEnd: _onPanEnd,
                      child: ClipRRect(
                        borderRadius: 1000.r,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: C(
                            height: _kButtonSize,
                            width: _kButtonSize,
                            decoration: BD(
                              color: primary.wo(0.2),
                              border: Border.all(color: primary.wo(0.5)),
                              borderRadius: 1000.r,
                            ),
                            child: Center(
                              child: receiving
                                  ? CircularProgressIndicator(
                                      color: primary,
                                      strokeWidth: 3,
                                      backgroundColor: primary.wo(0.1),
                                      strokeCap: StrokeCap.round,
                                    )
                                  : Icon(
                                      Icons.mic,
                                      size: 32,
                                      color: primary,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    12.h,
                    T(
                      bottomMessage,
                      s: TS(
                        s: 12,
                        c: primary.wo(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
