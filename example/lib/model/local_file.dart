import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:zone/model/file_info.dart';

@immutable
class LocalFile extends Equatable {
  final double progress;
  final double networkSpeed;
  final Duration timeRemaining;
  final bool downloading;
  final String targetPath;
  final bool hasFile;
  final String? downloadTaskId;

  final FileInfo _fileInfo;

  const LocalFile({
    required FileInfo fileInfo,
    required this.targetPath,
    this.progress = 0,
    this.networkSpeed = 0,
    this.timeRemaining = Duration.zero,
    this.downloading = false,
    this.hasFile = false,
    this.downloadTaskId,
  }) : _fileInfo = fileInfo;

  LocalFile copyWith({
    FileInfo? fileInfo,
    double? progress,
    double? networkSpeed,
    Duration? timeRemaining,
    bool? downloading,
    String? targetPath,
    bool? hasFile,
    String? downloadTaskId,
  }) =>
      LocalFile(
        fileInfo: fileInfo ?? _fileInfo,
        progress: progress ?? this.progress,
        networkSpeed: networkSpeed ?? this.networkSpeed,
        timeRemaining: timeRemaining ?? this.timeRemaining,
        downloading: downloading ?? this.downloading,
        targetPath: targetPath ?? this.targetPath,
        hasFile: hasFile ?? this.hasFile,
        downloadTaskId: downloadTaskId ?? this.downloadTaskId,
      );

  @override
  List<Object?> get props => [
        progress,
        networkSpeed,
        timeRemaining,
        downloading,
        targetPath,
        hasFile,
        downloadTaskId,
        _fileInfo,
      ];
}
