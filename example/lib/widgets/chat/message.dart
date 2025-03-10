// ignore: unused_import
import 'dart:developer';
import 'dart:math';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/state/p.dart';

class Message extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const Message(this.msg, this.index, {super.key});

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

  void _onTapLink(String text, String? href, String title) async {
    if (href != null) {
      await launchUrl(Uri.parse(href));
    }
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

    final received = ref.watch(P.chat.received.select((v) => msg.changing ? v : ""));

    final finalContent = changing ? received : content;

    final cotDisplayState = ref.watch(P.chat.cotDisplayState(msg.id));

    final usingReasoningModel = ref.watch(P.chat.usingReasoningModel);

    String cotContent = "";
    String cotResult = "";

    // TODO: @halowang 应该使用当前的模型来判断, 不应该使用内容
    if (usingReasoningModel) {
      final isCot = finalContent.startsWith("<think>");
      if (isCot) {
        if (finalContent.contains("</think>")) {
          final endIndex = finalContent.indexOf("</think>");
          cotContent = finalContent.substring(7, endIndex);
          if (endIndex + 9 < finalContent.length) {
            cotResult = finalContent.substring(endIndex + 9);
          } else {
            cotResult = "";
          }
        } else {
          cotContent = finalContent.substring(7);
          cotResult = "";
        }
      }
    }

    final color = Colors.deepPurple;

    final editingIndex = ref.watch(P.chat.editingIndex);

    final isHistoryForEditing = editingIndex != null && editingIndex > index;
    final isEditing = editingIndex != null && editingIndex == index;
    final isFutureForEditing = editingIndex != null && editingIndex < index;

    final width = ref.watch(P.app.screenWidth);

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

    final receiveId = ref.watch(P.chat.receiveId);
    final receiving = ref.watch(P.chat.receiving);
    final thisMessageIsReceiving = receiveId == msg.id && receiving;

    final markdownStyleSheetForCotContent = MarkdownStyleSheet(
      p: TS(c: kB.wo(0.5)),
      h1: TS(c: kB.wo(0.5)),
      h2: TS(c: kB.wo(0.5)),
      h3: TS(c: kB.wo(0.5)),
      h4: TS(c: kB.wo(0.5)),
      h5: TS(c: kB.wo(0.5)),
      h6: TS(c: kB.wo(0.5)),
      listBullet: TS(c: kB.wo(0.5)),
      listBulletPadding: const EI.o(l: 0),
      listIndent: 20,
    );

    final markdownStyleSheet = MarkdownStyleSheet(
      listBulletPadding: const EI.o(l: 0),
      listIndent: 20,
    );

    double? cotContentHeight;

    switch (cotDisplayState) {
      case CoTDisplayState.showCotHeaderIfCotResultIsEmpty:
        if (cotResult.isEmpty) {
          cotContentHeight = null;
        } else {
          cotContentHeight = 0;
        }
      case CoTDisplayState.showCotHeaderAndCotContent:
        cotContentHeight = null;
      case CoTDisplayState.hideCotHeader:
        cotContentHeight = 0;
    }

    final showingCotContent = cotContentHeight != 0;

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
                        if (isMine) T(finalContent, s: const TS(c: kW)),
                        if (!isMine && !usingReasoningModel)
                          MarkdownBody(
                            data: finalContent,
                            selectable: false,
                            shrinkWrap: true,
                            styleSheet: markdownStyleSheet,
                            onTapLink: _onTapLink,
                          ),
                        // 🔥 Bot message cot header
                        if (!isMine && usingReasoningModel)
                          GD(
                            onTap: () {
                              if (showingCotContent) {
                                ref.read(P.chat.cotDisplayState(msg.id).notifier).state = CoTDisplayState.hideCotHeader;
                              } else {
                                ref.read(P.chat.cotDisplayState(msg.id).notifier).state = CoTDisplayState.showCotHeaderAndCotContent;
                              }
                            },
                            child: C(
                              decoration: const BD(color: kC),
                              child: Ro(
                                children: [
                                  T(thisMessageIsReceiving ? "Thinking..." : "Thought result", s: TS(c: kB.wo(0.5), w: FW.w600)),
                                  showingCotContent ? Icon(Icons.expand_more, color: kB.wo(0.5)) : Icon(Icons.expand_less, color: kB.wo(0.5)),
                                ],
                              ),
                            ),
                          ),
                        // 🔥 Bot message cot content
                        if (!isMine && usingReasoningModel) 4.h,
                        if (!isMine && usingReasoningModel)
                          AnimatedContainer(
                            duration: 250.ms,
                            height: cotContentHeight,
                            child: C(
                              decoration: BD(
                                color: kW.wo(0.1),
                                border: Border(
                                  left: BorderSide(color: kB.wo(0.15), width: 2),
                                ),
                              ),
                              padding: const EI.o(l: 8),
                              child: MarkdownBody(
                                data: cotContent,
                                selectable: false,
                                shrinkWrap: true,
                                styleSheet: markdownStyleSheetForCotContent,
                                onTapLink: _onTapLink,
                              ),
                            ),
                          ),
                        // 🔥 Bot message cot result
                        if (!isMine && cotResult.isNotEmpty && usingReasoningModel) 4.h,
                        if (!isMine && cotResult.isNotEmpty && usingReasoningModel)
                          MarkdownBody(
                            data: cotResult,
                            selectable: false,
                            shrinkWrap: true,
                            styleSheet: markdownStyleSheet,
                            onTapLink: _onTapLink,
                          ),
                        // 🔥 User message bottom row
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
                        // 🔥 Bot message bottom row
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
  }
}
