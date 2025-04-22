// ignore: unused_import
import 'dart:developer';
import 'dart:io';

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
    final selectSpkName = ref.watch(P.tts.selectSpkName);
    final primary = Theme.of(context).colorScheme.primary;
    final selectSourceAudioPath = ref.watch(P.tts.selectSourceAudioPath);
    final sourceWavName = selectSourceAudioPath?.split("/").last;
    return Co(
      c: CAA.stretch,
      children: [
        if (selectSpkName != null)
          C(
            padding: const EI.s(v: 4),
            child: T("Target: " + (P.tts.safe(selectSpkName)), s: TS(c: primary, w: FW.w600)),
          ),
        if (selectSourceAudioPath != null)
          C(
            padding: const EI.s(v: 4),
            child: T("Source: " + (sourceWavName ?? ""), s: TS(c: primary, w: FW.w600)),
          ),
        const _Actions(),
        if (audioInteractorShown) const _AudioInteractor(),
        if (spkShown) const _SpkPanel(),
        if (intonationShown) const _Intonation(),
        if (!audioInteractorShown && !intonationShown && !spkShown) const _Instruction(),
      ],
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

    P.tts.selectSourceAudioPath.u(path);
    P.tts.selectSpkName.u(null);
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

class _Intonation extends ConsumerWidget {
  const _Intonation();

  void _onTap(String e) {
    qqq(e);
    P.chat.textEditingController.text += e;
    Gaimon.light();
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
                  border: Border.all(color: kB.wo(0.5), width: 0.5),
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
            color: primary.wo(audioInteractorShown ? 1 : 0.1),
            borderRadius: borderRadius,
          ),
          child: T(
            "声音克隆" + (audioInteractorShown ? " ×" : ""),
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
            color: primary.wo(spkShown ? 1 : 0.1),
            borderRadius: borderRadius,
          ),
          child: T(
            "预置声音" + (spkShown ? " ×" : ""),
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
            color: primary.wo(intonationShown ? 1 : 0.1),
            borderRadius: borderRadius,
          ),
          child: T(
            "Intonation" + (intonationShown ? " ×" : ""),
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

    return Ro(
      children: [
        const _AudioButton(),
        const _SpkButton(),
        const _IntonationButton(),
        const Spacer(),
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
                        color: color.wo(0.5),
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
            opacity: (canSend && loaded) ? 1 : 0.333,
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
    final spkNames = ref.watch(P.tts.spkNames);
    final selectSpkName = ref.watch(P.tts.selectSpkName);
    final primary = Theme.of(context).colorScheme.primary;
    return SB(
      height: 250,
      child: RawScrollbar(
        padding: const EI.o(t: 12, b: 12),
        child: ListView.builder(
          padding: const EI.o(t: 12, b: 12),
          itemCount: spkNames.length,
          itemBuilder: (context, index) {
            final spkName = spkNames[index];

            final selected = selectSpkName == spkName;
            return GD(
              onTap: () {
                P.tts.selectSpkName.u(spkName);
                P.tts.selectSourceAudioPath.u(null);
                Gaimon.light();
              },
              child: C(
                padding: const EI.o(t: 4, b: 4, l: 8, r: 8),
                decoration: BD(
                  color: selected ? primary.wo(0.1) : kC,
                  borderRadius: 6.r,
                ),
                child: Ro(
                  children: [
                    Exp(
                      child: T(
                        P.tts.safe(spkName),
                        s: TS(c: selected ? primary : primary.wo(0.8), w: selected ? FW.w600 : FW.w400),
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
            );
          },
        ),
      ),
    );
  }
}

class _Instruction extends ConsumerWidget {
  const _Instruction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Co(
      children: [
        _TextField(),
        _InstructActions(),
      ],
    );
  }
}

class _InstructActions extends ConsumerWidget {
  const _InstructActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(P.rwkv.loaded);
    final loading = ref.watch(P.rwkv.loading);
    bool enabled = loaded && !loading;

    return Ro(
      children: [
        Exp(
          child: Wrap(
            // runSpacing: 4,
            spacing: 4,
            children: TTSInstruction.values.where((e) => e.forInstruction).indexMap((index, e) {
              return GD(
                onTap: () {
                  if (!enabled) return;
                  // TODO: 添加指令
                  Gaimon.light();
                },
                child: AnimatedOpacity(
                  opacity: enabled ? 1 : 0.333,
                  duration: 250.ms,
                  child: C(
                    margin: EI.o(t: 4),
                    padding: const EI.o(l: 8, r: 8, t: 4, b: 4),
                    decoration: BD(
                      color: kC,
                      border: Border.all(color: kB.wo(0.5), width: 0.5),
                      borderRadius: 4.r,
                    ),
                    child: T(e.toString().split(".").last),
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
                    opacity: textInInput.trim().isNotEmpty ? 1 : 0.5,
                    duration: 250.ms,
                    child: C(
                      padding: EI.s(v: 6, h: 4),
                      child: Icon(Icons.clear),
                    ),
                  ),
                ),
                GD(
                  onTap: P.tts.onRefreshButtonPressed,
                  child: C(
                    padding: EI.s(v: 6, h: 4),
                    child: Icon(Icons.refresh),
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
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.wo(0.33)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: primary.wo(0.33)),
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

  void _onTapOutside(PointerDownEvent event) {
    qq;
  }

  void _onKeyEvent(KeyEvent event) {
    qq;
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
    final loaded = P.rwkv.loaded.v;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.u(true);
      return;
    }
  }
}
