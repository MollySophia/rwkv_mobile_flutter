// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class Input extends ConsumerWidget {
  const Input({super.key});

  void _onChanged(String value) {}

  void onEditingComplete() {
    logTrace();
  }

  void _onTap() async {
    logTrace();
    await Future.delayed(const Duration(milliseconds: 300));
    await P.chat.scrollToBottom();
  }

  void _onAppPrivateCommand(String action, Map<String, dynamic> data) {}

  void _onTapOutside(PointerDownEvent event) {
    logTrace();
  }

  void _onRightButtonPressed() async {
    logTrace();
    await P.chat.onInputRightButtonPressed();
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
    final receiving = ref.watch(P.chat.receiving);
    final canSend = ref.watch(P.chat.canSend);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);

    final color = Colors.deepPurple;

    final loaded = ref.watch(P.chat.loaded);

    final usingReasoningModel = ref.watch(P.chat.usingReasoningModel);

    return Positioned(
      bottom: 0,
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
              decoration: BD(color: kW.wo(0.8)),
              padding: EI.o(l: 12, r: 12, b: paddingBottom + 12, t: 12),
              child: Co(
                children: [
                  KeyboardListener(
                    onKeyEvent: _onKeyEvent,
                    focusNode: P.chat.focusNode,
                    child: TextField(
                      enabled: loaded,
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
                          borderSide: BorderSide(color: color.wo(0.33)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: 12.r,
                          borderSide: BorderSide(color: color.wo(0.33)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: 12.r,
                          borderSide: BorderSide(color: color.wo(0.33)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: 12.r,
                          borderSide: BorderSide(color: color.wo(0.33)),
                        ),
                        hintText: S.current.send_message_to_rwkv,
                      ),
                    ),
                  ),
                  8.h,
                  Row(
                    children: [
                      GD(
                        onTap: () {
                          if (P.chat.showingModelSelector.v) return;
                          P.chat.showingModelSelector.u(true);
                        },
                        child: C(
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
                              Icon(
                                Icons.emoji_objects_outlined,
                                color: usingReasoningModel ? kW : color,
                              ),
                              T(usingReasoningModel ? "Reason on" : "Reason off",
                                  s: TS(
                                    c: usingReasoningModel ? kW : color,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (receiving)
                        SB(
                          width: 46,
                          child: Center(
                            child: SB(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: color.wo(0.5),
                              ),
                            ),
                          ),
                        ),
                      if (!receiving)
                        AnimatedOpacity(
                          opacity: canSend ? 1 : 0.333,
                          duration: 250.ms,
                          child: GD(
                            onTap: canSend ? _onRightButtonPressed : null,
                            child: Icon(
                              editingBotMessage ? Icons.edit : Icons.send,
                              color: color,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
