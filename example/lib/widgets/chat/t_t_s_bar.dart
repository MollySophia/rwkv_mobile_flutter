// ignore: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/tts_instruction.dart';

class TTSBar extends ConsumerWidget {
  const TTSBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Co(
      c: CAA.stretch,
      children: [
        _Intonation(),
        _Instruction(),
      ],
    );
  }
}

class _Intonation extends ConsumerWidget {
  const _Intonation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: TTSInstruction.intonation.options.indexMap((index, e) {
        final emoji = TTSInstruction.intonation.emojiOptions[index];
        return GD(
          onTap: () {},
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
    );
  }
}

class _Instruction extends ConsumerWidget {
  const _Instruction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SB();
  }
}
