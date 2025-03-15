// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:zone/gen/l10n.dart';
import 'package:zone/model/role.dart';
import 'package:zone/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/app_bar.dart';
import 'package:zone/widgets/chat/audio_input.dart';
import 'package:zone/widgets/chat/empty.dart';
import 'package:zone/widgets/chat/input.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/chat/visual_float.dart';
import 'package:zone/widgets/model_selector.dart';

const _height = 28.0;

class Suggestions extends ConsumerWidget {
  const Suggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final imagePath = ref.watch(P.world.imagePath);
    final demoType = ref.watch(P.app.demoType);
    final messages = ref.watch(P.chat.messages);
    final primary = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;

    bool show = false;

    List<String> suggestions = [];

    if (demoType == DemoType.chat) {
      show = messages.isEmpty;
      suggestions = [
        'Please tell me about the Eiffel Tower.',
        "Why is the sky blue? ",
      ];
    }

    if (demoType == DemoType.world) {
      switch (currentWorldType) {
        case WorldType.engVisualQA:
          show = imagePath != null && imagePath.isNotEmpty && messages.isEmpty;
          suggestions = [
            'What do you see in this picture?',
            "Are there any interesting details you notice?",
            "Does this picture remind you of anything?",
          ];
        case WorldType.engAudioQA:
        case WorldType.chineseASR:
        case null:
          break;
      }
    }

    return AnimatedPositioned(
      duration: 200.ms,
      curve: Curves.easeInOutBack,
      bottom: show ? P.chat.inputHeight.v + 8 : -P.chat.inputHeight.v - _height,
      left: 0,
      right: 0,
      height: _height,
      child: ListView(
        padding: const EI.o(l: 8),
        scrollDirection: Axis.horizontal,
        children: suggestions
            .map(
              (e) => GD(
                onTap: () {
                  P.chat.send(e);
                },
                child: C(
                  decoration: BD(
                    color: kW.wo(0.8),
                    borderRadius: 4.r,
                    border: Border.all(
                      color: primary,
                      width: 0.5,
                    ),
                  ),
                  margin: EI.o(r: 8),
                  padding: EI.a(4),
                  child: T(e, s: TS(c: kB)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
