// ignore: unused_import
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:zone/gen/assets.gen.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/model/role.dart';
import 'package:zone/route/router.dart';
import 'package:zone/widgets/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/message.dart';
import 'package:zone/state/p.dart';

class PageChat extends StatefulWidget {
  const PageChat({super.key});

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  void _onShowingCharacterSelectorChanged(bool showing) async {
    if (!showing) return;
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          expand: false,
          snap: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return _RoleSelector(
              scrollController: scrollController,
            );
          },
        );
      },
    );
    P.chat.showingCharacterSelector.u(false);
  }

  void _onShowingModelSelectorChanged(bool showing) async {
    if (!showing) return;
    P.remoteFile.checkLocalFile();
    P.remoteFile.loadWeights();
    P.device.sync();
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          expand: false,
          snap: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return _ModelSelector(
              scrollController: scrollController,
            );
          },
        );
      },
    );
    P.chat.showingModelSelector.u(false);
  }

  @override
  void initState() {
    super.initState();
    P.chat.showingModelSelector.l(_onShowingModelSelectorChanged);
    P.chat.showingCharacterSelector.l(_onShowingCharacterSelectorChanged);
    HF.wait(1000).then((_) {
      final loaded = P.chat.loaded.v;
      if (!loaded) {
        P.chat.showingModelSelector.u(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          _List(),
          _Welcome(),
          //
          _AppBar(),
          _NavigationBarBottomLine(),
          //
          _ScrollToBottomButton(),
          //
          _InputTopLine(),
          _Input(),
        ],
      ),
    );
  }
}

class _Welcome extends ConsumerWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final messages = ref.watch(P.chat.messages);
    if (messages.isNotEmpty) return Positioned.fill(child: IgnorePointer(child: Container()));
    final loaded = ref.watch(P.chat.loaded);
    final currentModel = ref.watch(P.chat.currentModel);
    return AnimatedPositioned(
      duration: 350.ms,
      curve: Curves.easeInOutBack,
      bottom: 0,
      left: 0,
      right: 0,
      top: 0,
      child: Stack(
        children: [
          Positioned.fill(
            left: 32,
            right: 32,
            child: Co(
              c: CAA.center,
              children: [
                const Spacer(),
                Assets.img.chat.logoSquare.image(width: 140),
                12.h,
                T(S.current.chat_welcome_to_use, s: const TS(s: 18, w: FW.w600)),
                12.h,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: const T(
                    "Get ready to experience RWKV-x070-World, series of compact language models with 0.1, 0.4, 1.5, 3.0 billion parameters, optimized for seamless mobile devices inference. Once loaded, it functions offline without requiring any server communication.",
                  ),
                ),
                12.h,
                if (!loaded) const T("You can start a new chat by clicking the button below."),
                if (!loaded) 12.h,
                if (!loaded)
                  TextButton(
                    onPressed: () async {
                      P.chat.showingModelSelector.u(false);
                      P.chat.showingModelSelector.u(true);
                    },
                    child: const T("Select a model", s: TS(s: 16, w: FW.w600)),
                  ),
                if (!loaded) 12.h,
                if (loaded) T("You are now using ${currentModel?.weights?.name}"),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            top: paddingTop + kToolbarHeight + 12,
            left: 0,
            right: 0,
            height: 200,
            child: Ro(
              c: CAA.start,
              children: [
                12.w,
                Exp(
                  child: T(
                    "Click here to start a new chat",
                    s: TS(
                      c: loaded ? kB.wo(0.8) : kC,
                    ),
                  ),
                ),
                const Spacer(),
                Exp(
                  child: T(
                    "Click here to select a new model.",
                    textAlign: TextAlign.end,
                    s: TS(
                      c: !loaded ? kB.wo(0.8) : kC,
                    ),
                  ),
                ),
                12.w,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelSelector extends ConsumerWidget {
  final ScrollController scrollController;

  const _ModelSelector({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memUsed = ref.watch(P.device.memUsed);
    final memFree = ref.watch(P.device.memFree);
    final memUsedByCurrentModel = ref.watch(P.device.memUsedByCurrentModel);
    return ClipRRect(
      borderRadius: 16.r,
      child: C(
        margin: const EI.o(t: 16),
        child: ListView(
          padding: const EI.o(t: 24, l: 12, r: 12),
          controller: scrollController,
          children: [
            T(S.current.chat_welcome_to_use, s: const TS(s: 16, w: FW.w600)),
            4.h,
            T(S.current.chat_please_select_a_model),
            4.h,
            T(S.current.chat_you_need_download_model_if_you_want_to_use_it),
            4.h,
            const T("Please ensure you have enough memory to load the model, otherwise the application may crash."),
            4.h,
            T("Memory used: ${(memUsed / 1024 / 1024).toStringAsFixed(0)}MB, Memory free: ${(memFree / 1024 / 1024).toStringAsFixed(0)}MB, Memory used by current model: ${(memUsedByCurrentModel / 1024 / 1024).toStringAsFixed(0)}MB"),
            4.h,
            for (final fileKey in FileKey.availableModels) _ModelItem(fileKey),
            16.h,
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends ConsumerWidget {
  final ScrollController scrollController;

  const _RoleSelector({required this.scrollController});

  void _onStartChatTap() async {
    await P.chat.startNewChat();
    Navigator.pop(getContext()!);
  }

  void _onRoleTap(Role role) async {
    await P.chat.startNewChat();
    await HF.wait(100);
    Navigator.pop(getContext()!);
    await HF.wait(100);
    P.chat.send(role.value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(P.chat.roles);
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final loading = ref.watch(P.chat.loading);

    return ClipRRect(
      borderRadius: 16.r,
      child: C(
        margin: const EI.o(t: 16),
        child: Co(
          children: [
            const T("New chat", s: TS(s: 16, w: FW.w600)),
            12.h,
            const T("You can select a role to chat"),
            12.h,
            Exp(
              child: ListView.builder(
                padding: const EI.o(t: 24, l: 12, r: 12),
                controller: scrollController,
                itemBuilder: (context, index) {
                  return C(
                    margin: const EI.o(b: 12),
                    child: Row(
                      children: [
                        Exp(
                          child: SelectionArea(
                            child: Co(
                              c: CAA.start,
                              children: [
                                T(roles[index].key, s: const TS(s: 14, w: FW.w600)),
                                T(roles[index].value, s: const TS(s: 12)),
                              ],
                            ),
                          ),
                        ),
                        12.w,
                        GD(
                          onTap: () {
                            if (loading) return;
                            _onRoleTap(roles[index]);
                          },
                          child: C(
                            decoration: BD(
                              color: loading ? kCG.wo(0.5) : kCG,
                              borderRadius: 8.r,
                            ),
                            padding: const EI.a(8),
                            child: T(loading ? "Loading..." : S.current.start_to_chat, s: const TS(c: kW)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: roles.length,
              ),
            ),
            12.h,
            Ro(
              children: [
                12.w,
                const Exp(child: T("Or you can start a new empty chat", s: TS(c: kB, s: 16))),
                TextButton(
                  onPressed: _onStartChatTap,
                  child: C(
                    padding: const EI.s(h: 12, v: 4),
                    child: const T("Start a new chat", s: TS(c: kB, s: 20)),
                  ),
                ),
                12.w,
              ],
            ),
            4.h,
            paddingBottom.h,
          ],
        ),
      ),
    );
  }
}

class _ModelItem extends ConsumerWidget {
  final FileKey fileKey;

  const _ModelItem(this.fileKey);

  void _onLoadTap() async {
    if (P.chat.loading.v) return;
    if (kDebugMode) print("💬 _onLoadTap");
    final modelPath = fileKey.path;
    final backend = fileKey.backend;
    P.chat.loading.u(true);

    try {
      P.rwkv.clearStates();
      P.chat.messages.u([]);
      await P.rwkv.loadChat(modelPath: modelPath, backend: backend);
    } catch (e) {
      Alert.error(e.toString());
      return;
    } finally {
      P.chat.loading.u(false);
    }

    P.chat.currentModel.u(fileKey);
    Alert.success("You can now start to chat with RWKV");
    Navigator.pop(getContext()!);
  }

  void _onDownloadTap() async {
    P.remoteFile.getFile(fileKey: fileKey);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(P.remoteFile.files(fileKey));
    final fileSize = file.expectedFileSize;
    final fileSizeMB = fileSize / 1024 / 1024;
    final fileSizeString = fileSizeMB.toStringAsFixed(2);
    final fileSizeGB = fileSizeMB / 1024;
    final fileSizeGBString = fileSizeGB.toStringAsFixed(2);
    final shouldShowGB = fileSizeGB > 1;
    final progress = file.progress;
    final hasFile = file.hasFile;
    final downloading = file.downloading;
    final modelSizeB = fileKey.modelSizeB;
    final q = fileKey.quantization;
    final networkSpeed = file.networkSpeed;
    final timeRemaining = file.timeRemaining;
    final currentModel = ref.watch(P.chat.currentModel);
    final isCurrentModel = currentModel == fileKey;
    final loading = ref.watch(P.chat.loading);

    return ClipRRect(
      borderRadius: 8.r,
      child: C(
        decoration: BD(color: kW, borderRadius: 8.r),
        margin: const EI.o(t: 8),
        padding: const EI.a(8),
        child: SB(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            // alignment: WrapAlignment.start,
            children: [
              Co(
                c: CAA.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      T(
                        fileKey.name,
                        s: const TS(c: kB, w: FW.w600),
                      ),
                      if (shouldShowGB) T("$fileSizeGBString GB"),
                      if (!shouldShowGB) T("$fileSizeString MB"),
                    ],
                  ),
                  4.h,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      C(
                        decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                        padding: const EI.s(h: 4),
                        child: T(fileKey.backend.asArgument),
                      ),
                      if (modelSizeB > 0)
                        C(
                          decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                          padding: const EI.s(h: 4),
                          child: T("${modelSizeB}B"),
                        ),
                      if (q.isNotEmpty)
                        C(
                          decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                          padding: const EI.s(h: 4),
                          child: T(q),
                        ),
                    ],
                  ),
                  if (downloading) 8.h,
                  if (downloading)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return SB(
                          width: width - 100,
                          child: Ro(
                            children: [
                              Exp(
                                flex: (100 * progress).toInt(),
                                child: C(
                                  decoration: BD(
                                    borderRadius: BorderRadius.only(topLeft: 8.rr, bottomLeft: 8.rr),
                                    color: kCG,
                                  ),
                                  height: 4,
                                ),
                              ),
                              Exp(
                                flex: 100 - (100 * progress).toInt(),
                                child: C(
                                  decoration: BD(
                                    borderRadius: BorderRadius.only(topRight: 8.rr, bottomRight: 8.rr),
                                    color: kG.wo(0.5),
                                  ),
                                  height: 4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (downloading) 4.h,
                  if (downloading)
                    Wrap(
                      children: [
                        const T("Speed: "),
                        T("${networkSpeed.toStringAsFixed(1)}mb/s"),
                        12.w,
                        const T("Remaining: "),
                        if (timeRemaining.inMinutes > 0) T("${timeRemaining.inMinutes}m"),
                        if (timeRemaining.inMinutes == 0) T("${timeRemaining.inSeconds}s"),
                      ],
                    ),
                ],
              ),
              8.w,
              if (!hasFile && !downloading)
                IconButton(
                  onPressed: _onDownloadTap,
                  icon: const Icon(Icons.download),
                ),
              if (downloading)
                C(
                  margin: const EI.o(r: 8),
                  child: const SB(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (hasFile && !isCurrentModel)
                GD(
                  onTap: _onLoadTap,
                  child: C(
                    decoration: BD(
                      color: loading ? kCG.wo(0.5) : kCG,
                      borderRadius: 8.r,
                    ),
                    padding: const EI.a(8),
                    child: T(loading ? "Loading..." : S.current.start_to_chat, s: const TS(c: kW)),
                  ),
                ),
              if (isCurrentModel)
                GD(
                  onTap: null,
                  child: C(
                    decoration: BD(
                      color: kG.wo(0.5),
                      borderRadius: 8.r,
                    ),
                    padding: const EI.a(8),
                    child: T(S.current.chatting, s: const TS(c: kW)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputTopLine extends ConsumerWidget {
  const _InputTopLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputHeight = ref.watch(P.chat.inputHeight);
    return Positioned(
      bottom: inputHeight,
      left: 0,
      right: 0,
      height: 0.5,
      child: C(
        height: kToolbarHeight,
        color: kB.wo(0.1),
      ),
    );
  }
}

class _NavigationBarBottomLine extends ConsumerWidget {
  const _NavigationBarBottomLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    return Positioned(
      top: paddingTop + kToolbarHeight,
      left: 0,
      right: 0,
      height: 0.5,
      child: C(
        height: kToolbarHeight,
        color: kB.wo(0.1),
      ),
    );
  }
}

class _AppBar extends ConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(P.chat.loaded);
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
            centerTitle: true,
            title: AutoSizeText(
              S.current.chat_title,
              style: const TextStyle(fontSize: 20),
              minFontSize: 0,
              maxLines: 2,
            ),
            leading: IconButton(
              onPressed: loaded
                  ? () {
                      P.chat.showingCharacterSelector.u(false);
                      P.chat.showingCharacterSelector.u(true);
                    }
                  : null,
              icon: const Icon(Icons.add_comment_outlined),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  P.chat.showingModelSelector.u(false);
                  P.chat.showingModelSelector.u(true);
                },
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
    final loaded = ref.watch(P.chat.loaded);

    return Positioned.fill(
      child: GD(
        onTap: P.chat.onTapMessageList,
        child: RawScrollbar(
          radius: 100.rr,
          thickness: 4,
          thumbColor: kB.wo(0.4),
          padding: EI.o(r: 4, b: inputHeight + 4, t: paddingTop + kToolbarHeight + 4),
          controller: P.chat.scrollController,
          child: ListView.separated(
            reverse: useReverse,
            physics: loaded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
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
        ),
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
              child: KeyboardListener(
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
    final loaded = ref.watch(P.chat.loaded);
    final buttonSize = 36.0;
    if (!loaded) return Positioned.fill(child: IgnorePointer(child: Container()));
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
