// ignore_for_file: constant_identifier_names

import 'package:zone/state/p.dart';

enum FileKey {
  v7_world_0_1b_st,
  v7_world_0_1ncnn,

  v7_world_0_4b_st,
  v7_world_0_4b_ncnn,
  v7_world_0_4gguf,

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

  bool get available {
    switch (this) {
      case test:
      case v7_world_0_4gguf:
      case v7_world_3b_gguf:
        return true;
      case v7_world_0_1b_st:
        return false;
      case v7_world_0_1ncnn:
        return false;
      case v7_world_0_4b_st:
        return false;
      case v7_world_0_4b_ncnn:
        return false;
      case v7_world_1_5b_st:
        return false;
      case v7_world_1_5b_ncnn:
        return false;
      case v7_world_1_5b_gguf:
        return false;
      case v7_world_3b_st:
        return false;
      case v7_world_3b_ncnn:
        return false;
      case world_vocab:
        return false;
      case othello_vocab:
        return false;
    }
  }

  String get fileName {
    switch (this) {
      case v7_world_0_1b_st:
        return 'v7_world_0_1b_st';
      case v7_world_0_1ncnn:
        return 'v7_world_0_1ncnn';
      case v7_world_0_4b_st:
        return 'v7_world_0_4b_st';
      case v7_world_0_4b_ncnn:
        return 'v7_world_0_4b_ncnn';
      case v7_world_0_4gguf:
        return 'rwkv7-world-0.4B-Q8_0.gguf';
      case v7_world_1_5b_st:
        return 'v7_world_1_5b_st';
      case v7_world_1_5b_ncnn:
        return 'v7_world_1_5b_ncnn';
      case v7_world_3b_st:
        return 'v7_world_3b_st';
      case v7_world_3b_ncnn:
        return 'v7_world_3b_ncnn';
      case v7_world_3b_gguf:
        return 'rwkv7-world-2.9B-Q4_K_M.gguf';
      case test:
        return 'test.jpeg';
      case v7_world_1_5b_gguf:
        return 'rwkv7-world-1.5B-Q8_0.gguf';
      case world_vocab:
        return 'rwkv7-world-vocab.bin';
      case othello_vocab:
        return 'rwkv7-othello-vocab.bin';
    }
  }

  String get zipFileName => '$fileName.zip';

  String get url {
    const baseUrl = 'https://api-model.rwkvos.com/download';
    return '$baseUrl/$zipFileName';
  }

  String get zipPath => '${P.app.cacheDir.v!.path}/$zipFileName';

  String get path => '${P.app.supportDir.v!.path}/$fileName';
}
