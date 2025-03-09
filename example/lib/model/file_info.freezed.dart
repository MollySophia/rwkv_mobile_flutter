// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FileInfo {
  FileKey get key;

  /// 是否存在本地文件
  bool get hasFile;
  String? get sha256;
  double get progress;
  double get networkSpeed;
  Duration get timeRemaining;
  bool get downloading;
  bool get checkingSHA256;
  bool get sha256Verified;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FileInfoCopyWith<FileInfo> get copyWith =>
      _$FileInfoCopyWithImpl<FileInfo>(this as FileInfo, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FileInfo &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.hasFile, hasFile) || other.hasFile == hasFile) &&
            (identical(other.sha256, sha256) || other.sha256 == sha256) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.networkSpeed, networkSpeed) ||
                other.networkSpeed == networkSpeed) &&
            (identical(other.timeRemaining, timeRemaining) ||
                other.timeRemaining == timeRemaining) &&
            (identical(other.downloading, downloading) ||
                other.downloading == downloading) &&
            (identical(other.checkingSHA256, checkingSHA256) ||
                other.checkingSHA256 == checkingSHA256) &&
            (identical(other.sha256Verified, sha256Verified) ||
                other.sha256Verified == sha256Verified));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, hasFile, sha256, progress,
      networkSpeed, timeRemaining, downloading, checkingSHA256, sha256Verified);

  @override
  String toString() {
    return 'FileInfo(key: $key, hasFile: $hasFile, sha256: $sha256, progress: $progress, networkSpeed: $networkSpeed, timeRemaining: $timeRemaining, downloading: $downloading, checkingSHA256: $checkingSHA256, sha256Verified: $sha256Verified)';
  }
}

/// @nodoc
abstract mixin class $FileInfoCopyWith<$Res> {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) _then) =
      _$FileInfoCopyWithImpl;
  @useResult
  $Res call(
      {FileKey key,
      bool hasFile,
      String? sha256,
      double progress,
      double networkSpeed,
      Duration timeRemaining,
      bool downloading,
      bool checkingSHA256,
      bool sha256Verified});
}

/// @nodoc
class _$FileInfoCopyWithImpl<$Res> implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._self, this._then);

  final FileInfo _self;
  final $Res Function(FileInfo) _then;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? hasFile = null,
    Object? sha256 = freezed,
    Object? progress = null,
    Object? networkSpeed = null,
    Object? timeRemaining = null,
    Object? downloading = null,
    Object? checkingSHA256 = null,
    Object? sha256Verified = null,
  }) {
    return _then(_self.copyWith(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      hasFile: null == hasFile
          ? _self.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256: freezed == sha256
          ? _self.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      networkSpeed: null == networkSpeed
          ? _self.networkSpeed
          : networkSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      timeRemaining: null == timeRemaining
          ? _self.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      downloading: null == downloading
          ? _self.downloading
          : downloading // ignore: cast_nullable_to_non_nullable
              as bool,
      checkingSHA256: null == checkingSHA256
          ? _self.checkingSHA256
          : checkingSHA256 // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256Verified: null == sha256Verified
          ? _self.sha256Verified
          : sha256Verified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _FileInfo extends FileInfo {
  const _FileInfo(
      {required this.key,
      this.hasFile = false,
      this.sha256 = null,
      this.progress = 0,
      this.networkSpeed = 0,
      this.timeRemaining = Duration.zero,
      this.downloading = false,
      this.checkingSHA256 = false,
      this.sha256Verified = false})
      : super._();

  @override
  final FileKey key;

  /// 是否存在本地文件
  @override
  @JsonKey()
  final bool hasFile;
  @override
  @JsonKey()
  final String? sha256;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final double networkSpeed;
  @override
  @JsonKey()
  final Duration timeRemaining;
  @override
  @JsonKey()
  final bool downloading;
  @override
  @JsonKey()
  final bool checkingSHA256;
  @override
  @JsonKey()
  final bool sha256Verified;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FileInfoCopyWith<_FileInfo> get copyWith =>
      __$FileInfoCopyWithImpl<_FileInfo>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FileInfo &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.hasFile, hasFile) || other.hasFile == hasFile) &&
            (identical(other.sha256, sha256) || other.sha256 == sha256) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.networkSpeed, networkSpeed) ||
                other.networkSpeed == networkSpeed) &&
            (identical(other.timeRemaining, timeRemaining) ||
                other.timeRemaining == timeRemaining) &&
            (identical(other.downloading, downloading) ||
                other.downloading == downloading) &&
            (identical(other.checkingSHA256, checkingSHA256) ||
                other.checkingSHA256 == checkingSHA256) &&
            (identical(other.sha256Verified, sha256Verified) ||
                other.sha256Verified == sha256Verified));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, hasFile, sha256, progress,
      networkSpeed, timeRemaining, downloading, checkingSHA256, sha256Verified);

  @override
  String toString() {
    return 'FileInfo(key: $key, hasFile: $hasFile, sha256: $sha256, progress: $progress, networkSpeed: $networkSpeed, timeRemaining: $timeRemaining, downloading: $downloading, checkingSHA256: $checkingSHA256, sha256Verified: $sha256Verified)';
  }
}

/// @nodoc
abstract mixin class _$FileInfoCopyWith<$Res>
    implements $FileInfoCopyWith<$Res> {
  factory _$FileInfoCopyWith(_FileInfo value, $Res Function(_FileInfo) _then) =
      __$FileInfoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {FileKey key,
      bool hasFile,
      String? sha256,
      double progress,
      double networkSpeed,
      Duration timeRemaining,
      bool downloading,
      bool checkingSHA256,
      bool sha256Verified});
}

/// @nodoc
class __$FileInfoCopyWithImpl<$Res> implements _$FileInfoCopyWith<$Res> {
  __$FileInfoCopyWithImpl(this._self, this._then);

  final _FileInfo _self;
  final $Res Function(_FileInfo) _then;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? key = null,
    Object? hasFile = null,
    Object? sha256 = freezed,
    Object? progress = null,
    Object? networkSpeed = null,
    Object? timeRemaining = null,
    Object? downloading = null,
    Object? checkingSHA256 = null,
    Object? sha256Verified = null,
  }) {
    return _then(_FileInfo(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      hasFile: null == hasFile
          ? _self.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256: freezed == sha256
          ? _self.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      networkSpeed: null == networkSpeed
          ? _self.networkSpeed
          : networkSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      timeRemaining: null == timeRemaining
          ? _self.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      downloading: null == downloading
          ? _self.downloading
          : downloading // ignore: cast_nullable_to_non_nullable
              as bool,
      checkingSHA256: null == checkingSHA256
          ? _self.checkingSHA256
          : checkingSHA256 // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256Verified: null == sha256Verified
          ? _self.sha256Verified
          : sha256Verified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
