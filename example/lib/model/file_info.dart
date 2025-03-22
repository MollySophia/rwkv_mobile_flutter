// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zone/model/file_key.dart';

part 'file_info.freezed.dart';

@freezed
abstract class FileInfo with _$FileInfo {
  const FileInfo._();

  const factory FileInfo({
    required FileKey key,

    /// 是否存在本地文件
    @Default(false) bool hasFile,
    @Default(null) String? sha256,
    @Default(0) double progress,
    @Default(0) double networkSpeed,
    @Default(Duration.zero) Duration timeRemaining,
    @Default(false) bool downloading,
    @Default(false) bool checkingSHA256,
    @Default(false) bool sha256Verified,
  }) = _FileInfo;

  int get expectedFileSize {
    return key.fileSize;
  }
}
