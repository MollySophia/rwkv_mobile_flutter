// ignore_for_file: constant_identifier_names

import 'package:zone/state/p.dart';

enum FileKey {
  v7_world_0_1b_st,
  v7_world_0_1_ncnn,

  v7_world_0_4b_st,
  v7_world_0_4b_ncnn,
  v7_world_0_4b_gguf,

  v7_world_1_5b_st,
  v7_world_1_5b_ncnn,
  v7_world_1_5b_gguf,

  v7_world_3b_st,
  v7_world_3b_ncnn,
  v7_world_3b_gguf,

  world_vocab,
  othello_vocab,

  test,
  ;

  bool get available => fileName.isNotEmpty;

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
      case test:
        return 'test';
      case v7_world_1_5b_gguf:
      case world_vocab:
      case othello_vocab:
      case v7_world_0_4b_ncnn:
      case v7_world_0_1_ncnn:
      case v7_world_1_5b_st:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_st:
      case v7_world_3b_ncnn:
        return '';
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
      case test:
        return 10668720;
      case v7_world_1_5b_gguf:
      case world_vocab:
      case othello_vocab:
      case v7_world_0_4b_ncnn:
      case v7_world_0_1_ncnn:
      case v7_world_1_5b_st:
      case v7_world_1_5b_ncnn:
      case v7_world_3b_st:
      case v7_world_3b_ncnn:
        return 1;
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
