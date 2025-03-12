// ignore: unused_import
import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:zone/func/gb_display.dart';
import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/route/router.dart';
import 'package:zone/widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class ModelItem extends ConsumerWidget {
  final FileKey fileKey;

  const ModelItem(this.fileKey, {super.key});

  void _onStartTap() async {
    logTrace();
    if (P.rwkv.loading.v) return;
    final modelPath = fileKey.path;
    final backend = fileKey.backend;
    P.rwkv.loading.u(true);
    P.rwkv.usingReasoningModel.u(fileKey.isReasoning);

    try {
      P.rwkv.clearStates();
      P.chat.messages.u([]);
      await P.rwkv.loadChat(modelPath: modelPath, backend: backend);
    } catch (e) {
      Alert.error(e.toString());
      return;
    } finally {
      P.rwkv.loading.u(false);
    }

    P.rwkv.currentModel.u(fileKey);
    Alert.success(S.current.you_can_now_start_to_chat_with_rwkv);
    Navigator.pop(getContext()!);
  }

  void _onDownloadTap() async {
    P.remoteFile.getFile(fileKey: fileKey);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(P.remoteFile.files(fileKey));
    final fileSize = file.expectedFileSize;
    final progress = file.progress;
    final hasFile = file.hasFile;
    final downloading = file.downloading;
    final modelSizeB = fileKey.modelSizeB;
    final q = fileKey.quantization;
    final networkSpeed = file.networkSpeed;
    final timeRemaining = file.timeRemaining;
    final currentModel = ref.watch(P.rwkv.currentModel);
    final isCurrentModel = currentModel == fileKey;
    final loading = ref.watch(P.rwkv.loading);
    final tags = fileKey.weights?.tags ?? [];

    return ClipRRect(
      borderRadius: 8.r,
      child: C(
        decoration: BD(color: kW, borderRadius: 8.r),
        margin: const EI.o(t: 8),
        padding: const EI.a(8),
        child: Ro(
          children: [
            Exp(
              child: Co(
                c: CAA.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      T(
                        fileKey.weights?.name ?? "",
                        s: const TS(c: kB, w: FW.w600),
                      ),
                      T(gbDisplay(fileSize), s: TS(c: kB.wo(0.7), w: FW.w500)),
                    ],
                  ),
                  4.h,
                  Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children: [
                      ...tags.map((tag) {
                        return C(
                          decoration: BD(
                            borderRadius: 4.r,
                            color: kCG,
                          ),
                          padding: const EI.s(h: 4),
                          child: T(tag, s: const TS(c: kW, w: FW.w500)),
                        );
                      }),
                      C(
                        decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                        padding: const EI.s(h: 4),
                        child: T(fileKey.backend.asArgument),
                      ),
                      if (modelSizeB > 0)
                        C(
                          decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                          padding: const EI.s(h: 4),
                          child: T("${modelSizeB}B"),
                        ),
                      if (q.isNotEmpty)
                        C(
                          decoration: BD(color: kG.wo(0.2), borderRadius: 4.r),
                          padding: const EI.s(h: 4),
                          child: T(q),
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
                        const T("Speed: "),
                        T("${networkSpeed.toStringAsFixed(1)}MB/s"),
                        12.w,
                        const T("Remaining: "),
                        if (timeRemaining.inMinutes > 0) T("${timeRemaining.inMinutes}m"),
                        if (timeRemaining.inMinutes == 0) T("${timeRemaining.inSeconds}s"),
                      ],
                    ),
                ],
              ),
            ),
            8.w,
            if (!hasFile && !downloading)
              IconButton(
                onPressed: _onDownloadTap,
                icon: const Icon(Icons.download),
              ),
            if (downloading) _DownloadIndicator(fileKey),
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
              if (!isCurrentModel) _Delete(fileKey),
            ]
          ],
        ),
      ),
    );
  }
}

class _DownloadIndicator extends ConsumerWidget {
  final FileKey fileKey;

  const _DownloadIndicator(this.fileKey);

  void _onTap() async {
    logTrace();
    final result = await showOkCancelAlertDialog(
      context: getContext()!,
      title: "Cancel Download?",
      okLabel: "Cancel",
      isDestructiveAction: true,
      cancelLabel: "Continue download",
    );
    if (result == OkCancelResult.ok) {
      await P.remoteFile.cancelDownload(fileKey: fileKey);
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
  final FileKey fileKey;

  const _Delete(this.fileKey);

  void _onTap() async {
    logTrace();
    final result = await showOkCancelAlertDialog(
      context: getContext()!,
      title: "Are you sure you want to delete this model?",
      okLabel: "Delete",
      isDestructiveAction: true,
      cancelLabel: "Cancel",
    );
    if (result == OkCancelResult.ok) {
      await P.remoteFile.deleteFile(fileKey: fileKey);
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
