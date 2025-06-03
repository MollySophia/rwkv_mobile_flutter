import 'package:flutter/foundation.dart';
import 'package:zone/config.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/state/p.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/widgets/pager.dart';

class Debugger extends ConsumerWidget {
  const Debugger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return const SizedBox.shrink();
    if (!kDebugMode) return const SizedBox.shrink();
    final demoType = ref.watch(P.app.demoType);

    final kW = ref.watch(P.app.qw);

    switch (demoType) {
      case DemoType.sudoku:
        return const _SudokuDebugger();
      case DemoType.tts:
        return const _TTSDebugger();
      case DemoType.chat:
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.world:
    }

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final currentModel = ref.watch(P.rwkv.currentModel);
    final visualFloatHeight = ref.watch(P.world.visualFloatHeight);
    final loading = ref.watch(P.rwkv.loading);
    final playing = ref.watch(P.world.playing);
    final latestClickedMessage = ref.watch(P.chat.latestClickedMessage);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final hasFocus = ref.watch(P.chat.hasFocus);
    final isOthello = demoType == DemoType.othello;
    final paddingTop = ref.watch(P.app.paddingTop);
    final page = ref.watch(Pager.page);
    final atMainPage = ref.watch(Pager.atMainPage);
    final conversation = ref.watch(P.conversation.current);
    final editingIndex = ref.watch(P.chat.editingIndex);
    final receiveId = ref.watch(P.chat.receiveId);
    final kB = ref.watch(P.app.qb);
    final drawerWidth = ref.watch(Pager.drawerWidth);
    final screenWidth = ref.watch(P.app.screenWidth);
    final thinkingMode = ref.watch(P.rwkv.thinkingMode);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Material(
          textStyle: TS(
            ff: "Monospace",
            c: kW,
            s: 8,
          ),
          color: kC,
          child: SB(
            child: C(
              decoration: const BD(color: kC),
              child: Column(
                mainAxisAlignment: MAA.start,
                crossAxisAlignment: CAA.end,
                children:
                    [
                      paddingTop.h,
                      if (currentWorldType != null && !isOthello) T("currentWorldType".codeToName),
                      if (currentWorldType != null && !isOthello) T(currentWorldType.toString()),
                      if (currentWorldType != null && !isOthello) T("visualFloatHeight".codeToName),
                      if (currentWorldType != null) T(visualFloatHeight.toString()),
                      T("currentModel".codeToName),
                      T(currentModel?.fileName ?? "null"),
                      T("loading".codeToName),
                      T(loading.toString()),
                      if (currentWorldType != null) T("playing".codeToName),
                      if (currentWorldType != null) T(playing.toString()),
                      if (!isOthello) T("latestClickedMessage".codeToName),
                      T((latestClickedMessage?.id.toString() ?? "null")),
                      if (!isOthello) T("inputHeight".codeToName),
                      T(inputHeight.toString()),
                      if (!isOthello) T("hasFocus".codeToName),
                      T(hasFocus.toString()),
                      T("atMainPage".codeToName),
                      T(atMainPage.toString()),
                      T("page".codeToName),
                      T(page.toString()),
                      if (Config.enableConversation) T("conversation".codeToName),
                      if (Config.enableConversation) T(conversation?.name ?? "null"),
                      // T("receivingTokens".codeToName),
                      // T(receivingTokens.toString()),
                      T("receiveId".codeToName),
                      T(receiveId.toString()),
                      // T("lifecycleState".codeToName),
                      // T(lifecycleState.toString().split(".").last),
                      // T("autoPauseId".codeToName),
                      // T(autoPauseId.toString()),
                      T("editingIndex".codeToName),
                      T(editingIndex.toString()),
                      T("drawerWidth".codeToName),
                      T(drawerWidth.toString()),
                      T("screenWidth".codeToName),
                      T(screenWidth.toString()),
                      T("thinkingMode".codeToName),
                      T(thinkingMode.toString()),
                      T("editingBotMessage".codeToName),
                      T(editingBotMessage.toString()),
                    ].indexMap((index, e) {
                      return C(
                        margin: EI.o(t: index % 2 == 0 ? 0 : 1),
                        decoration: BD(color: kB.q(.55)),
                        child: e,
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SudokuDebugger extends ConsumerWidget {
  const _SudokuDebugger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddingTop = ref.watch(P.app.paddingTop);
    final loaded = ref.watch(P.rwkv.loaded);
    final running = ref.watch(P.sudoku.running);
    final page = ref.watch(Pager.page);
    final mainPageNotIgnoring = ref.watch(Pager.atMainPage);

    final kW = ref.watch(P.app.qw);
    final kB = ref.watch(P.app.qb);

    final modelSelectorShown = ref.watch(P.fileManager.modelSelectorShown);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Material(
          textStyle: TS(
            ff: "Monospace",
            c: kW,
            s: 8,
          ),
          color: kC,
          child: SB(
            child: C(
              decoration: const BD(color: kC),
              child: Column(
                mainAxisAlignment: MAA.start,
                crossAxisAlignment: CAA.end,
                children:
                    [
                      paddingTop.h,
                      T("paddingTop".codeToName),
                      T(paddingTop.toString()),
                      T("loaded".codeToName),
                      T(loaded.toString()),
                      T("running".codeToName),
                      T(running.toString()),
                      T("page".codeToName),
                      T(page.toString()),
                      T("mainPageNotIgnoring".codeToName),
                      T(mainPageNotIgnoring.toString()),
                      T("modelSelectorShown".codeToName),
                      T(modelSelectorShown.toString()),
                    ].indexMap((index, e) {
                      return C(
                        margin: EI.o(t: index % 2 == 0 ? 0 : 1),
                        decoration: BD(color: kB.q(.66)),
                        child: e,
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TTSDebugger extends ConsumerWidget {
  const _TTSDebugger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioInteractorShown = ref.watch(P.tts.audioInteractorShown);
    final endTime = ref.watch(P.world.endTime);
    final filePaths = ref.watch(P.tts.filePaths);
    final interactingInstruction = ref.watch(P.tts.interactingInstruction);
    final intonationShown = ref.watch(P.tts.intonationShown);
    final kB = ref.watch(P.app.qb);
    final overallProgress = ref.watch(P.tts.overallProgress);
    final paddingTop = ref.watch(P.app.paddingTop);
    final perWavProgress = ref.watch(P.tts.perWavProgress);
    final receiveId = ref.watch(P.chat.receiveId);
    final recording = ref.watch(P.world.recording);
    final selectSourceAudioPath = ref.watch(P.tts.selectSourceAudioPath);
    final selectSpkName = ref.watch(P.tts.selectedSpkName);
    final selectedIndex = ref.watch(P.tts.instructions(interactingInstruction));
    final selectedInstruction = selectedIndex != null ? interactingInstruction.options[selectedIndex] : null;
    final selectedLanguage = ref.watch(P.tts.selectedLanguage);
    final selectedSpkName = ref.watch(P.tts.selectedSpkName);
    final selectedSpkPanelFilter = ref.watch(P.tts.selectedSpkPanelFilter);
    final spkNames = ref.watch(P.tts.spkPairs);
    final spkShown = ref.watch(P.tts.spkShown);
    final startTime = ref.watch(P.world.startTime);
    final textInInput = ref.watch(P.tts.textInInput);
    final ttsDone = ref.watch(P.tts.ttsDone);

    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Material(
          textStyle: const TS(
            ff: "Monospace",
            c: kW,
            s: 8,
          ),
          color: kC,
          child: SB(
            child: C(
              decoration: const BD(color: kC),
              child: Column(
                mainAxisAlignment: MAA.start,
                crossAxisAlignment: CAA.end,
                children:
                    [
                      paddingTop.h,
                      T("paddingTop".codeToName),
                      T(paddingTop.toString()),
                      T("overallProgress".codeToName),
                      T(overallProgress.toString()),
                      T("perWavProgress".codeToName),
                      T(perWavProgress.toString()),
                      T("filePaths".codeToName),
                      Column(
                        children: filePaths.map((e) => T(e)).toList(),
                      ),
                      T("receiveId".codeToName),
                      T(receiveId.toString()),
                      T("selectedSpkPanelFilter".codeToName),
                      T(selectedSpkPanelFilter.toString()),
                      T("selectedLanguage".codeToName),
                      T(selectedLanguage.toString()),
                      T("startTime".codeToName),
                      T(startTime.toString()),
                      T("endTime".codeToName),
                      T(endTime.toString()),
                      T("selectedSpkName".codeToName),
                      T(selectedSpkName.toString()),
                      T("selectSourceAudioPath".codeToName),
                      T(selectSourceAudioPath.toString()),
                      T("ttsDone".codeToName),
                      T(ttsDone.toString()),
                      T("spkNames length".codeToName),
                      T(spkNames.length.toString()),
                      T("spkShown".codeToName),
                      T(spkShown.toString()),
                      T("audioInteractorShown".codeToName),
                      T(audioInteractorShown.toString()),
                      T("intonationShown".codeToName),
                      T(intonationShown.toString()),
                      T("selectSpkName".codeToName),
                      T(selectSpkName.toString()),
                      T("selectSourceAudioPath".codeToName),
                      T(selectSourceAudioPath.toString()),
                      T("textInInput".codeToName),
                      T(textInInput.toString()),
                      // T("ttsCores".codeToName),
                      // T(ttsCores.map((e) => e.name).join("\n")),
                      T("interactingInstruction".codeToName),
                      T(interactingInstruction.toString()),
                      T("selectedInstruction".codeToName),
                      T(selectedInstruction.toString()),
                      T("recording".codeToName),
                      T(recording.toString()),
                    ].indexMap((index, e) {
                      return C(
                        margin: EI.o(t: index % 2 == 0 ? 0 : 1),
                        decoration: BD(color: kB.q(.66)),
                        child: e,
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
