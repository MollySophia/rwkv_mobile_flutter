// ignore: unused_import
import 'dart:developer';
import 'dart:ui';

import 'package:zone/gen/l10n.dart';
import 'package:zone/model/role.dart';
import 'package:zone/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/app_bar.dart';
import 'package:zone/widgets/chat/audio_empty.dart';
import 'package:zone/widgets/chat/audio_input.dart';
import 'package:zone/widgets/chat/empty.dart';
import 'package:zone/widgets/chat/input.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/chat/suggestions.dart';
import 'package:zone/widgets/chat/visual_empty.dart';
import 'package:zone/widgets/chat/visual_float.dart';
import 'package:zone/widgets/model_selector.dart';

class PageChat extends StatefulWidget {
  const PageChat({super.key});

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  @override
  void initState() {
    super.initState();
    P.chat.showingModelSelector.l(_onShowingModelSelectorChanged);
    P.chat.showingCharacterSelector.l(_onShowingCharacterSelectorChanged);
    HF.wait(1000).then((_) {
      final loaded = P.rwkv.loaded.v;
      if (!loaded) {
        P.chat.showingModelSelector.u(true);
      }
    });
  }

  void _onShowingCharacterSelectorChanged(bool showing) async {
    if (!showing) return;
    HF.wait(1).then((_) {
      P.chat.roles.u(P.chat.roles.v.shuffled);
    });
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
            return _RoleSelector(scrollController: scrollController);
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
            return ModelSelector(
              scrollController: scrollController,
            );
          },
        );
      },
    );
    P.chat.showingModelSelector.u(false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          _List(),
          Empty(),
          VisualEmpty(),
          AudioEmpty(),
          VisualFloat(),
          //
          ChatAppBar(),
          _NavigationBarBottomLine(),
          //
          _ScrollToBottomButton(),
          //
          Suggestions(),
          Input(),
          AudioInput(),
        ],
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
    final loading = ref.watch(P.rwkv.loading);

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

class _List extends ConsumerWidget {
  const _List();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: @wangce Use select to improve performance
    final messages = ref.watch(P.chat.messages);
    final paddingTop = ref.watch(P.app.paddingTop);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final loaded = ref.watch(P.rwkv.loaded);

    double top = paddingTop + kToolbarHeight + 4;

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    if (currentWorldType == WorldType.engVisualQA) {
      final visualFloatHeight = ref.watch(P.world.visualFloatHeight);
      if (visualFloatHeight != null) {
        top = paddingTop + kToolbarHeight + 4 + visualFloatHeight;
      }
    }

    return Positioned.fill(
      child: GD(
        onTap: P.chat.onTapMessageList,
        child: RawScrollbar(
          radius: 100.rr,
          thickness: 4,
          thumbColor: kB.wo(0.4),
          padding: EI.o(r: 4, b: inputHeight + 4, t: top),
          controller: P.chat.scrollController,
          child: ListView.separated(
            reverse: true,
            physics: loaded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            padding: EI.o(
              t: top,
              b: inputHeight + 12,
            ),
            controller: P.chat.scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final finalIndex = messages.length - 1 - index;
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
    final loaded = ref.watch(P.rwkv.loaded);
    final buttonSize = 36.0;
    final demoType = ref.watch(P.app.demoType);
    if (demoType != DemoType.chat) return Positioned.fill(child: IgnorePointer(child: Container()));
    if (!loaded) return Positioned.fill(child: IgnorePointer(child: Container()));
    return AnimatedPositioned(
      duration: 200.ms,
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
