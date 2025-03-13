// ignore: unused_import
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:zone/func/gb_display.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/route/method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/model_group_item.dart';
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

    return ClipRRect(
      borderRadius: 16.r,
      child: C(
        margin: const EI.o(t: 16),
        child: ListView(
          padding: const EI.o(t: 24, l: 8, r: 8),
          controller: scrollController,
          children: [
            Ro(
              children: [
                Exp(child: T(S.current.chat_welcome_to_use("RWKV Chat"), s: const TS(s: 18, w: FW.w600))),
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
            4.h,
            T(S.current.chat_you_need_download_model_if_you_want_to_use_it),
            4.h,
            T(S.current.ensure_you_have_enough_memory_to_load_the_model, s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.memory_used(memUsedString, memFreeString), s: TS(c: kB.wo(0.7), s: 12)),
            4.h,
            T(S.current.download_source, s: TS(c: kB.wo(0.7), s: 14, w: FW.w600)),
            4.h,
            _DownloadSource(),
            4.h,
            if (demoType == DemoType.world)
              for (final worldType in WorldType.values) ModelGroupItem(worldType),
            if (demoType == DemoType.chat || kDebugMode)
              for (final fileKey in FileKey.availableModels) ModelItem(fileKey),
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
    final currentSource = ref.watch(P.remoteFile.currentSource);
    return Wrap(
      runSpacing: 4,
      spacing: 4,
      children: RemoteFileSource.values.where((e) => kDebugMode ? true : !e.isDebug).map((e) {
        return GD(
          onTap: () {
            P.remoteFile.currentSource.u(e);
          },
          child: C(
            decoration: BD(
              color: e == currentSource ? kCB : kC,
              borderRadius: 8.r,
              border: Border.all(
                color: kCB,
              ),
            ),
            padding: const EI.a(4),
            child: T(
              e.name,
              s: TS(c: e == currentSource ? kW : kB.wo(0.7), s: 12),
            ),
          ),
        );
      }).toList(),
    );
  }
}
