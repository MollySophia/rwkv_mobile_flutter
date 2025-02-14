// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zone/state/p.dart';

part 'file_info.freezed.dart';

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

  String get fileName {
    switch (this) {
      case FileKey.v7_world_0_1b_st:
        return 'v7_world_0_1b_st';
      case FileKey.v7_world_0_1ncnn:
        return 'v7_world_0_1ncnn';
      case FileKey.v7_world_0_4b_st:
        return 'v7_world_0_4b_st';
      case FileKey.v7_world_0_4b_ncnn:
        return 'v7_world_0_4b_ncnn';
      case FileKey.v7_world_0_4gguf:
        return 'rwkv7-world-0.4B-Q8_0.gguf';
      case FileKey.v7_world_1_5b_st:
        return 'v7_world_1_5b_st';
      case FileKey.v7_world_1_5b_ncnn:
        return 'v7_world_1_5b_ncnn';
      case FileKey.v7_world_3b_st:
        return 'v7_world_3b_st';
      case FileKey.v7_world_3b_ncnn:
        return 'v7_world_3b_ncnn';
      case FileKey.v7_world_3b_gguf:
        return 'v7_world_3b_gguf';
      case FileKey.test:
        return 'test.jpeg.zip';
      case FileKey.v7_world_1_5b_gguf:
        return 'rwkv7-world-1.5B-Q8_0.gguf';
      case FileKey.world_vocab:
        return 'rwkv7-world-vocab.bin';
      case FileKey.othello_vocab:
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

@freezed
class FileInfo with _$FileInfo {
  const factory FileInfo({
    required FileKey key,
    String? taskId,
    @Default(1) int zipSize,
    @Default(0) int downloadedZipSize,
    @Default(1) int fileSize,
    @Default(false) bool hasZip,
    @Default(false) bool hasFile,
    @Default(0) double progress,
    @Default(0) double networkSpeed,
    @Default(Duration.zero) Duration timeRemaining,
    @Default(0) int expectedFileSize,
  }) = _FileInfo;
}
