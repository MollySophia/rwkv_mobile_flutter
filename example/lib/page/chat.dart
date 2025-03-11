// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:zone/func/gb_display.dart';
import 'package:zone/gen/assets.gen.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/model/role.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/input.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/model_item.dart';

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
            HF.wait(1).then((_) {
              P.chat.roles.u(P.chat.roles.v.shuffled);
            });
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
          Input(),
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
      child: GD(
        onTap: () {
          P.chat.focusNode.unfocus();
        },
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
                    child: T(S.current.intro),
                  ),
                  12.h,
                  if (!loaded) T(S.current.start_a_new_chat_by_clicking_the_button_below),
                  if (!loaded) 12.h,
                  if (!loaded)
                    TextButton(
                      onPressed: () async {
                        P.chat.showingModelSelector.u(false);
                        P.chat.showingModelSelector.u(true);
                      },
                      child: T(S.current.select_a_model, s: const TS(s: 16, w: FW.w600)),
                    ),
                  if (!loaded) 12.h,
                  if (loaded) T(S.current.you_are_now_using(currentModel?.weights?.name ?? "")),
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
                      S.current.click_here_to_start_a_new_chat,
                      s: TS(
                        c: loaded ? kB.wo(0.8) : kC,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Exp(
                    child: T(
                      S.current.click_here_to_select_a_new_model,
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
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final source = ref.watch(P.remoteFile.source);
    final memUsedString = gbDisplay(memUsed);
    final memFreeString = gbDisplay(memFree);

    return ClipRRect(
      borderRadius: 16.r,
      child: C(
        margin: const EI.o(t: 16),
        child: ListView(
          padding: const EI.o(t: 24, l: 8, r: 8),
          controller: scrollController,
          children: [
            Ro(
              children: [
                Exp(child: T(S.current.chat_welcome_to_use, s: const TS(s: 18, w: FW.w600))),
                IconButton(
                  onPressed: () {
                    pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            4.h,
            T(S.current.chat_please_select_a_model, s: const TS(s: 16, w: FW.w500)),
            4.h,
            T(S.current.chat_you_need_download_model_if_you_want_to_use_it),
            4.h,
            T(S.current.ensure_you_have_enough_memory_to_load_the_model, s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.memory_used(memUsedString, memFreeString), s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.download_source, s: TS(c: kB.wo(0.7), s: 14, w: FW.w600)),
            4.h,
            Wrap(
              runSpacing: 4,
              spacing: 4,
              children: RemoteFileSource.values.where((e) => kDebugMode ? true : !e.isDebug).map((e) {
                return GD(
                  onTap: () {
                    P.remoteFile.source.u(e);
                  },
                  child: C(
                    decoration: BD(
                      color: e == source ? kCB : kC,
                      borderRadius: 8.r,
                      border: Border.all(
                        color: kCB,
                      ),
                    ),
                    padding: const EI.a(4),
                    child: T(
                      e.name,
                      s: TS(c: e == source ? kW : kB.wo(0.7), s: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
            4.h,
            for (final fileKey in FileKey.availableModels) ModelItem(fileKey),
            16.h,
            paddingBottom.h,
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
            T(S.current.new_chat, s: const TS(s: 16, w: FW.w600)),
            12.h,
            T(S.current.you_can_select_a_role_to_chat),
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
                Exp(child: T(S.current.or_you_can_start_a_new_empty_chat, s: const TS(c: kB, s: 16))),
                TextButton(
                  onPressed: _onStartChatTap,
                  child: C(
                    padding: const EI.s(h: 12, v: 4),
                    child: T(S.current.start_a_new_chat, s: const TS(c: kB, s: 20)),
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
              return Message(msg, finalIndex);
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
