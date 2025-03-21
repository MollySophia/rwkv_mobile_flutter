// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:rwkv_mobile_flutter/rwkv.dart';
import 'package:zone/model/weights.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/state/p.dart';

// TODO: 在未来应该改为权重, 现在这个东西的职责和权重重合了
enum FileKey {
  // 🔥 Chat demo

  v7_g1_0_1b_st,
  v7_g1_0_1b_gguf,
  v7_g1_0_1b_qnn,

  v7_world_0_4b_st,
  v7_world_0_4b_ncnn,
  v7_world_0_4b_gguf,

  v7_world_1_5b_prefab,
  v7_world_1_5b_ncnn,
  v7_world_1_5b_gguf,

  v7_world_3b_prefab,
  v7_world_3b_ncnn,
  v7_world_3b_gguf,

  // 🔥 World demo
  rwkv7_0_4b_siglip_vision_encoder_gguf,
  rwkv7_0_4b_vision_siglip_gguf,
  rwkv7_0_4b_whisper_small_enqa_adapter_gguf,
  rwkv7_0_4b_whisper_small_enqa_gguf,
  rwkv7_0_1b_whisper_small_enasr_adapter_gguf,
  rwkv7_0_1b_whisper_small_enasr_gguf,

  // 🔥 Download test
  download_test_github_releases,
  download_test_5mb,
  ;

  Weights? get weights {
    final weights = P.fileManager.weights.v;
    switch (this) {
      case rwkv7_0_1b_whisper_small_enasr_adapter_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'whisper-small-rwkv-0b1-enasr-adapter.gguf');
      case rwkv7_0_1b_whisper_small_enasr_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV7-0.1B-WhisperS-ENASR-DEMO-F16.gguf');
      case rwkv7_0_4b_whisper_small_enqa_adapter_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'whisper-small-rwkv-0b4-enqa-adapter.gguf');
      case rwkv7_0_4b_whisper_small_enqa_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV7-0.4B-WhisperS-ENQA-DEMO-Q8_0.gguf');
      case rwkv7_0_4b_siglip_vision_encoder_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7_0.4B_siglip_vision_encoder-f16.gguf');
      case rwkv7_0_4b_vision_siglip_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7_0.4B_vision_siglip-Q8_0.gguf');
      case v7_g1_0_1b_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7-g1-0.1B-F16.gguf');
      case v7_g1_0_1b_st:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-G1-0.1b-20250307-ctx4096.st');
      case v7_g1_0_1b_qnn:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7-g1-0.1b-20250307-ctx4096-qnn-f16-8gen3.bin');
      case v7_world_0_4b_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7-world-0.4B-Q8_0.gguf');
      case v7_world_1_5b_prefab:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-World-1.5B-v3-NF4-20250127-ctx4096.prefab');
      case v7_world_3b_prefab:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-World-2.9B-v3-NF4-20250211-ctx4096.prefab');
      case v7_world_1_5b_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7-world-1.5B-Q5_K_M.gguf');
      case v7_world_3b_gguf:
        return weights.firstWhereOrNull((e) => e.fileName == 'rwkv7-world-2.9B-Q4_K_M.gguf');
      case download_test_github_releases:
        return weights.firstWhereOrNull((e) => e.name == 'test: github-releases');
      case download_test_5mb:
        return weights.firstWhereOrNull((e) => e.name == 'test: 5MB');
      case v7_world_0_4b_st:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-World-0.4B-v2.9-20250107-ctx4096.st');
      case v7_world_0_4b_ncnn:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_ncnn:
        return null;
    }
  }

  bool get isTest {
    return this == download_test_github_releases || this == download_test_5mb;
  }

  bool get available {
    if (isTest) return kDebugMode;
    final platforms = weights?.platforms;
    if (platforms == null) return false;
    final socLimitations = weights?.socLimitations ?? [];
    if (socLimitations.isNotEmpty) {
      final soc = P.rwkv.soc.v;
      if (soc.isEmpty) return false;
      if (!socLimitations.contains(soc)) return false;
    }
    if (Platform.isIOS) return platforms.contains('ios');
    if (Platform.isMacOS) return platforms.contains('macos');
    if (Platform.isWindows) return platforms.contains('windows');
    if (Platform.isLinux) return platforms.contains('linux');
    if (Platform.isAndroid) return platforms.contains('android');
    if (Platform.isFuchsia) return platforms.contains('fuchsia');
    return false;
  }

  static List<FileKey> get availableModels {
    return values.where((e) => e.available).toList();
  }

  String get fileName => weights?.fileName ?? '';

  String get quantization => weights?.quantization ?? '';

  Backend get backend {
    final q = weights?.backends?.firstOrNull;
    if (q != null) {
      return Backend.fromString(q);
    }
    return Backend.webRwkv;
  }

  int get fileSize => weights?.fileSize ?? 0;

  double get modelSizeB => weights?.modelSize ?? 0;

  String get url {
    if (isTest) return weights?.url ?? '';
    final source = P.fileManager.currentSource.v;
    final raw = weights?.url ?? '';
    return source.prefix + raw + source.suffix;
  }

  String get path => '${P.app.documentsDir.v!.path}/$fileName';

  bool get isReasoning {
    return weights?.tags?.contains('reasoning') ?? false;
  }

  bool get isEncoder {
    return weights?.tags?.contains('encoder') ?? false;
  }

  WorldType? get worldType {
    switch (this) {
      case v7_world_0_4b_st:
        return null;
      case v7_world_0_4b_ncnn:
        return null;
      case v7_world_0_4b_gguf:
        return null;
      case v7_g1_0_1b_st:
        return null;
      case v7_g1_0_1b_gguf:
        return null;
      case v7_g1_0_1b_qnn:
        return null;
      case v7_world_1_5b_prefab:
        return null;
      case v7_world_1_5b_ncnn:
        return null;
      case v7_world_1_5b_gguf:
        return null;
      case v7_world_3b_prefab:
        return null;
      case v7_world_3b_ncnn:
        return null;
      case v7_world_3b_gguf:
        return null;
      case rwkv7_0_4b_siglip_vision_encoder_gguf:
        return WorldType.engVisualQA;
      case rwkv7_0_4b_vision_siglip_gguf:
        return WorldType.engVisualQA;
      case rwkv7_0_4b_whisper_small_enqa_adapter_gguf:
        return WorldType.engAudioQA;
      case rwkv7_0_4b_whisper_small_enqa_gguf:
        return WorldType.engAudioQA;
      case rwkv7_0_1b_whisper_small_enasr_adapter_gguf:
        return WorldType.engASR;
      case rwkv7_0_1b_whisper_small_enasr_gguf:
        return WorldType.engASR;
      case download_test_github_releases:
        return null;
      case download_test_5mb:
        return null;
    }
  }
}
