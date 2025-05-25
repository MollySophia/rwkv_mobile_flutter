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
          P.suggestion.loadSuggestions();
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
        suggestions = ref.watch(P.suggestion.suggestions);
      case DemoType.world:
        switch (currentWorldType) {
          case WorldType.reasoningQA:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "请向我描述这张图片",
              "Please describe this image for me~",
            ];
            break;
          case WorldType.ocr:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "请向我描述这张图片",
              "Please describe this image for me~",
              "图片上的文字是什么意思？",
              "可以帮我识别一下这张图片上的文字吗？",
              "图片里的文字内容是什么？",
              "这张图片里写了什么？",
              "What does the text in the image mean?",
              "Can you help me recognize the text on this image?",
              "What is the text content in this image?",
              "What is written in this image?",
              "What do you see in this picture?",
            ].shuffled.take(5).toList();
            break;
          case WorldType.qa:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "请向我描述这张图片",
              "Please describe this image for me~",
            ];
            break;
          case WorldType.engVisualQA:
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
        suggestions = ref.watch(P.suggestion.suggestions);
        show = true;
    }

    double bottom = show ? paddingBottom + 114 : -paddingBottom - defaultHeight;

    if (show && demoType == DemoType.tts) {
      bottom += inputHeight - 114 - paddingBottom;
    }

    final kW = ref.watch(P.app.qw);
    final kB = ref.watch(P.app.qb);

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
              child: T(displayText, s: TS(c: kB, s: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
