// ignore: unused_import
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:halo_state/halo_state.dart';
import 'package:photo_viewer/photo_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zone/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/cot_display_state.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/model/world_type.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/audio_bubble.dart';
import 'package:zone/widgets/chat/bot_message_bottom.dart';
import 'package:zone/widgets/chat/bot_tts_content.dart';
import 'package:zone/widgets/chat/photo_viewer_overlay.dart';
import 'package:zone/widgets/chat/user_message_bottom.dart';
import 'package:zone/widgets/chat/user_tts_content.dart';

const double _kTextScaleFactor = 1.1;
const double _kTextScaleFactorForCotContent = 1;

class Message extends ConsumerWidget {
  final model.Message msg;

  /// 使用逆顺序
  ///
  /// TODO: 明确一下这里的 index, 到底是顺序还是逆序
  final int index;

  const Message(this.msg, this.index, {super.key});

  void _onTapLink(String text, String? href, String title) async {
    if (href == null) return;
    await launchUrl(Uri.parse(href));
  }

  void _onTap() async {
    qq;

    if (P.rwkv.currentWorldType.v != null) {
      Focus.of(getContext()!).unfocus();
    }

    P.chat.focusNode.unfocus();
    P.tts.dismissAllShown();

    P.chat.latestClickedMessage.u(msg);
    final isMine = msg.isMine;

    if (msg.type == model.MessageType.userAudio) {
      final audioUrl = msg.audioUrl;
      qqq("audioUrl: $audioUrl");
      if (audioUrl == null) return;
      P.world.play(path: audioUrl);
      return;
    }

    if (msg.type == model.MessageType.ttsGeneration) {
      final audioUrl = msg.audioUrl;
      qqq("audioUrl: $audioUrl");
      if (audioUrl == null) return;
      P.world.play(path: audioUrl);
      return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMine = msg.isMine;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    const marginHorizontal = 12.0;
    const marginVertical = 0.0;
    const kBubbleMinHeight = 44.0;
    const kBubbleMaxWidthAdjust = 0.0;

    final content = msg.content;
    final changing = msg.changing;

    final received = ref.watch(P.chat.receivedTokens.select((v) => msg.changing ? v : ""));

    String finalContent = changing ? (received.isEmpty ? content : received) : content;

    finalContent = finalContent.replaceAll("\n", "\n\n");
    while (finalContent.contains("\n\n\n")) {
      finalContent = finalContent.replaceAll("\n\n\n", "\n\n");
    }

    if (isMine) {
      finalContent = finalContent.replaceAll("\n\n", "\n");
    }

    final cotDisplayState = ref.watch(P.chat.cotDisplayState(msg.id));

    final usingReasoningModel = msg.isReasoning;

    String cotContent = "";
    String cotResult = "";

    final worldType = ref.watch(P.rwkv.currentWorldType);
    final subStringCount = worldType == WorldType.engVisualQAReason ? 8 : 9;

    if (usingReasoningModel) {
      assert(!msg.isMine);
      final isCot = finalContent.startsWith("<think>");
      if (isCot) {
        if (finalContent.contains("</think>")) {
          final endIndex = finalContent.indexOf("</think>");
          cotContent = finalContent.substring(7, endIndex);
          if (endIndex + subStringCount < finalContent.length) {
            final startIndex = endIndex + subStringCount;
            cotResult = finalContent.substring(startIndex);
            if (worldType == WorldType.engVisualQAReason) {
              if (cotResult.endsWith("</answer>")) cotResult = cotResult.replaceFirst("</answer>", "");
              if (cotResult.startsWith("<answer>")) cotResult = cotResult.replaceFirst("<answer>", "");
            }
          } else {
            cotResult = "";
          }
        } else {
          cotContent = finalContent.substring(7);
          cotResult = "";
        }
      }
    }

    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;

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
    final receiving = ref.watch(P.chat.receivingTokens);
    final thisMessageIsReceiving = receiveId == msg.id && receiving;

    final textScaleFactorForCotContent = TextScaler.linear(MediaQuery.textScalerOf(context).scale(_kTextScaleFactorForCotContent));

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
      textScaler: textScaleFactorForCotContent,
    );

    final textScaleFactor = TextScaler.linear(MediaQuery.textScalerOf(context).scale(_kTextScaleFactor));

    final markdownStyleSheet = MarkdownStyleSheet(
      listBulletPadding: const EI.o(l: 0),
      listIndent: 20,
      textScaler: textScaleFactor,
      horizontalRuleDecoration: BoxDecoration(
        color: kB.wo(0.1),
        border: Border(
          top: BorderSide(color: kB.wo(0.1), width: 1),
        ),
      ),
    );

    final rawFontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0;
    final userMessageStyle = TS(c: kB, s: rawFontSize * _kTextScaleFactor);

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

    final isUserImage = msg.type == model.MessageType.userImage;
    final isUserAudio = msg.type == model.MessageType.userAudio;

    String worldDemoMessageHeader = "";

    switch (worldType) {
      case WorldType.chineseASR:
        if (changing) {
          worldDemoMessageHeader = "正在识别您的声音...";
        } else {
          worldDemoMessageHeader = "语音识别结果";
        }
      case WorldType.engASR:
        if (changing) {
          worldDemoMessageHeader = "Recognizing your voice...";
        } else {
          worldDemoMessageHeader = "Voice recognition result";
        }
      case null:
      case WorldType.engVisualQA:
      case WorldType.engVisualQAReason:
      case WorldType.engAudioQA:
        break;
    }

    bool showUserEditButton = true;
    bool showUserCopyButton = true;

    switch (worldType) {
      case null:
        break;
      default:
        showUserEditButton = false;
        showUserCopyButton = false;
    }

    EI padding = const EI.o(
      t: 12,
      l: 12,
      r: 12,
      // b: 12,
    );

    Border border = Border.all(color: primaryColor.wo(0.2));

    if (isUserImage) {
      padding = EI.zero;
      border = Border.all(width: 0);
    }

    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final rawMaxWidth = math.min(screenWidth, screenHeight);

    final bubbleContent = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width - kBubbleMaxWidthAdjust,
        minHeight: kBubbleMinHeight,
      ),
      child: ClipRRect(
        borderRadius: !isUserImage
            ? BorderRadius.zero
            : BorderRadius.only(
                topLeft: Radius.circular(isMine ? 24 : 0),
                topRight: const Radius.circular(24),
                bottomLeft: const Radius.circular(24),
                bottomRight: Radius.circular(isMine ? 0 : 24),
              ),
        child: C(
          padding: padding,
          decoration: BD(
            color: isMine ? primaryContainer : kW,
            // color: isMine ? primaryContainer : kC,
            border: border,
            // border: isMine ? border : null,
            borderRadius: isUserImage
                ? null
                : BorderRadius.only(
                    topLeft: Radius.circular(isMine ? 24 : 0),
                    topRight: const Radius.circular(24),
                    bottomLeft: const Radius.circular(24),
                    bottomRight: Radius.circular(isMine ? 0 : 24),
                  ),
          ),
          child: Co(
            c: isMine ? CAA.end : CAA.start,
            children: [
              if (isMine) ...[
                // 🔥 User message
                if (!isUserImage && !isUserAudio && finalContent.isNotEmpty) T(finalContent, s: userMessageStyle),
                // 🔥 User message image
                if (isUserImage)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: rawMaxWidth * 0.8,
                      maxHeight: rawMaxWidth * 0.8,
                    ),
                    child: PhotoViewerImage(
                      borderRadius: 24,
                      imageUrl: msg.imageUrl!,
                      showDefaultCloseButton: false,
                      overlayBuilder: (context) {
                        return const PhotoViewerOverlay();
                      },
                    ),
                  ),
                // 🔥 User message audio
                if (isUserAudio) AudioBubble(msg),
                UserTtsContent(msg, index),
                UserMessageBottom(msg, index),
              ],
              if (!isMine) ...[
                // 🔥 Bot message audio recognition result
                if (worldDemoMessageHeader.isNotEmpty)
                  T(
                    worldDemoMessageHeader,
                    s: TS(
                      c: kB.wo(0.5),
                      w: FW.w700,
                      s: 10,
                    ),
                  ),
                if (worldDemoMessageHeader.isNotEmpty) 4.h,
                // 🔥 Bot message
                if (!usingReasoningModel)
                  MarkdownBody(
                    data: finalContent,
                    selectable: false,
                    shrinkWrap: true,
                    styleSheet: markdownStyleSheet,
                    onTapLink: _onTapLink,
                  ),
                // 🔥 Bot message cot header
                if (usingReasoningModel)
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
                          T(thisMessageIsReceiving ? S.current.thinking : S.current.thought_result, s: TS(c: kB.wo(0.5), w: FW.w600)),
                          showingCotContent ? Icon(Icons.expand_more, color: kB.wo(0.5)) : Icon(Icons.expand_less, color: kB.wo(0.5)),
                        ],
                      ),
                    ),
                  ),
                // 🔥 Bot message cot content
                if (usingReasoningModel) 4.h,
                if (usingReasoningModel)
                  AnimatedContainer(
                    duration: 250.ms,
                    height: cotContentHeight,
                    child: MarkdownBody(
                      data: cotContent,
                      selectable: false,
                      shrinkWrap: true,
                      styleSheet: markdownStyleSheetForCotContent,
                      onTapLink: _onTapLink,
                    ),
                  ),
                // 🔥 Bot message cot result
                if (cotResult.isNotEmpty && usingReasoningModel && showingCotContent) 12.h,
                if (cotResult.isNotEmpty && usingReasoningModel)
                  MarkdownBody(
                    data: cotResult,
                    selectable: false,
                    shrinkWrap: true,
                    styleSheet: markdownStyleSheet,
                    onTapLink: _onTapLink,
                  ),
                BotMessageBottom(msg, index),
                BotTtsContent(msg, index),
              ],
            ],
          ),
        ),
      ),
    );

    return Align(
      alignment: alignment,
      child: IgnorePointer(
        ignoring: editingIndex != null && editingIndex != index,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: 250.ms,
          child: Padding(
            padding: const EI.s(h: marginHorizontal, v: marginVertical),
            child: SelectionArea(
              child: GD(
                onTap: _onTap,
                child: bubbleContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
