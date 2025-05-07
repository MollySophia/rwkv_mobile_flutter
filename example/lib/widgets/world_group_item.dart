// ignore: unused_import
import 'dart:developer';

import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/widgets/model_item.dart';

class WorldGroupItem extends ConsumerWidget {
  final WorldType worldType;

  const WorldGroupItem(this.worldType, {super.key});

  void _onDownloadAllTap() async {
    final availableModels = P.fileManager.availableModels.q;
    final fileInfos = availableModels.where((e) => e.worldType == worldType).toList();
    final missingFileInfos = fileInfos.where((e) => P.fileManager.locals(e).q.hasFile == false).toList();
    missingFileInfos.forEach((e) => P.fileManager.getFile(fileInfo: e));
  }

  void _onDeleteAllTap() async {
    final availableModels = P.fileManager.availableModels.q;
    final fileInfos = availableModels.where((e) => e.worldType == worldType).toList();
    fileInfos.forEach((e) => P.fileManager.deleteFile(fileInfo: e));
  }

  void _onStartToChatTap() async {
    if (P.rwkv.loading.q) {
      Alert.warning("Please wait for the model to load...");
      return;
    }
    final availableModels = P.fileManager.availableModels.q;
    final fileInfos = availableModels.where((e) => e.worldType == worldType).toList();
    final encoderFileKey = fileInfos.firstWhere((e) => e.isEncoder);
    final modelFileKey = fileInfos.firstWhere((e) => !e.isEncoder);
    final encoderLocalFile = P.fileManager.locals(encoderFileKey).q;
    final modelLocalFile = P.fileManager.locals(modelFileKey).q;

    P.rwkv.currentWorldType.q = worldType;

    qqq("worldType: $worldType");

    P.rwkv.clearStates();
    P.chat.clearMessages();

    try {
      switch (worldType) {
        case WorldType.engAudioQA:
        case WorldType.chineseASR:
        case WorldType.engASR:
          await P.rwkv.loadWorldEngAudioQA(
            modelPath: modelLocalFile.targetPath,
            encoderPath: encoderLocalFile.targetPath,
            backend: modelFileKey.backend!,
          );
        case WorldType.engVisualQA:
        case WorldType.visualQA:
        case WorldType.engVisualQAReason:
          await P.rwkv.loadWorldVision(
            modelPath: modelLocalFile.targetPath,
            encoderPath: encoderLocalFile.targetPath,
            backend: modelFileKey.backend!,
            usingReasoningModel: worldType.isReasoning,
          );
        // throw "Not implemented";
      }
      Navigator.pop(getContext()!);
    } catch (e) {
      qqe("$e");
      Alert.error(e.toString());
      P.rwkv.currentWorldType.q = null;
      return;
    }

    P.rwkv.currentModel.q = modelFileKey;
    Alert.success(S.current.you_can_now_start_to_chat_with_rwkv);
    pop();
  }

  void _onContinueTap() async {
    qq;
    pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableModels = P.fileManager.availableModels.q;
    final fileInfos = availableModels.where((e) => e.worldType == worldType).toList();
    if (fileInfos.isEmpty) return const SizedBox.shrink();
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;

    final files = fileInfos.m((e) {
      return ref.watch(P.fileManager.locals(e));
    });

    final allDownloaded = files.every((e) => e.hasFile);
    final allMissing = files.every((e) => !e.hasFile);
    final downloading = files.any((e) => e.downloading);

    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final alreadyStarted = currentWorldType == worldType;
    final loading = ref.watch(P.rwkv.loading);

    return ClipRRect(
      borderRadius: 8.r,
      child: C(
        decoration: BD(color: kW, borderRadius: 8.r),
        margin: const EI.o(t: 8),
        padding: const EI.o(t: 8, l: 8, r: 8),
        child: Co(
          c: CAA.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                T(worldType.displayName, s: const TS(s: 18, w: FW.w600)),
                T(worldType.taskDescription, s: const TS(s: 12, w: FW.w400)),
              ],
            ),
            ...fileInfos.m((e) => C(
                  decoration: BD(
                    color: kC,
                    border: Border.all(color: primaryColor),
                    borderRadius: 6.r,
                  ),
                  padding: const EI.s(v: 4, h: 4),
                  margin: const EI.o(t: 8),
                  child: FileKeyItem(e, showDownloaded: true),
                )),
            Ro(
              children: [
                if (downloading) 8.h,
                if (allMissing && !downloading)
                  TextButton(
                    onPressed: _onDownloadAllTap,
                    child: const T(
                      "Download All",
                      s: TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (!allMissing && !allDownloaded && !downloading)
                  TextButton(
                    onPressed: _onDownloadAllTap,
                    child: T(
                      S.current.download_missing,
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (allDownloaded && !alreadyStarted)
                  TextButton(
                    onPressed: _onDeleteAllTap,
                    child: T(
                      S.current.delete_all,
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (alreadyStarted)
                  TextButton(
                    onPressed: null,
                    child: T(
                      S.current.exploring,
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (allDownloaded && !alreadyStarted)
                  TextButton(
                    onPressed: loading ? null : _onStartToChatTap,
                    child: T(
                      loading ? S.current.loading : S.current.start_to_chat,
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (alreadyStarted)
                  TextButton(
                    onPressed: loading ? null : _onContinueTap,
                    child: T(
                      loading ? S.current.loading : S.current.back_to_chat,
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
