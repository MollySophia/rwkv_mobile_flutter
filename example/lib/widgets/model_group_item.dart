// ignore: unused_import
import 'dart:developer';

import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/alert.dart';
import 'package:zone/widgets/model_item.dart';

class ModelGroupItem extends ConsumerWidget {
  final WorldType worldType;

  const ModelGroupItem(this.worldType, {super.key});

  void _onDownloadAllTap() {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    fileKeys.forEach((e) => P.remoteFile.getFile(fileKey: e));
  }

  void _onDeleteAllTap() {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    fileKeys.forEach((e) => P.remoteFile.deleteFile(fileKey: e));
  }

  void _onStartToChatTap() async {
    logTrace();
    if (P.rwkv.loading.v) return;
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    final encoderFileKey = fileKeys.firstWhere((e) => e.isEncoder);
    final modelFileKey = fileKeys.firstWhere((e) => !e.isEncoder);

    P.rwkv.loading.u(true);
    P.rwkv.currentWorldType.u(worldType);
    try {
      P.rwkv.clearStates();
      P.chat.messages.u([]);
      await P.rwkv.loadWorldVision(
        modelPath: modelFileKey.path,
        visionEncoderPath: encoderFileKey.path,
        backend: modelFileKey.backend,
      );
      Navigator.pop(getContext()!);
    } catch (e) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileKeys = FileKey.availableModels.where((e) => e.worldType == worldType).toList();
    if (fileKeys.isEmpty) return const SizedBox.shrink();
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;
    final files = [
      ...fileKeys.m(
        (e) => ref.watch(
          P.remoteFile.files(e),
        ),
      ),
    ];
    final allDownloaded = files.every((e) => e.hasFile);
    final downloading = files.any((e) => e.downloading);
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
                  padding: EI.s(v: 4, h: 4),
                  margin: EI.o(t: 8),
                  child: FileKeyItem(e),
                )),
            Ro(
              children: [
                if (!allDownloaded && !downloading)
                  TextButton(
                    onPressed: _onDownloadAllTap,
                    child: T(
                      "Download All",
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                if (allDownloaded)
                  TextButton(
                    onPressed: _onDeleteAllTap,
                    child: T(
                      "Delete All",
                      s: const TS(
                        w: FW.w600,
                      ),
                    ),
                  ),
                Spacer(),
                if (allDownloaded)
                  TextButton(
                    onPressed: _onStartToChatTap,
                    child: T(
                      "Start to Chat",
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
