// ignore: unused_import
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/group_info.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/widgets/model_item.dart';

class GroupItem extends ConsumerWidget {
  final GroupInfo groupInfo;

  const GroupItem(this.groupInfo, {super.key});

  void _onDownloadAllTap() async {
    final availableModels = P.fileManager.availableModels.v;
    final fileInfos = availableModels..toList();
    final missingFileInfos = fileInfos.where((e) => P.fileManager.locals(e).v.hasFile == false).toList();
    missingFileInfos.forEach((e) => P.fileManager.getFile(fileInfo: e));
  }

  void _onDeleteAllTap() async {
    final availableModels = P.fileManager.availableModels.v;
    final fileInfos = availableModels.toList();
    fileInfos.forEach((e) => P.fileManager.deleteFile(fileInfo: e));
  }

  void _onStartToChatTap() async {
    if (P.rwkv.loading.v) {
      Alert.warning("Please wait for the model to load...");
      return;
    }
    final availableModels = P.fileManager.availableModels.v;
    final fileInfos = availableModels.toList();

    final campPlusFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("campplus"));
    final flowEncoderFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("flow.encoder"));
    final flowDecoderEstimatorFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("flow.decoder.estimator"));
    final hiftGeneratorFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("hift"));
    final speechTokenizerFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("speech.tokenizer"));
    final modelFileKey = fileInfos.firstWhereOrNull((e) => e.name == "RWKV7 TTS");
    final spksInfoFileKey = fileInfos.firstWhereOrNull((e) => e.tags.contains("spk_info"));

    if (campPlusFileKey == null) {
      Alert.error("Campplus file not found");
      return;
    }

    if (flowEncoderFileKey == null) {
      Alert.error("Flow encoder file not found");
      return;
    }

    if (flowDecoderEstimatorFileKey == null) {
      Alert.error("Flow decoder estimator file not found");
      return;
    }

    if (hiftGeneratorFileKey == null) {
      Alert.error("Hift generator file not found");
      return;
    }

    if (speechTokenizerFileKey == null) {
      Alert.error("TTS tokenizer file not found");
      return;
    }

    if (modelFileKey == null) {
      Alert.error("Model file not found");
      return;
    }

    if (spksInfoFileKey == null) {
      Alert.error("Speaker info file not found");
      return;
    }

    final modelLocalFile = P.fileManager.locals(modelFileKey).v;
    final localCampPlusFile = P.fileManager.locals(campPlusFileKey).v;
    final localFlowEncoderFile = P.fileManager.locals(flowEncoderFileKey).v;
    final localFlowDecoderEstimatorFile = P.fileManager.locals(flowDecoderEstimatorFileKey).v;
    final localHiftGeneratorFile = P.fileManager.locals(hiftGeneratorFileKey).v;
    final localSpeechTokenizerFile = P.fileManager.locals(speechTokenizerFileKey).v;
    final localSpksInfoFile = P.fileManager.locals(spksInfoFileKey).v;
    P.rwkv.currentGroupInfo.u(groupInfo);

    P.rwkv.clearStates();
    P.chat.clearMessages();

    try {
      await P.rwkv.loadTTSModels(
        modelPath: modelLocalFile.targetPath,
        backend: modelFileKey.backend!,
        usingReasoningModel: false,
        campPlusPath: localCampPlusFile.targetPath,
        flowEncoderPath: localFlowEncoderFile.targetPath,
        flowDecoderEstimatorPath: localFlowDecoderEstimatorFile.targetPath,
        hiftGeneratorPath: localHiftGeneratorFile.targetPath,
        speechTokenizerPath: localSpeechTokenizerFile.targetPath,
        spksInfoPath: localSpksInfoFile.targetPath,
      );
      P.tts.getTTSSpkNames();
      Navigator.pop(getContext()!);
    } catch (e) {
      qqe("$e");
      Alert.error(e.toString());
      P.rwkv.currentGroupInfo.u(null);
      return;
    }

    P.rwkv.currentGroupInfo.u(groupInfo);
    P.rwkv.currentModel.u(modelFileKey);
    Alert.success(S.current.you_can_now_start_to_chat_with_rwkv);
    pop();
  }

  void _onContinueTap() async {
    qq;
    pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableModels = P.fileManager.availableModels.v;
    final fileInfos = availableModels.toList();
    if (fileInfos.isEmpty) return const SizedBox.shrink();
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;

    final files = fileInfos.m((e) {
      return ref.watch(P.fileManager.locals(e));
    });

    final allDownloaded = files.every((e) => e.hasFile);
    final allMissing = files.every((e) => !e.hasFile);
    final downloading = files.any((e) => e.downloading);

    final currentGroupInfo = ref.watch(P.rwkv.currentGroupInfo);
    final alreadyStarted = currentGroupInfo == groupInfo;
    final loading = ref.watch(P.rwkv.loading);

    return ClipRRect(
      borderRadius: 8.r,
      child: C(
        decoration: BD(color: kW, borderRadius: 8.r),
        margin: const EI.o(t: 8),
        padding: const EI.o(t: 8, l: 8, r: 8, b: 8),
        child: Co(
          c: CAA.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                T(groupInfo.displayName, s: const TS(s: 18, w: FW.w600)),
                T(groupInfo.taskDescription, s: const TS(s: 12, w: FW.w400)),
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}
