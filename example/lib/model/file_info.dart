// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zone/model/file_key.dart';

part 'file_info.freezed.dart';

@freezed
class FileInfo with _$FileInfo {
  const FileInfo._();

  const factory FileInfo({
    required FileKey key,

    /// 是否已下载
    @Default(false) bool hasFile,
    @Default(0) double progress,
    @Default(0) double networkSpeed,
    @Default(Duration.zero) Duration timeRemaining,
    @Default(false) bool downloading,
  }) = _FileInfo;

  int get fileSize {
    return key.fileSize;
  }
}
