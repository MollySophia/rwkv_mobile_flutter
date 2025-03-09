// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';
import 'package:zone/model/weights.dart';
import 'package:zone/state/p.dart';

enum FileKey {
  v7_g1_0_1b_st,
  v7_world_0_1b_st,
  v7_world_0_1_ncnn,

  v7_world_0_4b_st,
  v7_world_0_4b_ncnn,
  v7_world_0_4b_gguf,

  v7_world_1_5b_prefab,
  v7_world_1_5b_ncnn,
  v7_world_1_5b_gguf,

  v7_world_3b_prefab,
  v7_world_3b_ncnn,
  v7_world_3b_gguf,

  download_test,
  ;

  Weights? get weights {
    final weights = P.remoteFile.weights.v;
    switch (this) {
      case v7_world_0_1b_st:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-World-0.1B-v2.8-20241210-ctx4096.st');
      case v7_g1_0_1b_st:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-G1-0.1b-20250307-ctx4096.st');
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
      case download_test:
        return weights.firstWhereOrNull((e) => e.fileName == 'test');
      case v7_world_0_4b_st:
        return weights.firstWhereOrNull((e) => e.fileName == 'RWKV-x070-World-0.4B-v2.9-20250107-ctx4096.st');
      case v7_world_0_1_ncnn:
      case v7_world_0_4b_ncnn:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_ncnn:
        return null;
    }
  }

  bool get available {
    if (this == download_test) return kDebugMode;
    final platforms = weights?.platforms;
    if (platforms == null) return false;
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
    final q = weights?.backends.firstOrNull;
    if (q != null) {
      return Backend.values.byName(q);
    }
    return Backend.webRwkv;
  }

  int get fileSize => weights?.fileSize ?? 0;

  double get modelSizeB => weights?.modelSize ?? 0;

  String get url => weights?.url ?? '';

  String get path => '${P.app.documentsDir.v!.path}/$fileName';
}
