// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/config.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';

const _height = 46.0;

class Suggestions extends ConsumerWidget {
  const Suggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(P.world.imagePath);
    final demoType = ref.watch(P.app.demoType);
    final messages = ref.watch(P.chat.messages);
    final primary = Theme.of(context).colorScheme.primary;
    final paddingBottom = ref.watch(P.app.quantizedIntPaddingBottom);
    final currentModel = ref.watch(P.rwkv.currentModel);

    ref.watch(P.fileManager.modelSelectorShown);

    bool show = false;

    List<String> suggestions = [];

    if (demoType == DemoType.chat) {
      show = messages.isEmpty && currentModel != null;
      suggestions = ref.watch(P.chat.suggestions);
    }

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);

    if (demoType == DemoType.world) {
      switch (currentWorldType) {
        case WorldType.engVisualQA:
        case WorldType.engVisualQAReason:
          show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
          suggestions = [
            "Please describe this image for me~",
          ];
        case WorldType.engAudioQA:
        case WorldType.chineseASR:
        case WorldType.engASR:
        case null:
          break;
      }
    }

    double bottom = show ? paddingBottom + 114 : -paddingBottom - _height;

    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      height: _height,
      child: ListView(
        padding: const EI.o(l: 8),
        scrollDirection: Axis.horizontal,
        children: suggestions.map((e) {
          return GD(
            onTap: () {
              P.chat.send(e);
            },
            child: C(
              decoration: BD(
                color: Platform.isIOS ? kW.wo(0.9) : kW,
                borderRadius: 6.r,
                border: Border.all(
                  color: primary,
                  width: 0.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: kBG,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              margin: const EI.o(r: 8, t: 4, b: 8),
              padding: const EI.s(v: 4, h: 8),
              child: T(e, s: const TS(c: kB, s: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
