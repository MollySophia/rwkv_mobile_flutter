// ignore: unused_import
import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/config.dart';
import 'package:zone/func/gb_display.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_info.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class ModelItem extends ConsumerWidget {
  final FileInfo fileInfo;

  const ModelItem(this.fileInfo, {super.key});

  void _onStartTap() async {
    qq;
    if (P.rwkv.loading.v) return;
    final localFile = P.fileManager.locals(fileInfo).v;
    final modelPath = localFile.targetPath;
    final backend = localFile.fileInfo.backend;

    try {
      P.rwkv.clearStates();
      P.chat.messages.u([]);
      await P.rwkv.loadChat(
        modelPath: modelPath,
        backend: backend!,
        usingReasoningModel: fileInfo.isReasoning,
      );
    } catch (e) {
      Alert.error(e.toString());
      return;
    }

    P.rwkv.currentModel.u(fileInfo);
    Alert.success(S.current.you_can_now_start_to_chat_with_rwkv);
    pop();
  }

  void _onDownloadTap() async {
    P.fileManager.getFile(fileInfo: fileInfo);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localFile = ref.watch(P.fileManager.locals(fileInfo));
    final hasFile = localFile.hasFile;
    final downloading = localFile.downloading;
    final currentModel = ref.watch(P.rwkv.currentModel);
    final isCurrentModel = currentModel == fileInfo;
    final loading = ref.watch(P.rwkv.loading);

    return ClipRRect(
      borderRadius: 8.r,
      child: C(
        decoration: BD(color: kW, borderRadius: 8.r),
        margin: const EI.o(t: 8),
        padding: const EI.a(8),
        child: Ro(
          children: [
            Exp(
              child: FileKeyItem(fileInfo),
            ),
            8.w,
            if (!hasFile && !downloading)
              IconButton(
                onPressed: _onDownloadTap,
                icon: const Icon(Icons.download),
              ),
            if (downloading) _DownloadIndicator(fileInfo),
            if (hasFile) ...[
              if (!isCurrentModel)
                GD(
                  onTap: _onStartTap,
                  child: C(
                    decoration: BD(
                      color: loading ? kCG.wo(0.5) : kCG,
                      borderRadius: 8.r,
                    ),
                    padding: const EI.a(8),
                    child: T(loading ? "Loading..." : S.current.start_to_chat, s: const TS(c: kW)),
                  ),
                ),
              if (isCurrentModel)
                GD(
                  onTap: null,
                  child: C(
                    decoration: BD(
                      color: kG.wo(0.5),
                      borderRadius: 8.r,
                    ),
                    padding: const EI.a(8),
                    child: T(S.current.chatting, s: const TS(c: kW)),
                  ),
                ),
              if (!isCurrentModel) 8.w,
              if (!isCurrentModel) _Delete(fileInfo),
            ]
          ],
        ),
      ),
    );
  }
}

class _DownloadIndicator extends ConsumerWidget {
  final FileInfo fileInfo;

  const _DownloadIndicator(this.fileInfo);

  void _onTap() async {
    qq;
    final result = await showOkCancelAlertDialog(
      context: getContext()!,
      title: "Cancel Download?",
      okLabel: "Cancel",
      isDestructiveAction: true,
      cancelLabel: "Continue download",
    );
    if (result == OkCancelResult.ok) {
      await P.fileManager.cancelDownload(fileInfo: fileInfo);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GD(
      onTap: _onTap,
      child: C(
        margin: const EI.o(r: 8),
        child: Stack(
          children: [
            const SB(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
              child: Icon(
                Icons.stop,
                size: 16,
                color: kB.wo(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Delete extends ConsumerWidget {
  final FileInfo fileInfo;

  const _Delete(this.fileInfo);

  void _onTap() async {
    qq;
    final result = await showOkCancelAlertDialog(
      context: getContext()!,
      title: S.current.are_you_sure_you_want_to_delete_this_model,
      okLabel: S.current.delete,
      isDestructiveAction: true,
      cancelLabel: S.current.cancel,
    );
    if (result == OkCancelResult.ok) {
      await P.fileManager.deleteFile(fileInfo: fileInfo);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GD(
      onTap: _onTap,
      child: C(
        decoration: BD(color: kCR.wo(0.8), borderRadius: 8.r, border: Border.all(color: kC)),
        padding: const EI.a(5),
        child: const Icon(Icons.delete_forever_outlined, color: kW),
      ),
    );
  }
}

class FileKeyItem extends ConsumerWidget {
  final FileInfo fileInfo;
  final bool showDownloaded;

  const FileKeyItem(this.fileInfo, {super.key, this.showDownloaded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localFile = ref.watch(P.fileManager.locals(fileInfo));
    final fileSize = localFile.fileInfo.fileSize;
    final progress = localFile.progress;
    final downloading = localFile.downloading;
    final modelSize = fileInfo.modelSize ?? 0;
    final quantization = fileInfo.quantization;
    double networkSpeed = localFile.networkSpeed;
    if (networkSpeed < 0) networkSpeed = 0;
    Duration timeRemaining = localFile.timeRemaining;
    if (timeRemaining.isNegative) timeRemaining = Duration.zero;
    final tags = fileInfo.tags;
    final primary = Theme.of(getContext()!).colorScheme.primary;
    return Co(
      c: CAA.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: [
            T(
              fileInfo.name,
              s: const TS(c: kB, w: FW.w600),
            ),
            T(gbDisplay(fileSize), s: TS(c: kB.wo(0.7), w: FW.w500)),
            if (showDownloaded && localFile.hasFile)
              Icon(
                Icons.download_done,
                color: primary,
                size: 20,
              ),
          ],
        ),
        4.h,
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: [
            ...tags.map((tag) {
              final showHighlight = tag == Config.reasonTag || tag == "encoder" || tag == "npu";
              return C(
                decoration: BD(
                  borderRadius: 4.r,
                  color: showHighlight ? kCG : kG.wo(0.2),
                ),
                padding: const EI.s(h: 4),
                child: T(
                  tag,
                  s: TS(
                    c: showHighlight ? kW : kB,
                    w: showHighlight ? FW.w500 : FW.w400,
                  ),
                ),
              );
            }),
            C(
              decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
              padding: const EI.s(h: 4),
              child: T(fileInfo.backend?.asArgument ?? ""),
            ),
            if (modelSize > 0)
              C(
                decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                padding: const EI.s(h: 4),
                child: T("${modelSize}B"),
              ),
            if (quantization != null && quantization.isNotEmpty)
              C(
                decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                padding: const EI.s(h: 4),
                child: T(quantization),
              ),
          ],
        ),
        if (downloading) 8.h,
        if (downloading)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SB(
                width: width - 100,
                child: Ro(
                  children: [
                    Exp(
                      flex: (100 * progress).toInt(),
                      child: C(
                        decoration: BD(
                          borderRadius: BorderRadius.only(topLeft: 8.rr, bottomLeft: 8.rr),
                          color: kCG,
                        ),
                        height: 4,
                      ),
                    ),
                    Exp(
                      flex: 100 - (100 * progress).toInt(),
                      child: C(
                        decoration: BD(
                          borderRadius: BorderRadius.only(topRight: 8.rr, bottomRight: 8.rr),
                          color: kG.wo(0.5),
                        ),
                        height: 4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (downloading) 4.h,
        if (downloading)
          Wrap(
            children: [
              T(S.current.speed, s: TS(c: kB)),
              T("${networkSpeed.toStringAsFixed(1)}MB/s"),
              12.w,
              T(S.current.remaining, s: TS(c: kB)),
              if (timeRemaining.inMinutes > 0) T("${timeRemaining.inMinutes}m"),
              if (timeRemaining.inMinutes == 0) T("${timeRemaining.inSeconds}s"),
            ],
          ),
      ],
    );
  }
}
