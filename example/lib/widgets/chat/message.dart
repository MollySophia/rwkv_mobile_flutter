// ignore: unused_import
import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:halo_state/halo_state.dart';
import 'package:photo_viewer/photo_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zone/gen/l10n.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/model/world_type.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';

const double _kTextScaleFactor = 1.1;
const double _kTextScaleFactorForCotContent = 1;

class Message extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const Message(this.msg, this.index, {super.key});

  void _onUserEditPressed() async {
    await P.chat.onTapEditInUserMessageBubble(index: index);
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

  void _onTap() async {
    if (P.rwkv.currentWorldType.v != null) {
      Focus.of(getContext()!).unfocus();
    }

    qq;

    P.chat.focusNode.unfocus();
    P.chat.latestClickedMessage.u(msg);
    final isMine = msg.isMine;
    final isAudio = msg.type == model.MessageType.userAudio;

    if (isMine && isAudio) {
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

    String finalContent = changing ? received : content;

    finalContent = finalContent.replaceAll("\n", "\n\n");
    while (finalContent.contains("\n\n\n")) {
      finalContent = finalContent.replaceAll("\n\n\n", "\n\n");
    }

    final cotDisplayState = ref.watch(P.chat.cotDisplayState(msg.id));

    final usingReasoningModel = msg.isReasoning;

    String cotContent = "";
    String cotResult = "";

    if (usingReasoningModel) {
      assert(!msg.isMine);
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
    final worldType = ref.watch(P.rwkv.currentWorldType);

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

    EI padding = EI.o(
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
              // 🔥 User message
              if (isMine && !isUserImage && !isUserAudio) T(finalContent, s: userMessageStyle),
              // 🔥 User message image
              if (isMine && isUserImage)
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
                      return const _PhotoViewerOverlay();
                    },
                  ),
                ),
              // 🔥 User message audio
              if (isMine && isUserAudio) _AudioBubble(msg),
              // 🔥 Bot message audio recognition result
              if (!isMine && worldDemoMessageHeader.isNotEmpty)
                T(
                  worldDemoMessageHeader,
                  s: TS(
                    c: kB.wo(0.5),
                    w: FW.w700,
                    s: 10,
                  ),
                ),
              if (!isMine && worldDemoMessageHeader.isNotEmpty) 4.h,
              // 🔥 Bot message
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
                        T(thisMessageIsReceiving ? S.current.thinking : S.current.thought_result, s: TS(c: kB.wo(0.5), w: FW.w600)),
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
                  child: MarkdownBody(
                    data: cotContent,
                    selectable: false,
                    shrinkWrap: true,
                    styleSheet: markdownStyleSheetForCotContent,
                    onTapLink: _onTapLink,
                  ),
                ),
              // 🔥 Bot message cot result
              if (!isMine && cotResult.isNotEmpty && usingReasoningModel && showingCotContent) 12.h,
              if (!isMine && cotResult.isNotEmpty && usingReasoningModel)
                MarkdownBody(
                  data: cotResult,
                  selectable: false,
                  shrinkWrap: true,
                  styleSheet: markdownStyleSheet,
                  onTapLink: _onTapLink,
                ),
              // 🔥 User message bottom row
              if (isMine && !isUserImage && !isUserAudio && (showUserEditButton || showUserCopyButton)) 12.h,
              if (isMine && !isUserImage && !isUserAudio)
                Ro(
                  m: MAA.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showUserEditButton)
                      GD(
                        onTap: _onUserEditPressed,
                        child: Padding(
                          padding: EI.o(b: 12, l: 4),
                          child: Icon(
                            Icons.edit,
                            color: primaryColor.wo(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    if (showUserCopyButton)
                      GD(
                        onTap: _onCopyPressed,
                        child: Padding(
                          padding: EI.o(b: 12, l: 4),
                          child: Icon(
                            Icons.copy,
                            color: primaryColor.wo(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              // 🔥 Bot message bottom row
              _BotMessageBottom(msg, index),
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

class _BotMessageBottom extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const _BotMessageBottom(this.msg, this.index);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (msg.isMine) return const SizedBox.shrink();

    final paused = msg.paused;

    qqq("paused: $paused");

    final changing = msg.changing;

    final primaryColor = Theme.of(context).colorScheme.primary;

    final worldType = ref.watch(P.rwkv.currentWorldType);

    bool showBotEditButton = true;
    bool showBotCopyButton = true;

    switch (worldType) {
      case null:
        break;
      default:
        showBotEditButton = false;
        showBotCopyButton = false;
    }

    return C(
      padding: const EI.o(t: 12),
      child: Ro(
        m: MAA.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (changing)
            GD(
              child: Padding(
                padding: EI.o(b: 12, r: 4),
                child: TweenAnimationBuilder(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000000000),
                  builder: (context, value, child) => Transform.rotate(
                    angle: value * 2 * pi * 1000000,
                    child: child,
                  ),
                  child: Icon(
                    Icons.hourglass_top,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          4.w,
          GD(
            onTap: _onRegeneratePressed,
            child: Padding(
              padding: EI.o(b: 12, r: 4),
              child: Icon(
                Icons.refresh,
                color: primaryColor.wo(0.8),
                size: 20,
              ),
            ),
          ),
          if (showBotEditButton)
            GD(
              onTap: _onBotEditPressed,
              child: Padding(
                padding: EI.o(b: 12, r: 4),
                child: Icon(
                  Icons.edit,
                  color: primaryColor.wo(0.8),
                  size: 20,
                ),
              ),
            ),
          if (showBotCopyButton) 4.w,
          if (showBotCopyButton)
            GD(
              onTap: _onCopyPressed,
              child: Padding(
                padding: EI.o(b: 12, r: 4),
                child: Icon(
                  Icons.copy,
                  color: primaryColor.wo(0.8),
                  size: 20,
                ),
              ),
            ),
          if (paused) Spacer(),
          if (paused)
            GD(
              onTap: _onResumePressed,
              child: C(
                padding: EI.o(b: 10, l: 12),
                child: C(
                  padding: EI.s(v: 1, h: 8),
                  decoration: BD(color: kC, border: Border.all(color: primaryColor.wo(0.67)), borderRadius: 4.r),
                  child: T(
                    S.current.chat_resume,
                    s: TS(c: primaryColor, w: FW.w600, s: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onResumePressed() {
    P.chat.resumeMessageById(id: msg.id);
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
}

class _AudioBubble extends ConsumerStatefulWidget {
  final model.Message msg;

  const _AudioBubble(this.msg);

  @override
  ConsumerState<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends ConsumerState<_AudioBubble> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();

    ref.listenManual(P.chat.latestClickedMessage, (previous, next) {
      if (next?.id == widget.msg.id) {
        _timer?.cancel();
        _timer = Timer.periodic(500.ms, (timer) {
          _tick++;
          setState(() {});
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final length = widget.msg.audioLength ?? 2000;
    final base = 4000;
    final width = 200 * (length / (length + base));
    final isPlaying = ref.watch(P.world.playing);
    final latestClickedMessage = ref.watch(P.chat.latestClickedMessage);
    final isLatestClickedMessage = latestClickedMessage?.id == widget.msg.id;
    return C(
      decoration: const BD(color: kC),
      width: width,
      child: Ro(
        m: MAA.end,
        children: [
          T(
            (length / 1000).toStringAsFixed(0) + "s",
            s: TS(c: kB.wo(0.8), w: FW.w600),
          ),
          8.w,
          if (_tick % 3 == 0 || !isPlaying || !isLatestClickedMessage)
            Icon(
              Icons.volume_up,
              color: primaryColor,
            ),
          if (_tick % 3 == 2 && isPlaying && isLatestClickedMessage)
            Icon(
              Icons.volume_down,
              color: primaryColor,
            ),
          if (_tick % 3 == 1 && isPlaying && isLatestClickedMessage)
            Icon(
              Icons.volume_mute,
              color: primaryColor,
            ),
        ],
      ),
    );
  }
}

class _PhotoViewerOverlay extends ConsumerWidget {
  const _PhotoViewerOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final paddingRight = ref.watch(P.app.paddingRight);
    return Ro(
      m: MAA.end,
      children: [
        C(
          margin: EI.o(t: paddingTop + 12, r: paddingRight + 12),
          child: IconButton(
            onPressed: () {
              pop();
            },
            icon: const Icon(
              Icons.close,
              color: kW,
            ),
          ),
        ),
      ],
    );
  }
}
