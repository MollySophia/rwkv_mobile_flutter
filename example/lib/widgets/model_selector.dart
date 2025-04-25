// ignore: unused_import
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:zone/func/gb_display.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/route/method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/tts_group_item.dart';
import 'package:zone/widgets/world_group_item.dart';
import 'package:zone/widgets/model_item.dart';

class ModelSelector extends ConsumerWidget {
  final ScrollController scrollController;

  const ModelSelector({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memUsed = ref.watch(P.device.memUsed);
    final memFree = ref.watch(P.device.memFree);
    final paddingBottom = ref.watch(P.app.paddingBottom);

    final memUsedString = gbDisplay(memUsed);
    final memFreeString = gbDisplay(memFree);
    final demoType = ref.watch(P.app.demoType);
    final hasDownloadedModels = ref.watch(P.fileManager.hasDownloadedModels);
    final availableModels = ref.watch(P.fileManager.availableModels);
    final ttsCores = ref.watch(P.fileManager.ttsCores);

    return ClipRRect(
      borderRadius: 16.r,
      child: C(
        margin: const EI.o(t: 12),
        child: ListView(
          padding: const EI.o(l: 8, r: 8),
          controller: scrollController,
          children: [
            Ro(
              children: [
                Exp(child: T(S.current.chat_welcome_to_use(Config.appTitle), s: const TS(s: 18, w: FW.w600))),
                IconButton(
                  onPressed: () {
                    pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (demoType == DemoType.chat) T(S.current.chat_please_select_a_model, s: const TS(s: 16, w: FW.w500)),
            if (demoType == DemoType.world) T(S.current.please_select_a_world_type, s: const TS(s: 16, w: FW.w500)),
            if (!hasDownloadedModels) 4.h,
            if (!hasDownloadedModels) T(S.current.chat_you_need_download_model_if_you_want_to_use_it),
            4.h,
            T(S.current.ensure_you_have_enough_memory_to_load_the_model, s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.memory_used(memUsedString, memFreeString), s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.download_source, s: TS(c: kB.wo(0.7), s: 14, w: FW.w600)),
            4.h,
            const _DownloadSource(),
            4.h,
            if (demoType == DemoType.world)
              for (final worldType in WorldType.values) WorldGroupItem(worldType),
            if (demoType == DemoType.tts)
              for (final fileInfo in ttsCores) TTSGroupItem(fileInfo),
            if (demoType == DemoType.chat)
              for (final fileInfo in availableModels.sorted((a, b) {
                return a.fileSize.compareTo(b.fileSize);
              }).sorted((a, b) {
                return (a.isDebug ? 1 : 0).compareTo((b.isDebug ? 1 : 0));
              }).sorted((a, b) {
                final aIsDownloaded = P.fileManager.locals(a).q.hasFile ? 1 : 0;
                final bIsDownloaded = P.fileManager.locals(b).q.hasFile ? 1 : 0;
                return bIsDownloaded.compareTo(aIsDownloaded);
              }))
                ModelItem(fileInfo),
            16.h,
            paddingBottom.h,
          ],
        ),
      ),
    );
  }
}

class _DownloadSource extends ConsumerWidget {
  const _DownloadSource();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSource = ref.watch(P.fileManager.downloadSource);
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      runSpacing: 4,
      spacing: 4,
      children: FileDownloadSource.values.where((e) => kDebugMode ? true : !e.isDebug).map((e) {
        return GD(
          onTap: () {
            P.fileManager.downloadSource.u(e);
          },
          child: C(
            decoration: BD(
              color: e == currentSource ? primary : kC,
              borderRadius: 4.r,
              border: Border.all(
                color: primary,
              ),
            ),
            padding: const EI.s(h: 6, v: 4),
            child: T(
              e.name,
              s: TS(c: e == currentSource ? kW : kB.wo(0.7), s: 14),
            ),
          ),
        );
      }).toList(),
    );
  }
}
