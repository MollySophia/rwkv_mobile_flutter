// ignore: unused_import
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/widgets/model_item.dart';

class ModelGroupItem extends ConsumerWidget {
  final WorldType worldType;

  const ModelGroupItem(this.worldType, {super.key});

  void _onDownloadAllTap() async {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    final missingFileKeys = fileKeys.where((e) => P.remoteFile.files(e).v.hasFile == false).toList();
    missingFileKeys.forEach((e) => P.remoteFile.getFile(fileKey: e));
  }

  void _onDeleteAllTap() async {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    fileKeys.forEach((e) => P.remoteFile.deleteFile(fileKey: e));
  }

  void _onStartToChatTap() async {
    if (P.rwkv.loading.v) {
      Alert.warning("Please wait for the model to load...");
      return;
    }
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    final encoderFileKey = fileKeys.firstWhere((e) => e.isEncoder);
    final modelFileKey = fileKeys.firstWhere((e) => !e.isEncoder);

    P.rwkv.loading.u(true);
    P.rwkv.currentWorldType.u(worldType);

    logTrace("worldType: $worldType");

    P.rwkv.clearStates();
    P.chat.messages.u([]);

    try {
      switch (worldType) {
        case WorldType.engAudioQA:
        case WorldType.chineseASR:
        case WorldType.engASR:
          await P.rwkv.loadWorldEngAudioQA(
            modelPath: modelFileKey.path,
            encoderPath: encoderFileKey.path,
            backend: modelFileKey.backend,
          );
        case WorldType.engVisualQA:
          await P.rwkv.loadWorldVision(
            modelPath: modelFileKey.path,
            encoderPath: encoderFileKey.path,
            backend: modelFileKey.backend,
          );
        // throw "Not implemented";
      }
      Navigator.pop(getContext()!);
    } catch (e) {
      if (kDebugMode) print("😡 $e");
      Alert.error(e.toString());
      P.rwkv.currentWorldType.u(null);
      return;
    } finally {
      P.rwkv.loading.u(false);
    }

    P.rwkv.currentModel.u(modelFileKey);
    Alert.success(S.current.you_can_now_start_to_chat_with_rwkv);
    pop();
  }

  void _onContinueTap() async {
    logTrace();
    pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    if (fileKeys.isEmpty) return const SizedBox.shrink();
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;

    final files = fileKeys.m((e) {
      return ref.watch(P.remoteFile.files(e));
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
            T(worldType.name.codeToName, s: const TS(s: 18, w: FW.w600)),
            ...fileKeys.m((e) => C(
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
                    child: const T(
                      "Download Missing",
                      s: TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (allDownloaded && !alreadyStarted)
                  TextButton(
                    onPressed: _onDeleteAllTap,
                    child: const T(
                      "Delete All",
                      s: TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (alreadyStarted)
                  TextButton(
                    onPressed: null,
                    child: const T(
                      "Exploring...",
                      s: TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (allDownloaded && !alreadyStarted)
                  TextButton(
                    onPressed: loading ? null : _onStartToChatTap,
                    child: T(
                      loading ? "Loading..." : "Start to Chat",
                      s: TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (alreadyStarted)
                  TextButton(
                    onPressed: loading ? null : _onContinueTap,
                    child: T(
                      loading ? "Loading..." : "Back to Chat",
                      s: TS(
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
