// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/func/show_image_selector.dart';
import 'package:zone/gen/l10n.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/bottom_bar.dart';
import 'package:zone/widgets/chat/t_t_s_bar.dart';

class Input extends ConsumerWidget {
  const Input({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.quantizedIntPaddingBottom);
    final primary = Theme.of(context).colorScheme.primary;

    final worldType = ref.watch(P.rwkv.currentWorldType);

    final demoType = ref.watch(P.app.demoType);

    bool show = true;

    switch (worldType) {
      case WorldType.engAudioQA:
      case WorldType.chineseASR:
      case WorldType.engASR:
        show = false;
      case WorldType.engVisualQA:
      case WorldType.engVisualQAReason:
      case null:
        show = true;
    }

    qqq(paddingBottom);

    return Positioned(
      bottom: show ? 0 : -P.chat.inputHeight.v,
      left: 0,
      right: 0,
      child: MeasureSize(
        onChange: (size) {
          P.chat.inputHeight.u(size.height);
        },
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: C(
              decoration: BD(
                color: kW.wo(0.8),
                border: Border(
                  top: BorderSide(
                    color: primary.wo(0.33),
                    width: 0.5,
                  ),
                ),
              ),
              padding: EI.o(
                l: 10,
                r: 10,
                b: paddingBottom + 12,
                t: 12,
              ),
              child: Co(
                children: [
                  const _TextField(),
                  8.h,
                  if (demoType != DemoType.tts) const BottomBar(),
                  if (demoType == DemoType.tts) const TTSBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends ConsumerWidget {
  const _TextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final loaded = ref.watch(P.rwkv.loaded);
    final loading = ref.watch(P.rwkv.loading);
    final demoType = ref.watch(P.app.demoType);

    late final String hintText;
    switch (demoType) {
      case DemoType.chat:
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.world:
        hintText = S.current.send_message_to_rwkv;
      case DemoType.tts:
        hintText = S.current.i_want_rwkv_to_say;
    }

    bool textFieldEnabled = loaded && !loading;

    return GD(
      onTap: textFieldEnabled ? null : _onTapTextFieldWhenItsDisabled,
      child: KeyboardListener(
        onKeyEvent: _onKeyEvent,
        focusNode: P.chat.focusNode,
        child: TextField(
          enabled: textFieldEnabled,
          controller: P.chat.textEditingController,
          onSubmitted: P.chat.onSubmitted,
          onChanged: _onChanged,
          onEditingComplete: P.chat.onEditingComplete,
          onAppPrivateCommand: _onAppPrivateCommand,
          onTap: _onTap,
          onTapOutside: _onTapOutside,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          textInputAction: TextInputAction.send,
          maxLines: 10,
          minLines: 1,
          decoration: InputDecoration(
            contentPadding: const EI.o(
              l: 12,
              r: 12,
              t: 4,
              b: 4,
            ),
            fillColor: kW,
            focusColor: kW,
            hoverColor: kW,
            iconColor: kW,
            border: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: 12.r,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            hintText: hintText,
          ),
        ),
      ),
    );
  }

  void _onChanged(String value) {}

  void _onTap() async {
    qq;
    await Future.delayed(const Duration(milliseconds: 300));
    await P.chat.scrollToBottom();
  }

  void _onAppPrivateCommand(String action, Map<String, dynamic> data) {}

  void _onTapOutside(PointerDownEvent event) {
    qq;
  }

  void _onKeyEvent(KeyEvent event) {
    qq;
    final character = event.character;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isEnterPressed = event.logicalKey == LogicalKeyboardKey.enter && character != null;
    if (!isEnterPressed) return;
    if (isShiftPressed) {
      final currentValue = P.chat.textEditingController.value;
      if (currentValue.text.trim().isNotEmpty) {
        P.chat.textEditingController.value = TextEditingValue(text: P.chat.textEditingController.value.text);
      } else {
        Alert.warning(S.current.chat_empty_message);
        P.chat.textEditingController.value = const TextEditingValue(text: "");
      }
    } else {
      P.chat.onInputRightButtonPressed();
    }
  }

  void _onTapTextFieldWhenItsDisabled() {
    qq;
    final loaded = P.rwkv.loaded.v;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.u(true);
      return;
    }
  }
}
