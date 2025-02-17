// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';
import 'package:zone/state/p.dart';

enum FileKey {
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

  world_vocab,
  othello_vocab,

  download_test,
  ;

  bool get available {
    if (fileName.isEmpty) return false;

    switch (this) {
      case FileKey.v7_world_0_1b_st:
      case FileKey.v7_world_0_4b_st:
      case FileKey.v7_world_1_5b_prefab:
      case FileKey.v7_world_3b_prefab:
        if (Platform.isIOS || Platform.isMacOS) return true;
        return false;
      case FileKey.v7_world_0_1_ncnn:
      case FileKey.v7_world_0_4b_ncnn:
      case FileKey.v7_world_1_5b_ncnn:
      case FileKey.v7_world_3b_ncnn:
        return false;
      case FileKey.v7_world_0_4b_gguf:
      case FileKey.v7_world_1_5b_gguf:
      case FileKey.v7_world_3b_gguf:
        if (!Platform.isIOS && !Platform.isMacOS) return true;
        return false;
      case FileKey.download_test:
        return kDebugMode;
      case FileKey.world_vocab:
      case FileKey.othello_vocab:
        return false;
    }
  }

  static List<FileKey> get availableModels {
    return values.where((e) => e.available).toList();
  }

  String get fileName {
    switch (this) {
      case v7_world_0_1b_st:
        return 'RWKV-x070-World-0.1B-v2.8-20241210-ctx4096.st';
      case v7_world_0_4b_st:
        return 'RWKV-x070-World-0.4B-v2.9-20250107-ctx4096.st';
      case v7_world_0_4b_gguf:
        return 'rwkv7-world-0.4B-Q8_0.gguf';
      case v7_world_3b_gguf:
        return 'rwkv7-world-2.9B-Q4_K_M.gguf';
      case v7_world_3b_prefab:
        return 'RWKV-x070-World-2.9B-v3-NF4-20250211-ctx4096.prefab';
      case v7_world_1_5b_prefab:
        return '';
      case v7_world_1_5b_gguf:
        return '';
      case download_test:
        return 'test';
      case world_vocab:
      case othello_vocab:
      case v7_world_0_4b_ncnn:
      case v7_world_0_1_ncnn:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_ncnn:
        return '';
    }
  }

  String get q {
    switch (this) {
      case v7_world_0_1b_st:
        return '';
      case v7_world_0_4b_st:
        return '';
      case v7_world_0_4b_gguf:
        return 'Q8_0';
      case v7_world_1_5b_gguf:
        return 'Q5_K_M';
      case v7_world_3b_gguf:
        return 'Q4_K_M';
      case download_test:
        return '';
      case world_vocab:
      case othello_vocab:
      case v7_world_0_4b_ncnn:
      case v7_world_0_1_ncnn:
      case v7_world_1_5b_prefab:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_prefab:
      case v7_world_3b_ncnn:
        return '';
    }
  }

  Backend get backend {
    switch (this) {
      case FileKey.v7_world_0_1b_st:
      case FileKey.v7_world_0_4b_st:
      case FileKey.v7_world_1_5b_prefab:
      case FileKey.v7_world_3b_prefab:
        return Backend.webRwkv;
      case FileKey.v7_world_0_1_ncnn:
      case FileKey.v7_world_0_4b_ncnn:
      case FileKey.v7_world_1_5b_ncnn:
      case FileKey.v7_world_3b_ncnn:
        return Backend.ncnn;
      case FileKey.v7_world_0_4b_gguf:
      case FileKey.v7_world_1_5b_gguf:
      case FileKey.v7_world_3b_gguf:
        return Backend.llamacpp;
      case FileKey.world_vocab:
      case FileKey.othello_vocab:
      case FileKey.download_test:
        return Backend.webRwkv;
    }
  }

  int get fileSize {
    switch (this) {
      case v7_world_0_1b_st:
        return 1;
      case v7_world_0_4b_st:
        return 1;
      case v7_world_0_4b_gguf:
        return 491113248;
      case v7_world_3b_gguf:
        return 1875792416;
      case download_test:
        return 10668720;
      case v7_world_1_5b_gguf:
        return 1355373866;
      case world_vocab:
      case othello_vocab:
      case v7_world_0_4b_ncnn:
      case v7_world_0_1_ncnn:
      case v7_world_1_5b_prefab:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_prefab:
        return 2315788802;
      case v7_world_3b_ncnn:
        return 1;
    }
  }

  double get modelSizeB {
    switch (this) {
      case FileKey.v7_world_0_1b_st:
        return 0.1;
      case FileKey.v7_world_0_1_ncnn:
        return 0.1;
      case FileKey.v7_world_0_4b_st:
        return 0.4;
      case FileKey.v7_world_0_4b_ncnn:
        return 0.4;
      case FileKey.v7_world_0_4b_gguf:
        return 0.4;
      case FileKey.v7_world_1_5b_prefab:
        return 1.5;
      case FileKey.v7_world_1_5b_ncnn:
        return 1.5;
      case FileKey.v7_world_1_5b_gguf:
        return 1.5;
      case FileKey.v7_world_3b_prefab:
        return 3;
      case FileKey.v7_world_3b_ncnn:
        return 3;
      case FileKey.v7_world_3b_gguf:
        return 3;
      case FileKey.world_vocab:
        return 0.0;
      case FileKey.othello_vocab:
        return 0.0;
      case FileKey.download_test:
        return 0.0;
    }
  }

  @Deprecated("")
  String get zipFileName => '$fileName.zip';

  String get url {
    const baseUrl = 'https://api-model.rwkvos.com/download';
    return '$baseUrl/$fileName';
  }

  @Deprecated("")
  String get zipPath => '${P.app.tempDir.v!.path}/$zipFileName';

  String get path => '${P.app.documentsDir.v!.path}/$fileName';
}
