// ignore: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/state/p.dart';

enum ReasoningOption {
  language,
  pseudo;

  IconData get icon => switch (this) {
    ReasoningOption.language => Icons.translate,
    ReasoningOption.pseudo => Icons.bolt,
  };
}

class ReasoningOptionButton extends ConsumerWidget {
  final ReasoningOption option;

  const ReasoningOptionButton({super.key, required this.option});

  void _onTap() async {
    final loading = P.rwkv.loading.q;
    if (loading) {
      Alert.info(S.current.please_wait_for_the_model_to_load);
      return;
    }
    final receiving = P.chat.receivingTokens.q;
    if (receiving) {
      Alert.info(S.current.please_wait_for_the_model_to_finish_generating);
      return;
    }
    final currentModel = P.rwkv.currentModel.q;
    if (currentModel == null) {
      if (P.fileManager.modelSelectorShown.q) return;
      P.fileManager.modelSelectorShown.q = true;
      return;
    }

    switch (option) {
      case ReasoningOption.language:
        final newValue = !P.rwkv.preferChinese.q;
        await P.rwkv.setModelConfig(preferChinese: newValue);

        if (newValue) Alert.success(S.current.prefer_chinese);
        break;
      case ReasoningOption.pseudo:
        final newValue = !P.rwkv.preferPseudo.q;
        await P.rwkv.setModelConfig(preferPseudo: newValue);
        if (newValue) Alert.success(S.current.quick_thinking_enabled);
        break;
    }

    P.app.hapticLight();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final preferChinese = ref.watch(P.rwkv.preferChinese);
    final preferPseudo = ref.watch(P.rwkv.preferPseudo);
    final loading = ref.watch(P.rwkv.loading);
    final kW = ref.watch(P.app.qw);
    final kB = ref.watch(P.app.qb);

    final iconColor = switch (option) {
      ReasoningOption.language => preferChinese ? kW : kB.q(.25),
      ReasoningOption.pseudo => preferPseudo ? kW : kB.q(.25),
    };

    final buttonColor = switch (option) {
      ReasoningOption.language => preferChinese ? primary : kC,
      ReasoningOption.pseudo => preferPseudo ? primary : kC,
    };

    final buttonBorderColor = switch (option) {
      ReasoningOption.language => preferChinese ? primary.q(.5) : kB.q(.25),
      ReasoningOption.pseudo => preferPseudo ? primary.q(.5) : kB.q(.25),
    };

    final contentPadding = switch (option) {
      ReasoningOption.language => preferChinese ? const EI.o(l: 4, r: 8, t: 4, b: 4) : const EI.o(l: 4, r: 8, t: 4, b: 4),
      ReasoningOption.pseudo => preferPseudo ? const EI.o(l: 4, r: 8, t: 4, b: 4) : const EI.o(l: 4, r: 4, t: 4, b: 4),
    };

    final locale = ref.watch(P.preference.preferredLanguage);

    return AnimatedOpacity(
      opacity: loading ? .33 : 1,
      duration: 250.ms,
      child: GD(
        onTap: _onTap,
        child: C(
          decoration: BD(
            color: buttonColor,
            border: Border.all(color: buttonBorderColor),
            borderRadius: 12.r,
          ),
          padding: contentPadding,
          child: Ro(
            c: CAA.center,
            children: [
              Icon(option.icon, color: iconColor),
              2.w,
              Co(
                c: CAA.start,
                m: MAA.center,
                children: [
                  if (option == ReasoningOption.language) ...[
                    if (preferChinese) T(s.prefer, s: TS(c: kW, s: 10, height: 1)),
                    if (preferChinese) T(s.chinese, s: TS(c: kW, s: 10, height: 1)),
                    if (!preferChinese && !preferPseudo) T(s.auto, s: TS(c: kB.q(.25), s: 10, height: 1)),
                  ] else if (option == ReasoningOption.pseudo) ...[
                    if (preferPseudo && locale.resolved.isCJK) T(s.prefer, s: TS(c: kW, s: 10, height: 1)),
                    if (preferPseudo && !locale.resolved.isCJK) T("Quick", s: TS(c: kW, s: 10, height: 1)),
                    if (preferPseudo) 2.h,
                    if (preferPseudo && locale.resolved.isCJK) T(s.quick_thinking, s: TS(c: kW, s: 10, height: 1)),
                    if (preferPseudo && !locale.resolved.isCJK) T("Reason", s: TS(c: kW, s: 10, height: 1)),
                  ] else
                    ...[],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
