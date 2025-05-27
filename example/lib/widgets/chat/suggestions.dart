// ignore: unused_import
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:zone/func/is_chinese.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';

class Suggestions extends ConsumerWidget {
  static const defaultHeight = 46.0;

  const Suggestions({super.key});

  void _onSuggestionTap(dynamic suggestion) {
    switch (P.app.demoType.q) {
      case DemoType.chat:
        final text = (suggestion as Suggestion).prompt;
        P.chat.send(text);
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.world:
        P.chat.send(suggestion);
      case DemoType.tts:
        final current = P.chat.textEditingController.text;
        if (current.isEmpty) {
          P.chat.textEditingController.text = suggestion;
        } else {
          final last = current.characters.last;
          final lastIsChinese = containsChineseCharacters(last);
          final lastIsEnglish = isEnglish(last);
          P.suggestion.loadSuggestions();
          if (lastIsChinese) {
            P.chat.textEditingController.text = "$current。$suggestion";
          } else if (lastIsEnglish) {
            P.chat.textEditingController.text = "$current. $suggestion";
          } else {
            P.chat.textEditingController.text = "$current$suggestion";
          }
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(P.world.imagePath);
    final demoType = ref.watch(P.app.demoType);
    final messages = ref.watch(P.chat.messages);
    final paddingBottom = ref.watch(P.app.quantizedIntPaddingBottom);
    final currentModel = ref.watch(P.rwkv.currentModel);
    final inputHeight = ref.watch(P.chat.inputHeight);

    final _ = ref.watch(P.fileManager.modelSelectorShown);

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);

    bool show = false;

    List<dynamic> suggestions = [];
    final config = ref.watch(P.suggestion.config);

    switch (demoType) {
      case DemoType.chat:
        show = messages.isEmpty && currentModel != null;
        suggestions = config.chat.map((e) => e.suggestions).flattened.shuffled().take(5).toList();
        break;
      case DemoType.world:
        switch (currentWorldType) {
          case WorldType.reasoningQA:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = config.seeReasoningQa;
            break;
          case WorldType.ocr:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = config.seeOcr.toList().shuffled.take(5).toList();
            break;
          case WorldType.qa:
            show = imagePath != null && imagePath.isNotEmpty && messages.length == 1;
            suggestions = [
              "请向我描述这张图片",
              "Please describe this image for me~",
            ];
            break;
          default:
            break;
        }
        break;
      case DemoType.tts:
        show = true;
        suggestions = config.tts.toList().shuffled.take(5).toList();
        break;
      default:
        return SizedBox.shrink();
    }

    double bottom = show ? paddingBottom + 114 : -paddingBottom - defaultHeight;

    if (show && demoType == DemoType.tts) {
      bottom += inputHeight - 114 - paddingBottom;
    }

    final showAllPromptButton = config.chat.length > 1;

    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      height: defaultHeight,
      child: Row(
        children: [
          Exp(
            child: _buildRndPromptList(context, suggestions),
          ),
          if (showAllPromptButton) 8.w,
          if (showAllPromptButton) _buildAllButton(context),
          if (showAllPromptButton) 8.w,
        ],
      ),
    );
  }

  Widget _buildRndPromptList(
    BuildContext context,
    List suggestions,
  ) {
    final primary = Theme.of(context).primaryColor;
    return ListView(
      padding: const EI.o(l: 8, b: 8, t: 2),
      scrollDirection: Axis.horizontal,
      children: suggestions.map((e) {
        String displayText = '';
        if (e is Suggestion) {
          displayText = e.display;
        } else {
          displayText = e.toString();
        }
        return _buildTag(
          displayText,
          color: primary,
          onTap: () => _onSuggestionTap(e),
        );
      }).toList(),
    );
  }

  Widget _buildAllButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final prompt = await AllSuggestionDialog.show(context);
        if (prompt != null) {
          await Future.delayed(const Duration(milliseconds: 200));
          _onSuggestionTap(prompt);
        }
      },
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EI.s(v: 0, h: 8),
        shape: OutlinedBorder.lerp(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          0,
        ),
      ),
      child: Text(S.of(context).all),
    );
  }

  Widget _buildTag(String text, {required Color color, required VoidCallback? onTap}) {
    return GD(
      onTap: onTap,
      child: C(
        alignment: Alignment.center,
        decoration: BD(
          color: Platform.isIOS ? kW.q(.9) : kW,
          borderRadius: 6.r,
          border: Border.all(
            color: color,
            width: .5,
          ),
          boxShadow: const [
            BoxShadow(
              color: kBG,
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        margin: const EI.o(r: 8, t: 4),
        padding: const EI.s(v: 4, h: 8),
        child: T(text, s: const TS(c: kB, s: 16)),
      ),
    );
  }
}

class AllSuggestionDialog extends StatefulWidget {
  final ScrollController scrollController;

  const AllSuggestionDialog({
    super.key,
    required this.scrollController,
  });

  static Future<Suggestion?> show(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => DraggableScrollableSheet(
        initialChildSize: .8,
        maxChildSize: .9,
        expand: false,
        snap: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return AllSuggestionDialog(
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  @override
  State<AllSuggestionDialog> createState() => _AllSuggestionDialogState();
}

class _AllSuggestionDialogState extends State<AllSuggestionDialog> implements TickerProvider {
  late final allCategories = P.suggestion.config.q.chat;
  late final categoryCount = allCategories.length;

  late final TabController tabController = TabController(length: categoryCount, vsync: this);
  late final PageController pageController = PageController(initialPage: 0, viewportFraction: 1);
  bool isChangingIndex = false;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() async {
      if (isChangingIndex) {
        await Future.delayed(const Duration(milliseconds: 200));
        isChangingIndex = false;
        return;
      }
      final pageIndex = pageController.page!.round();
      if (tabController.index != pageIndex) {
        tabController.animateTo(pageIndex);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SB(
      width: double.infinity,
      child: Co(
        c: CrossAxisAlignment.center,
        children: [
          16.h,
          T(S.of(context).all_prompt, s: const TS(s: 16, w: FW.w600)),
          16.h,
          SB(
            height: 50,
            child: TabBar(
              isScrollable: true,
              unselectedLabelStyle: const TS(c: kB, s: 12),
              labelPadding: const EI.s(v: 0, h: 12),
              tabAlignment: TabAlignment.start,
              controller: tabController,
              onTap: (i) {
                if (i != pageController.page!.round()) {
                  isChangingIndex = true;
                  pageController.animateToPage(i, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                }
              },
              tabs: [
                for (final category in allCategories) Tab(text: category.name),
              ],
            ),
          ),
          Exp(
            child: PageView.builder(
              controller: pageController,
              itemCount: categoryCount,
              itemBuilder: (ctx, page) {
                final category = allCategories[page];
                return _SuggestionList(
                  scrollController: widget.scrollController,
                  suggestions: category.suggestions,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class _SuggestionList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Suggestion> suggestions;

  const _SuggestionList({
    required this.scrollController,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: T(S.of(context).no_data, s: const TS(s: 16)),
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: suggestions.length,
      padding: EI.o(t: 8, b: 40),
      itemBuilder: (c, i) {
        final s = suggestions[i];
        return InkWell(
          child: Container(
            padding: const EI.s(v: 8, h: 12),
            child: T(s.display, s: const TS(s: 14, w: FW.w500)),
          ),
          onTap: () {
            Navigator.pop(context, s);
          },
        );
      },
    );
  }
}
