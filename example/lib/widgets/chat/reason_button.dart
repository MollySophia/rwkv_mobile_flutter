// ignore: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaimon/gaimon.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/state/p.dart';

class ReasonButton extends ConsumerWidget {
  const ReasonButton({super.key});

  void _onTap() async {
    final loading = P.rwkv.loading.q;
    if (loading) {
      Alert.info("Please wait for the model to load");
      return;
    }
    final receiving = P.chat.receivingTokens.q;
    if (receiving) {
      Alert.info("Please wait for the model to finish generating");
      return;
    }
    final currentModel = P.rwkv.currentModel.q;
    if (currentModel == null) {
      if (P.fileManager.modelSelectorShown.q) return;
      P.fileManager.modelSelectorShown.q = true;
      return;
    }
    final newValue = !P.rwkv.usingReasoningModel.q;
    await P.rwkv.setModelConfig(usingReasoningModel: newValue);

    if (newValue) Alert.success(S.current.reasoning_enabled);

    Gaimon.light();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final color = Theme.of(context).colorScheme.primary;
    final usingReasoningModel = ref.watch(P.rwkv.usingReasoningModel);
    final loading = ref.watch(P.rwkv.loading);
    final kW = ref.watch(P.app.qw);
    final kB = ref.watch(P.app.qb);
    return GD(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        decoration: BD(
          color: usingReasoningModel ? color : kC,
          border: Border.all(
            color: usingReasoningModel ? color.q(.5) : kB.q(.25),
          ),
          borderRadius: 12.r,
        ),
        padding: const EI.o(l: 4, r: 8, t: 4, b: 4),
        child: Ro(
          c: CAA.center,
          children: [
            if (!loading)
              Icon(
                Icons.emoji_objects_outlined,
                color: usingReasoningModel ? kW : kB.q(.25),
              ),
            if (loading)
              C(
                margin: const EI.o(l: 8, t: 6, b: 6, r: 10),
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                  color: usingReasoningModel ? kW : color,
                  strokeWidth: 2,
                ),
              ),
            if (!loading)
              T(
                s.reason,
                s: TS(c: usingReasoningModel ? kW : kB.q(.25)),
              ),
            if (loading)
              T(
                s.loading,
                s: TS(c: usingReasoningModel ? kW : color),
              ),
          ],
        ),
      ),
    );
  }
}
