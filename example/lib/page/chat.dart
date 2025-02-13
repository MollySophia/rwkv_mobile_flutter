// ignore: unused_import
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/widgets/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/message.dart';
import 'package:zone/state/p.dart';

class PageChat extends ConsumerWidget {
  const PageChat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final inputHeight = ref.watch(P.chat.inputHeight);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GD(
              onTap: P.chat.onTapMessageList,
              child: const _List(),
            ),
          ),
          const _ScrollToBottomButton(),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _Input(),
          ),
          Positioned(
            bottom: inputHeight,
            left: 0,
            right: 0,
            height: 0.5,
            child: C(
              height: kToolbarHeight,
              color: kB.wo(0.1),
            ),
          ),
          Positioned(
            top: paddingTop + kToolbarHeight,
            left: 0,
            right: 0,
            height: 0.5,
            child: C(
              height: kToolbarHeight,
              color: kB.wo(0.1),
            ),
          ),
          _AppBar(),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(P.app.version);
    final buildNumber = ref.watch(P.app.buildNumber);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: kW.wo(0.6),
            elevation: 0,
            title: AutoSizeText(
              S.current.chat_title,
              style: const TextStyle(fontSize: 20),
              minFontSize: 0,
              maxLines: 2,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: @wangce Use select to improve performance
    final messages = ref.watch(P.chat.messages);
    final paddingTop = ref.watch(P.app.paddingTop);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final useReverse = ref.watch(P.chat.useReverse);

    return RawScrollbar(
      radius: 100.rr,
      thickness: 4,
      thumbColor: kB.wo(0.4),
      padding: EI.o(r: 4, b: inputHeight + 4, t: paddingTop + kToolbarHeight + 4),
      controller: P.chat.scrollController,
      child: ListView.separated(
        reverse: useReverse,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EI.o(
          t: paddingTop + kToolbarHeight + 12,
          b: inputHeight + 12,
        ),
        controller: P.chat.scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final finalIndex = useReverse ? messages.length - 1 - index : index;
          final msg = messages[finalIndex];
          return _Message(msg, finalIndex);
        },
        separatorBuilder: (context, index) {
          return const SB(height: 15);
        },
      ),
    );
  }
}

class _Message extends ConsumerWidget {
  final Message msg;
  final int index;

  const _Message(this.msg, this.index);

  void _onUserEditPressed() async {
    await P.chat.onTapEditInUserMessageBubble(index: index);
  }

  void _onBotEditPressed() async {
    await P.chat.onTapEditInBotMessageBubble(index: index);
  }

  void _onRegeneratePressed() async {
    await P.chat.onRegeneratePressed(index: index);
  }

  void _onCopyPressed() {
    Alert.success(S.current.chat_copied_to_clipboard);
    Clipboard.setData(ClipboardData(text: msg.content));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMine = msg.isMine;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    const marginHorizontal = 12.0;
    const marginVertical = 0.0;
    const kBubbleMinHeight = 44.0;
    const kBubbleMaxWidthAdjust = 40.0;

    final content = msg.content;
    final changing = msg.changing;

    // Do not rebuild if message is not changing.
    final received = ref.watch(P.chat.received.select((v) => msg.changing ? v : ""));

    final finalContent = changing ? received : content;

    final color = Colors.deepPurple;

    final editingIndex = ref.watch(P.chat.editingIndex);

    final isHistoryForEditing = editingIndex != null && editingIndex > index;
    final isEditing = editingIndex != null && editingIndex == index;
    final isFutureForEditing = editingIndex != null && editingIndex < index;

    double opacity = 1;

    if (isHistoryForEditing) {
      opacity = 0.667;
    } else if (isFutureForEditing) {
      opacity = 0.333;
    } else if (isEditing) {
      opacity = 1;
    } else {
      opacity = 1;
    }

    // debugger();

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return Align(
        alignment: alignment,
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: editingIndex != null && editingIndex != index,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: 250.ms,
                child: Padding(
                  padding: const EI.s(h: marginHorizontal, v: marginVertical),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width - kBubbleMaxWidthAdjust,
                      minHeight: kBubbleMinHeight,
                    ),
                    child: C(
                      padding: const EI.a(12),
                      decoration: BD(
                        color: isMine ? const Color.fromARGB(255, 58, 79, 154) : kW,
                        border: Border.all(color: color.wo(0.2)),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMine ? 20 : 0),
                          topRight: const Radius.circular(20),
                          bottomLeft: const Radius.circular(20),
                          bottomRight: Radius.circular(isMine ? 0 : 20),
                        ),
                      ),
                      child: Co(
                        c: isMine ? CAA.end : CAA.start,
                        children: [
                          T(finalContent, s: TS(c: isMine ? kW : kB)),
                          if (isMine) 12.h,
                          if (isMine)
                            Ro(
                              m: MAA.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GD(
                                  onTap: _onUserEditPressed,
                                  child: Icon(
                                    Icons.edit,
                                    color: kW.wo(0.8),
                                    size: 20,
                                  ),
                                ),
                                4.w,
                                GD(
                                  onTap: _onCopyPressed,
                                  child: Icon(
                                    Icons.copy,
                                    color: kW.wo(0.8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          if (!isMine) 12.h,
                          if (!isMine)
                            Ro(
                              m: MAA.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (msg.changing)
                                  GD(
                                    child: TweenAnimationBuilder(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1000000000),
                                      builder: (context, value, child) => Transform.rotate(
                                        angle: value * 2 * pi * 1000000,
                                        child: child,
                                      ),
                                      child: Icon(
                                        Icons.hourglass_top,
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                4.w,
                                GD(
                                  onTap: _onRegeneratePressed,
                                  child: Icon(
                                    Icons.refresh,
                                    color: color.wo(0.8),
                                    size: 20,
                                  ),
                                ),
                                4.w,
                                GD(
                                  onTap: _onBotEditPressed,
                                  child: Icon(
                                    Icons.edit,
                                    color: color.wo(0.8),
                                    size: 20,
                                  ),
                                ),
                                4.w,
                                GD(
                                  onTap: _onCopyPressed,
                                  child: Icon(
                                    Icons.copy,
                                    color: color.wo(0.8),
                                    size: 20,
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
            ),
          ],
        ),
      );
    });
  }
}

class _Input extends ConsumerWidget {
  const _Input();

  void _onChanged(String value) {
    // String finalValue = value;
    // while (finalValue.contains("\n\n\n")) {
    //   finalValue = finalValue.replaceAll("\n\n\n", "\n\n");
    // }
    // while (finalValue.startsWith("\n")) {
    //   finalValue = finalValue.substring(1);
    // }
    // P.chat.textEditingController.value = TextEditingValue(text: finalValue);
  }

  void onEditingComplete() {
    if (kDebugMode) print("💬 $runtimeType._onEditingComplete");
  }

  void _onTap() async {
    if (kDebugMode) print("💬 $runtimeType._onTap");
    await Future.delayed(const Duration(milliseconds: 300));
    await P.chat.scrollToBottom();
  }

  void _onAppPrivateCommand(String action, Map<String, dynamic> data) {
    if (kDebugMode) {
      print("💬 $runtimeType._onAppPrivateCommand: $action, $data");
    }
  }

  void _onTapOutside(PointerDownEvent event) {
    if (kDebugMode) print("💬 $runtimeType._onTapOutside: $event");
    // Do not call unfocus() here, it will cause the keyboard to disappear even a single touch.
    // P.chat.focusNode.unfocus();
  }

  void _onRightButtonPressed() async {
    if (kDebugMode) print("💬 $runtimeType._onSendPressed");
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
        P.chat.textEditingController.value = TextEditingValue(text: "");
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

    return MeasureSize(
      onChange: (size) {
        P.chat.inputHeight.u(size.height);
      },
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: C(
            decoration: BD(color: kW.wo(0.8)),
            padding: EI.o(l: 12, r: 12, b: paddingBottom + 12, t: 12),
            child: Stack(
              children: [
                KeyboardListener(
                  onKeyEvent: _onKeyEvent,
                  focusNode: P.chat.focusNode,
                  child: TextField(
                    controller: P.chat.textEditingController,
                    onSubmitted: P.chat.onSubmitted,
                    onChanged: _onChanged,
                    onEditingComplete: P.chat.onEditingComplete,
                    onAppPrivateCommand: _onAppPrivateCommand,
                    onTap: _onTap,
                    onTapOutside: _onTapOutside,
                    keyboardType: TextInputType.multiline,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.newline,
                    maxLines: 10,
                    minLines: 1,
                    decoration: InputDecoration(
                      fillColor: kW,
                      focusColor: kW,
                      hoverColor: kW,
                      iconColor: kW,
                      border: OutlineInputBorder(
                        borderRadius: 28.r,
                        borderSide: BorderSide(color: color),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: 28.r,
                        borderSide: BorderSide(color: color),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: 28.r,
                        borderSide: BorderSide(color: color),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: 28.r,
                        borderSide: BorderSide(color: color),
                      ),
                      hintText: S.current.chat_title_placeholder,
                      suffixIcon: receiving
                          ? SB(
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
                            )
                          : AnimatedOpacity(
                              opacity: canSend ? 1 : 0.333,
                              duration: 250.ms,
                              child: IconButton(
                                onPressed: canSend ? _onRightButtonPressed : null,
                                icon: Icon(
                                  editingBotMessage ? Icons.edit : Icons.send,
                                  color: color,
                                ),
                              ),
                            ),
                    ),
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

class _ScrollToBottomButton extends ConsumerWidget {
  const _ScrollToBottomButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputHeight = ref.watch(P.chat.inputHeight);
    final atBottom = ref.watch(P.chat.atBottom);
    final screenWidth = ref.watch(P.app.screenWidth);
    final buttonSize = 36.0;
    return AnimatedPositioned(
      duration: 350.ms,
      curve: Curves.easeInOutBack,
      left: (screenWidth - buttonSize) / 2,
      bottom: atBottom ? 0 : inputHeight + 12,
      child: AnimatedOpacity(
        opacity: atBottom ? 0 : 1,
        duration: 150.ms,
        child: GD(
          onTap: atBottom
              ? null
              : () {
                  P.chat.scrollToBottom();
                },
          child: ClipRRect(
            borderRadius: 8.r,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: C(
                decoration: BD(
                  border: Border.all(color: Theme.of(context).colorScheme.primary.wo(0.333)),
                  color: Theme.of(context).colorScheme.primary.wo(0.333),
                  borderRadius: 8.r,
                ),
                height: buttonSize,
                width: buttonSize,
                child: const Icon(
                  Icons.arrow_downward,
                  color: kW,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
