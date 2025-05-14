// ignore: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/state/p.dart';

class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

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
    final newValue = !P.rwkv.preferChinese.q;
    await P.rwkv.setModelConfig(preferChinese: newValue);

    if (newValue) Alert.success(S.current.prefer_chinese);

    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.primary;
    final preferChinese = ref.watch(P.rwkv.preferChinese);
    final loading = ref.watch(P.rwkv.loading);
    return AnimatedOpacity(
      opacity: loading ? .33 : 1,
      duration: 250.ms,
      child: GD(
        onTap: _onTap,
        child: C(
          decoration: BD(
            color: preferChinese ? color : kC,
            border: Border.all(
              color: preferChinese ? color.q(.5) : kB.q(.25),
            ),
            borderRadius: 12.r,
          ),
          padding: const EI.o(l: 4, r: 8, t: 4, b: 4),
          child: Ro(
            c: CAA.center,
            children: [
              Icon(
                Icons.translate,
                color: preferChinese ? kW : kB.q(.25),
              ),
              2.w,
              Co(
                c: CAA.start,
                m: MAA.center,
                children: [
                  if (preferChinese) T(S.current.prefer, s: const TS(c: kW, s: 10, height: 1)),
                  if (preferChinese) T(S.current.chinese, s: const TS(c: kW, s: 10, height: 1)),
                  if (!preferChinese) T(S.current.auto, s: TS(c: kB.q(.25), s: 10, height: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
