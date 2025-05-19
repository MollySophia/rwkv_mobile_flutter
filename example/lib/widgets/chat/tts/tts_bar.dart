// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/language.dart';
import 'package:zone/model/tts_instruction.dart';
import 'package:zone/state/p.dart';
import 'package:file_picker/file_picker.dart';

class TTSBar extends ConsumerWidget {
  const TTSBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioInteractorShown = ref.watch(P.tts.audioInteractorShown);
    final intonationShown = ref.watch(P.tts.intonationShown);
    final spkShown = ref.watch(P.tts.spkShown);
    final selectedSpkName = ref.watch(P.tts.selectedSpkName);
    final selectedLanguage = ref.watch(P.tts.selectedLanguage);
    final primary = Theme.of(context).colorScheme.primary;
    final selectSourceAudioPath = ref.watch(P.tts.selectSourceAudioPath);
    final sourceWavName = selectSourceAudioPath?.split("/").last;
    final pairs = ref.watch(P.tts.spkPairs);

    String target = "";

    if (selectedSpkName != null) {
      target = S.current.imitate_target + ": " + (P.tts.safe(selectedSpkName));
      target += " " + pairs[selectedSpkName];
      final flag = selectedLanguage.flag;
      if (flag != null) target += " " + flag;
    }

    return GD(
      onTap: P.tts.dismissAllShown,
      child: C(
        decoration: const BD(color: kC),
        child: Co(
          c: CAA.stretch,
          children: [
            if (selectedSpkName != null)
              C(
                padding: const EI.s(v: 4),
                child: T(target, s: TS(c: primary, w: FW.w600)),
              ),
            if (selectSourceAudioPath != null)
              C(
                padding: const EI.s(v: 4),
                child: T(S.current.imitate_target + ": " + (sourceWavName ?? ""), s: TS(c: primary, w: FW.w600)),
              ),
            const _Actions(),
            if (audioInteractorShown) const _AudioInteractor(),
            if (spkShown) const _SpkPanel(),
            if (intonationShown) const _IntonationPanel(),
            if (!audioInteractorShown && !intonationShown && !spkShown && selectedSpkName == null) const _Instruction(),
          ],
        ),
      ),
    );
  }
}

class _AudioInteractor extends ConsumerWidget {
  const _AudioInteractor();

  void _onUploadFilePressed() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav'],
      allowMultiple: false,
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) {
      Alert.error("File path not found");
      return;
    }

    final extension = path.split('.').last;

    if (extension != 'wav') {
      Alert.error("File extension must be wav");
      return;
    }

    P.tts.selectSourceAudioPath.q = path;
    P.tts.selectedSpkName.q = null;
    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    return SB(
      height: 250,
      child: Co(
        children: [
          24.h,
          Ro(
            children: [
              24.w,
              Exp(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "You can record your voice and then let RWKV to copy it. ",
                        style: TS(
                          c: primary,
                          w: FW.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Or select a wav file to let RWKV to copy it.",
                        style: const TS(
                          c: Colors.blue,
                          w: FW.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _onUploadFilePressed,
                      ),
                      const WidgetSpan(
                          child: Icon(
                        Icons.upload_file,
                        color: Colors.blue,
                        size: 20,
                      )),
                    ],
                  ),
                ),
              ),
              24.w,
            ],
          ),
        ],
      ),
    );
  }
}

class _IntonationPanel extends ConsumerWidget {
  const _IntonationPanel();

  void _onTap(String e) {
    qq;
    final controller = P.chat.textEditingController;
    final selection = controller.selection;
    final text = controller.text;
    if (!selection.isValid) {
      controller.text += e;
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      Gaimon.light();
      return;
    }
    final newText = text.replaceRange(selection.start, selection.end, e);
    final newOffset = selection.start + e.length;
    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newOffset);
    Gaimon.light();
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SB(
      height: 250,
      child: Padding(
        padding: const EI.o(t: 12, b: 12),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: TTSInstruction.intonation.options.indexMap((index, e) {
            final emoji = TTSInstruction.intonation.emojiOptions[index];
            return GD(
              onTap: () {
                _onTap(e);
              },
              child: C(
                decoration: BD(
                  color: kC,
                  border: Border.all(color: kB.q(.5), width: .5),
                  borderRadius: 4.r,
                ),
                padding: const EI.o(l: 8, r: 8, t: 4, b: 4),
                child: T(emoji + e),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AudioButton extends ConsumerWidget {
  const _AudioButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final demoType = ref.watch(P.app.demoType);
    final borderRadius = demoType != DemoType.tts ? 12.r : 6.r;
    final audioInteractorShown = ref.watch(P.tts.audioInteractorShown);
    return GD(
      onTap: P.tts.onAudioInteractorButtonPressed,
      child: Padding(
        padding: const EI.o(l: 0, r: 4, t: 2, b: 6),
        child: C(
          padding: const EI.o(l: 8, r: 8, t: 6, b: 6),
          decoration: BD(
            color: primary.q(audioInteractorShown ? 1 : .1),
            borderRadius: borderRadius,
          ),
          child: T(
            S.current.voice_cloning + (audioInteractorShown ? " ×" : ""),
            s: TS(c: audioInteractorShown ? kW : primary),
          ),
        ),
      ),
    );
  }
}

class _SpkButton extends ConsumerWidget {
  const _SpkButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final primary = Theme.of(context).colorScheme.primary;
    final demoType = ref.watch(P.app.demoType);
    final borderRadius = demoType != DemoType.tts ? 12.r : 6.r;
    final intonationShown = ref.watch(P.tts.intonationShown);
    final audioInteractorShown = ref.watch(P.tts.audioInteractorShown);
    final spkShown = ref.watch(P.tts.spkShown);
    return GD(
      onTap: P.tts.onSpkButtonPressed,
      child: Padding(
        padding: const EI.o(l: 0, r: 4, t: 2, b: 6),
        child: C(
          padding: const EI.o(l: 8, r: 8, t: 6, b: 6),
          decoration: BD(
            color: primary.q(spkShown ? 1 : .1),
            borderRadius: borderRadius,
          ),
          child: T(
            S.current.prebuilt_voices + (spkShown ? " ×" : ""),
            s: TS(c: spkShown ? kW : primary),
          ),
        ),
      ),
    );
  }
}

class _IntonationButton extends ConsumerWidget {
  const _IntonationButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final demoType = ref.watch(P.app.demoType);
    final borderRadius = demoType != DemoType.tts ? 12.r : 6.r;
    final intonationShown = ref.watch(P.tts.intonationShown);
    return GD(
      onTap: P.tts.onIntonationButtonPressed,
      child: Padding(
        padding: const EI.o(l: 0, r: 4, t: 2, b: 6),
        child: C(
          padding: const EI.o(l: 8, r: 8, t: 6, b: 6),
          decoration: BD(
            color: primary.q(intonationShown ? 1 : .1),
            borderRadius: borderRadius,
          ),
          child: T(
            S.current.intonations + (intonationShown ? " ×" : ""),
            s: TS(c: intonationShown ? kW : primary),
          ),
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsDone = ref.watch(P.tts.ttsDone);
    final canSend = ref.watch(P.chat.canSend);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);
    final color = Theme.of(context).colorScheme.primary;
    final loaded = ref.watch(P.rwkv.loaded);
    final interactingInstruction = ref.watch(P.tts.interactingInstruction);

    final audioInteractorShown = ref.watch(P.tts.audioInteractorShown);
    final intonationShown = ref.watch(P.tts.intonationShown);
    final spkShown = ref.watch(P.tts.spkShown);

    return Ro(
      children: [
        Exp(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const _AudioButton(),
              const _SpkButton(),
              const _IntonationButton(),
              if (!audioInteractorShown && !intonationShown && !spkShown && interactingInstruction == TTSInstruction.none) const _PerformanceInfo(),
            ],
          ),
        ),
        if (!ttsDone)
          C(
            decoration: const BD(color: kC),
            child: Stack(
              children: [
                SizedBox(
                  width: 46,
                  height: 34,
                  child: Center(
                    child: C(
                      decoration: BD(color: kC, borderRadius: 2.r),
                      width: 12,
                      height: 12,
                    ),
                  ),
                ),
                SB(
                  width: 46,
                  height: 34,
                  child: Center(
                    child: SB(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: color.q(.5),
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (ttsDone)
          AnimatedOpacity(
            opacity: (canSend && loaded) ? 1 : .333,
            duration: 250.ms,
            child: GD(
              onTap: _onRightButtonPressed,
              child: C(
                padding: const EI.s(h: 10, v: 5),
                child: Icon(
                  (Platform.isIOS || Platform.isMacOS)
                      ? editingBotMessage
                          ? CupertinoIcons.pencil_circle_fill
                          : CupertinoIcons.arrow_up_circle_fill
                      : editingBotMessage
                          ? Icons.edit
                          : Icons.send,
                  color: color,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onRightButtonPressed() async {
    qq;
    await P.tts.gen();
  }
}

class _SpkPanel extends ConsumerWidget {
  const _SpkPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spkPairs = ref.watch(P.tts.spkPairs);
    var spkNames = spkPairs.keys;
    final selectSpkName = ref.watch(P.tts.selectedSpkName);
    final primary = Theme.of(context).colorScheme.primary;
    final controller = ScrollController();

    final selectedLanguage = ref.watch(P.tts.selectedLanguage);
    final selectedSpkPanelFilter = ref.watch(P.tts.selectedSpkPanelFilter);

    switch (selectedSpkPanelFilter) {
      case Language.none:
      case Language.en:
        spkNames = spkPairs.keys.where((e) => e.contains(Language.en.enName!));
      case Language.ja:
        spkNames = spkPairs.keys.where((e) => e.contains(Language.ja.enName!));
      case Language.ko:
        spkNames = spkPairs.keys.where((e) => e.contains(Language.ko.enName!));
      case Language.zh_Hans:
        spkNames = spkPairs.keys.where((e) => e.contains(Language.zh_Hans.enName!));
      case Language.zh_Hant:
        spkNames = spkPairs.keys.where((e) => e.contains(Language.zh_Hans.enName!));
    }

    return SB(
      height: 250,
      child: Co(
        c: CAA.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Ro(
              children: [Language.zh_Hans, Language.en, Language.ja].m((e) {
                final flag = e.flag;
                final localizedName = e.soundDisplay;
                final selected = selectedLanguage == e;
                final filtered = selectedSpkPanelFilter == e;

                return GD(
                  onTap: () {
                    P.tts.selectedSpkPanelFilter.q = e;
                    Gaimon.light();
                  },
                  child: C(
                    padding: const EI.s(h: 4, v: 2),
                    margin: const EI.o(r: 4),
                    decoration: BD(
                      color: filtered ? primary.q(.1) : kC,
                      borderRadius: 4.r,
                      border: Border.all(color: kB.q(.5), width: .5),
                    ),
                    child: Ro(
                      children: [
                        T((flag ?? "") + " " + (localizedName ?? "")),
                        if (selected) 4.w,
                        if (selected) Icon(Icons.circle, color: primary, size: 8),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Exp(
            child: RawScrollbar(
              controller: controller,
              padding: const EI.o(t: 12, b: 12),
              child: ListView.builder(
                controller: controller,
                padding: const EI.o(t: 12, b: 12),
                itemCount: spkNames.length,
                itemBuilder: (context, index) {
                  final k = spkNames.elementAt(index);
                  final v = spkPairs[k];

                  final selected = selectSpkName == k;

                  final language = Language.values.where((e) => e.enName != null).firstWhereOrNull((e) => k.contains(e.enName!));

                  final display = P.tts.safe(k) + " " + P.tts.safe(v) + " " + (language?.flag ?? "");

                  return GD(
                      onTap: () {
                        qq;
                        P.tts.selectedSpkName.q = k;
                        P.tts.selectSourceAudioPath.q = null;
                        Gaimon.light();
                      },
                      child: Ro(
                        children: [
                          Exp(
                            child: C(
                              padding: const EI.o(t: 4, b: 4, l: 8, r: 8),
                              decoration: BD(
                                color: selected ? primary.q(.1) : kC,
                                borderRadius: 6.r,
                              ),
                              child: Ro(
                                children: [
                                  Exp(
                                    child: T(
                                      display,
                                      s: TS(c: selected ? primary : primary.q(.8), w: selected ? FW.w600 : FW.w400),
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check,
                                      color: primary,
                                      size: 14,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          GD(
                            onTap: () async {
                              final path = await P.tts.getPrebuiltSpkAudioPathFromTemp(k);
                              P.chat.latestClickedMessage.q = null;
                              await P.world.play(path: path);
                            },
                            child: C(
                              padding: const EI.a(6.5),
                              decoration: const BD(color: kC),
                              child: Icon(
                                Icons.volume_up,
                                color: primary,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Instruction extends ConsumerWidget {
  const _Instruction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFocus = ref.watch(P.tts.hasFocus);
    final interactingInstruction = ref.watch(P.tts.interactingInstruction);
    final primary = Theme.of(context).colorScheme.primary;
    final selectSpkName = ref.watch(P.tts.selectedSpkName);
    return Stack(
      children: [
        if (selectSpkName == null)
          Co(
            c: CAA.stretch,
            children: [
              const _TextField(),
              if (!hasFocus) const _InstructTabs(),
              if (!hasFocus && interactingInstruction != TTSInstruction.none) const _InstructOptions(),
            ],
          ),
      ],
    );
  }
}

class _InstructTabs extends ConsumerWidget {
  const _InstructTabs();

  void _onTap(TTSInstruction e) {
    qq;
    if (P.tts.interactingInstruction.q == e) {
      P.tts.interactingInstruction.q = TTSInstruction.none;
    } else {
      P.tts.interactingInstruction.q = e;
    }

    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(P.rwkv.loaded);
    final loading = ref.watch(P.rwkv.loading);
    bool enabled = loaded && !loading;

    final primary = Theme.of(context).colorScheme.primary;

    final i1 = ref.watch(P.tts.instructions(TTSInstruction.emotion));
    final i2 = ref.watch(P.tts.instructions(TTSInstruction.dialect));
    final i3 = ref.watch(P.tts.instructions(TTSInstruction.speed));
    final i4 = ref.watch(P.tts.instructions(TTSInstruction.role));
    final _ = ref.watch(P.tts.interactingInstruction);

    final isZh = Localizations.localeOf(context).languageCode == "zh";
    return Ro(
      children: [
        Exp(
          child: Wrap(
            // runSpacing: 4,
            spacing: 4,
            children: TTSInstruction.values.where((e) => e.forInstruction).indexMap((index, e) {
              final isSelected = P.tts.interactingInstruction.q == e;
              String displayText = isZh ? e.nameCN : e.nameEN;
              if (isSelected) displayText += " ×";

              bool hasValue = false;
              switch (e) {
                case TTSInstruction.none:
                case TTSInstruction.emotion:
                  hasValue = i1 != null;
                case TTSInstruction.dialect:
                  hasValue = i2 != null;
                case TTSInstruction.speed:
                  hasValue = i3 != null;
                case TTSInstruction.role:
                  hasValue = i4 != null;
                case TTSInstruction.intonation:
              }

              return GD(
                onTap: () {
                  if (!enabled) return;
                  _onTap(e);
                },
                child: AnimatedOpacity(
                  opacity: enabled ? 1 : .333,
                  duration: 250.ms,
                  child: C(
                    margin: const EI.o(t: 4),
                    padding: const EI.o(l: 8, r: 8, t: 4, b: 4),
                    decoration: BD(
                      color: isSelected ? primary.q(.2) : kC,
                      border: Border.all(color: kB.q(.5), width: .5),
                      borderRadius: 4.r,
                    ),
                    child: Ro(
                      c: CAA.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasValue)
                          Icon(
                            Icons.circle,
                            color: primary,
                            size: 8,
                          ),
                        if (hasValue) 4.w,
                        T(displayText),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _InstructOptions extends ConsumerWidget {
  const _InstructOptions();

  void _onTap(int index) {
    qq;
    Gaimon.light();
    final interactingInstruction = P.tts.interactingInstruction.q;
    if (interactingInstruction == TTSInstruction.none) return;
    if (P.tts.instructions(interactingInstruction).q == index) {
      P.tts.instructions(interactingInstruction).q = null;
    } else {
      P.tts.instructions(interactingInstruction).q = index;
    }
    P.tts.syncInstruction();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactingInstruction = ref.watch(P.tts.interactingInstruction);
    final primary = Theme.of(context).colorScheme.primary;
    final options = interactingInstruction.options;
    final selectedIndex = ref.watch(P.tts.instructions(interactingInstruction));
    final selectedInstruction = selectedIndex != null ? options[selectedIndex] : null;
    return GD(
      onTap: () {},
      child: AnimatedContainer(
        duration: 250.ms,
        height: interactingInstruction == TTSInstruction.none ? 0 : 150,
        margin: const EI.o(t: 4),
        decoration: BD(border: Border(top: BorderSide(color: kB.q(.5), width: .5))),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 4,
          children: options.indexMap((index, e) {
            bool selected = false;
            if (interactingInstruction != TTSInstruction.none) {
              selected = P.tts.instructions(interactingInstruction).q == index;
            }

            return GD(
              onTap: () {
                _onTap(index);
              },
              child: C(
                padding: const EI.o(l: 8, r: 8, t: 4, b: 4),
                margin: const EI.o(t: 4),
                decoration: BD(
                  color: selected ? primary.q(.2) : kC,
                  border: Border.all(color: kB.q(.5), width: .5),
                  borderRadius: 4.r,
                ),
                child: T(e + (selected ? " ×" : "")),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TextField extends ConsumerWidget {
  const _TextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final loaded = ref.watch(P.rwkv.loaded);
    final loading = ref.watch(P.rwkv.loading);
    final demoType = ref.watch(P.app.demoType);

    late final String hintText;
    switch (demoType) {
      case DemoType.chat:
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
      case DemoType.world:
        hintText = "";
      case DemoType.tts:
        hintText = "Enter your instruction here";
    }

    bool textFieldEnabled = loaded && !loading;

    final borderRadius = demoType != DemoType.tts ? 12.r : 6.r;

    final textInInput = ref.watch(P.tts.textInInput);

    return GD(
      onTap: textFieldEnabled ? null : _onTapTextFieldWhenItsDisabled,
      child: KeyboardListener(
        onKeyEvent: _onKeyEvent,
        focusNode: P.tts.focusNode,
        child: TextField(
          enabled: textFieldEnabled,
          controller: P.tts.textEditingController,
          onSubmitted: _onSubmitted,
          onChanged: _onChanged,
          onEditingComplete: _onEditingComplete,
          onAppPrivateCommand: _onAppPrivateCommand,
          onTap: _onTap,
          onTapOutside: _onTapOutside,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          textInputAction: TextInputAction.send,
          maxLines: 5,
          minLines: 1,
          decoration: InputDecoration(
            suffixIcon: Ro(
              mainAxisSize: MainAxisSize.min,
              children: [
                GD(
                  onTap: P.tts.onClearButtonPressed,
                  child: AnimatedOpacity(
                    opacity: textInInput.trim().isNotEmpty ? 1 : .5,
                    duration: 250.ms,
                    child: C(
                      padding: const EI.s(v: 6, h: 4),
                      child: const Icon(Icons.clear),
                    ),
                  ),
                ),
                GD(
                  onTap: P.tts.onRefreshButtonPressed,
                  child: C(
                    padding: const EI.s(v: 6, h: 4),
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
            contentPadding: const EI.o(
              l: 12,
              r: 8,
              t: 4,
              b: 4,
            ),
            fillColor: kW,
            focusColor: kW,
            hoverColor: kW,
            iconColor: kW,
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.q(.33)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.q(.33)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.q(.33)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.q(.33)),
            ),
            hintText: hintText,
          ),
        ),
      ),
    );
  }

  void _onChanged(String value) {}

  void _onSubmitted(String value) {}

  void _onEditingComplete() {}

  void _onTap() async {
    qq;
    await Future.delayed(const Duration(milliseconds: 300));
    await P.chat.scrollToBottom();
  }

  void _onAppPrivateCommand(String action, Map<String, dynamic> data) {}

  void _onTapOutside(PointerDownEvent event) {}

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
      P.tts.dismissAllShown();
      P.tts.gen();
    }
  }

  void _onTapTextFieldWhenItsDisabled() {
    qq;
    final loaded = P.rwkv.loaded.q;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.q = true;
      return;
    }
  }
}

class _PerformanceInfo extends ConsumerWidget {
  const _PerformanceInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefillSpeed = ref.watch(P.rwkv.prefillSpeed);
    final decodeSpeed = ref.watch(P.rwkv.decodeSpeed);
    if (prefillSpeed == 0 && decodeSpeed == 0) return const SizedBox.shrink();
    return Co(
      c: CAA.start,
      m: MAA.center,
      children: [
        T("Prefill: ${prefillSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.q(.6), s: 10)),
        T("Decode: ${decodeSpeed.toStringAsFixed(2)} t/s", s: TS(c: kB.q(.6), s: 10)),
        6.h,
      ],
    );
  }
}
