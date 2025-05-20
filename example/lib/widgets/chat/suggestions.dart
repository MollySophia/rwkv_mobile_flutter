// ignore: unused_import
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:zone/func/is_chinese.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';

class Suggestions extends ConsumerWidget {
  static const defaultHeight = 46.0;

  const Suggestions({super.key});

  void _onSuggestionTap(String suggestion) {
    switch (P.app.demoType.q) {
      case DemoType.chat:
        final text = jsonDecode(suggestion)["prompt"];
        P.chat.send(text);
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.world:
        P.chat.send(suggestion);
      case DemoType.tts:
        final current = P.chat.textEditingController.text;
        if (current.isEmpty) {
          P.chat.textEditingController.text = suggestion;
        } else {
          final last = current.characters.last;
          final lastIsChinese = containsChineseCharacters(last);
          final lastIsEnglish = isEnglish(last);
          P.chat.loadSuggestions();
          if (lastIsChinese) {
            P.chat.textEditingController.text = "$current。$suggestion";
          } else if (lastIsEnglish) {
            P.chat.textEditingController.text = "$current. $suggestion";
          } else {
            P.chat.textEditingController.text = "$current$suggestion";
          }
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(P.world.imagePath);
    final demoType = ref.watch(P.app.demoType);
    final messages = ref.watch(P.chat.messages);
    final primary = Theme.of(context).colorScheme.primary;
    final paddingBottom = ref.watch(P.app.quantizedIntPaddingBottom);
    final currentModel = ref.watch(P.rwkv.currentModel);
    final inputHeight = ref.watch(P.chat.inputHeight);

    final _ = ref.watch(P.fileManager.modelSelectorShown);

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final canSend = ref.watch(P.chat.canSend);

    bool show = false;

    List<String> suggestions = [];

    switch (demoType) {
      case DemoType.chat:
        show = messages.isEmpty && currentModel != null;
        suggestions = ref.watch(P.chat.suggestions);
      case DemoType.world:
        switch (currentWorldType) {
          case WorldType.engVisualQA:
          case WorldType.reasoningQA:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "Please describe this image for me~",
            ];
            break;
          case WorldType.qa:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "请向我描述这张图片",
              "Please describe this image for me~",
            ];
            break;
          case WorldType.ocr:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "What is written in this image?",
            ];
            break;
          case WorldType.engAudioQA:
          case WorldType.chineseASR:
          case WorldType.engASR:
          case null:
            break;
        }
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.tts:
        suggestions = ref.watch(P.chat.suggestions);
        show = true;
    }

    double bottom = show ? paddingBottom + 114 : -paddingBottom - defaultHeight;

    if (show && demoType == DemoType.tts) {
      bottom += inputHeight - 114 - paddingBottom;
    }

    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      height: defaultHeight,
      child: ListView(
        padding: const EI.o(l: 8),
        scrollDirection: Axis.horizontal,
        children: suggestions.map((e) {
          String displayText = e;
          if (demoType == DemoType.chat) {
            displayText = jsonDecode(e)["display"];
          }
          return GD(
            onTap: () {
              _onSuggestionTap(e);
            },
            child: C(
              decoration: BD(
                color: Platform.isIOS ? kW.q(.9) : kW,
                borderRadius: 6.r,
                border: Border.all(
                  color: primary,
                  width: .5,
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
              child: T(displayText, s: const TS(c: kB, s: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
