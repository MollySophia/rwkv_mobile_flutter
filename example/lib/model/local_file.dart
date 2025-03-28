import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:zone/model/file_info.dart';
import 'package:rwkv_mobile_flutter/types.dart';
import 'package:zone/model/world_type.dart';

@immutable
class LocalFile extends Equatable implements FileInfo {
  final double progress;
  final double networkSpeed;
  final Duration timeRemaining;
  final bool downloading;
  final String targetPath;
  final bool hasFile;
  final String? downloadTaskId;
  final FileInfo fileInfo;

  const LocalFile({
    required this.fileInfo,
    required this.targetPath,
    this.progress = 0,
    this.networkSpeed = 0,
    this.timeRemaining = Duration.zero,
    this.downloading = false,
    this.hasFile = false,
    this.downloadTaskId,
  });

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
        fileInfo: fileInfo ?? this.fileInfo,
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
        fileInfo,
      ];

  @override
  bool get available => fileInfo.available;

  @override
  List<FileDownloadSource> get availableIn => fileInfo.availableIn;

  @override
  Backend? get backend => fileInfo.backend;

  @override
  String? get ext => fileInfo.ext;

  @override
  String get fileName => fileInfo.fileName;

  @override
  int get fileSize => fileInfo.fileSize;

  @override
  FileType get fileType => fileInfo.fileType;

  @override
  bool get isDebug => fileInfo.isDebug;

  @override
  double? get modelSize => fileInfo.modelSize;

  @override
  String get name => fileInfo.name;

  @override
  String? get quantization => fileInfo.quantization;

  @override
  String get raw => fileInfo.raw;

  @override
  String? get sha256 => fileInfo.sha256;

  @override
  List<String> get supportedPlatforms => fileInfo.supportedPlatforms;

  @override
  List<String> get tags => fileInfo.tags;

  @override
  bool get isReasoning => fileInfo.isReasoning;

  @override
  bool get isEncoder => fileInfo.isEncoder;

  @override
  WorldType? get worldType => fileInfo.worldType;

  @override
  bool get platformSupported => fileInfo.platformSupported;
}
