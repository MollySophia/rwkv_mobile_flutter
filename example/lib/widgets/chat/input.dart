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
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';

class Input extends ConsumerWidget {
  const Input({super.key});

  void _onChanged(String value) {}

  void onEditingComplete() {
    qq;
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final primary = Theme.of(context).colorScheme.primary;
    final loaded = ref.watch(P.rwkv.loaded);
    final loading = ref.watch(P.rwkv.loading);

    String hintText = S.current.send_message_to_rwkv;

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final imagePath = ref.watch(P.world.imagePath);
    bool textFieldEnabled = loaded && !loading;
    bool show = true;

    switch (currentWorldType) {
      case WorldType.engVisualQA:
        if (imagePath != null && imagePath.isNotEmpty) {
          hintText = "Ask me anything about the image";
        } else {
          hintText = "Please select an image or take a photo";
        }
        textFieldEnabled = imagePath != null && imagePath.isNotEmpty;
      case WorldType.engAudioQA:
      case WorldType.chineseASR:
      case WorldType.engASR:
        show = false;
      case null:
        break;
    }

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
              padding: EI.o(l: 10, r: 10, b: paddingBottom + 12, t: 12),
              child: Co(
                children: [
                  KeyboardListener(
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
                  8.h,
                  const _BottomBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar();

  void _onRightButtonPressed() async {
    qq;

    final currentWorldType = P.rwkv.currentWorldType.v;
    final imagePath = P.world.imagePath.v;

    if (currentWorldType != null && imagePath == null) {
      await showImageSelector();
      return;
    }

    await P.chat.onInputRightButtonPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiving = ref.watch(P.chat.receivingTokens);
    final canSend = ref.watch(P.chat.canSend);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);
    final color = Theme.of(context).colorScheme.primary;
    final prefillSpeed = ref.watch(P.rwkv.prefillSpeed);
    final decodeSpeed = ref.watch(P.rwkv.decodeSpeed);
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final demoType = ref.watch(P.app.demoType);
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final usingReasoningModel = ref.watch(P.rwkv.usingReasoningModel);

    return Row(
      children: [
        if (currentWorldType == WorldType.engVisualQA)
          GD(
            onTap: () async {
              await showImageSelector();
            },
            child: C(
              decoration: BD(
                color: primaryContainer,
                border: Border.all(
                  color: color.wo(0.5),
                ),
                borderRadius: 12.r,
              ),
              padding: const EI.o(l: 8, r: 8, t: 8, b: 8),
              child: T(
                "Select new image",
                s: TS(c: color),
              ),
            ),
          ),
        if (demoType == DemoType.chat) const _ReasonButton(),
        if (usingReasoningModel) 4.w,
        if (usingReasoningModel)
          if (demoType == DemoType.chat) const _LangugaeButton(),
        8.w,
        Co(
          c: CAA.start,
          children: [
            T("Prefill: ${prefillSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.wo(0.6), s: 10)),
            T("Decode: ${decodeSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.wo(0.6), s: 10)),
          ],
        ),
        const Spacer(),
        if (receiving)
          GD(
            onTap: () {
              P.chat.onStopButtonPressed();
            },
            child: C(
              decoration: const BD(color: kC),
              child: Stack(
                children: [
                  SizedBox(
                    width: 46,
                    height: 34,
                    child: Center(
                      child: C(
                        decoration: BD(color: color, borderRadius: 2.r),
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                  SB(
                    width: 46,
                    height: 34,
                    child: Center(
                      child: SB(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: color.wo(0.5),
                          strokeWidth: 3,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!receiving)
          AnimatedOpacity(
            opacity: canSend ? 1 : 0.333,
            duration: 250.ms,
            child: GD(
              onTap: _onRightButtonPressed,
              child: C(
                padding: const EI.s(h: 10, v: 5),
                child: Icon(
                  (Platform.isIOS || Platform.isMacOS)
                      ? editingBotMessage
                          ? CupertinoIcons.pencil_circle_fill
                          : CupertinoIcons.arrow_up_circle_fill
                      : editingBotMessage
                          ? Icons.edit
                          : Icons.send,
                  color: color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReasonButton extends ConsumerWidget {
  const _ReasonButton();

  void _onTap() async {
    final loading = P.rwkv.loading.v;
    if (loading) {
      Alert.info("Please wait for the model to load");
      return;
    }
    final receiving = P.chat.receivingTokens.v;
    if (receiving) {
      Alert.info("Please wait for the model to finish generating");
      return;
    }
    final currentModel = P.rwkv.currentModel.v;
    if (currentModel == null) {
      if (P.chat.showingModelSelector.v) return;
      P.chat.showingModelSelector.u(true);
      return;
    }
    final newValue = !P.rwkv.usingReasoningModel.v;
    await P.rwkv.setModelConfig(usingReasoningModel: newValue);

    if (newValue) Alert.success("Reasoning enabled");

    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.primary;
    final usingReasoningModel = ref.watch(P.rwkv.usingReasoningModel);
    final loading = ref.watch(P.rwkv.loading);
    return GD(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        decoration: BD(
          color: usingReasoningModel ? color : kC,
          border: Border.all(
            color: color.wo(0.5),
          ),
          borderRadius: 12.r,
        ),
        padding: const EI.o(l: 4, r: 8, t: 4, b: 4),
        child: Ro(
          c: CAA.center,
          children: [
            if (!loading)
              Icon(
                Icons.emoji_objects_outlined,
                color: usingReasoningModel ? kW : color,
              ),
            if (loading)
              C(
                margin: const EI.o(l: 8, t: 6, b: 6, r: 10),
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                  color: usingReasoningModel ? kW : color,
                  strokeWidth: 2,
                ),
              ),
            if (!loading)
              T(
                "Reason",
                s: TS(c: usingReasoningModel ? kW : color),
              ),
            if (loading)
              T(
                "Loading...",
                s: TS(c: usingReasoningModel ? kW : color),
              ),
          ],
        ),
      ),
    );
  }
}

class _LangugaeButton extends ConsumerWidget {
  const _LangugaeButton();

  void _onTap() async {
    final loading = P.rwkv.loading.v;
    if (loading) {
      Alert.info("Please wait for the model to load");
      return;
    }
    final receiving = P.chat.receivingTokens.v;
    if (receiving) {
      Alert.info("Please wait for the model to finish generating");
      return;
    }
    final currentModel = P.rwkv.currentModel.v;
    if (currentModel == null) {
      if (P.chat.showingModelSelector.v) return;
      P.chat.showingModelSelector.u(true);
      return;
    }
    final newValue = !P.rwkv.preferChinese.v;
    await P.rwkv.setModelConfig(preferChinese: newValue);

    if (newValue) Alert.success("Prefer Chinese");

    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.primary;
    final preferChinese = ref.watch(P.rwkv.preferChinese);
    final loading = ref.watch(P.rwkv.loading);
    return AnimatedOpacity(
      opacity: loading ? 0.33 : 1,
      duration: 250.ms,
      child: GD(
        onTap: _onTap,
        child: C(
          decoration: BD(
            color: preferChinese ? color : kC,
            border: Border.all(
              color: color.wo(0.5),
            ),
            borderRadius: 12.r,
          ),
          padding: const EI.o(l: 4, r: 8, t: 4, b: 4),
          child: Ro(
            c: CAA.center,
            children: [
              Icon(
                Icons.translate,
                color: preferChinese ? kW : color,
              ),
              2.w,
              Co(
                c: CAA.start,
                m: MAA.center,
                children: [
                  if (preferChinese) const T("Prefer", s: TS(c: kW, s: 10, height: 1)),
                  if (preferChinese) const T("Chinese", s: TS(c: kW, s: 10, height: 1)),
                  if (!preferChinese) T("Auto", s: TS(c: color, s: 10, height: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
