// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zone/model/file_key.dart';

part 'file_info.freezed.dart';

@freezed
class FileInfo with _$FileInfo {
  const factory FileInfo({
    required FileKey key,
    String? taskId,

    /// 压缩包文件大小, bytes
    @Default(1) int zipSize,
    @Default(1) int fileSize,
    @Default(false) bool hasZip,
    @Default(false) bool hasFile,
    @Default(0) double progress,
    @Default(0) double networkSpeed,
    @Default(Duration.zero) Duration timeRemaining,
    @Default(false) bool downloading,
  }) = _FileInfo;
}
