// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FileInfo {
  FileKey get key => throw _privateConstructorUsedError;

  /// 是否存在本地文件
  bool get hasFile => throw _privateConstructorUsedError;
  String? get sha256 => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  double get networkSpeed => throw _privateConstructorUsedError;
  Duration get timeRemaining => throw _privateConstructorUsedError;
  bool get downloading => throw _privateConstructorUsedError;
  bool get checkingSHA256 => throw _privateConstructorUsedError;
  bool get sha256Verified => throw _privateConstructorUsedError;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileInfoCopyWith<FileInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileInfoCopyWith<$Res> {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) then) =
      _$FileInfoCopyWithImpl<$Res, FileInfo>;
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
class _$FileInfoCopyWithImpl<$Res, $Val extends FileInfo>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      hasFile: null == hasFile
          ? _value.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256: freezed == sha256
          ? _value.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      networkSpeed: null == networkSpeed
          ? _value.networkSpeed
          : networkSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      timeRemaining: null == timeRemaining
          ? _value.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      downloading: null == downloading
          ? _value.downloading
          : downloading // ignore: cast_nullable_to_non_nullable
              as bool,
      checkingSHA256: null == checkingSHA256
          ? _value.checkingSHA256
          : checkingSHA256 // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256Verified: null == sha256Verified
          ? _value.sha256Verified
          : sha256Verified // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileInfoImplCopyWith<$Res>
    implements $FileInfoCopyWith<$Res> {
  factory _$$FileInfoImplCopyWith(
          _$FileInfoImpl value, $Res Function(_$FileInfoImpl) then) =
      __$$FileInfoImplCopyWithImpl<$Res>;
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
class __$$FileInfoImplCopyWithImpl<$Res>
    extends _$FileInfoCopyWithImpl<$Res, _$FileInfoImpl>
    implements _$$FileInfoImplCopyWith<$Res> {
  __$$FileInfoImplCopyWithImpl(
      _$FileInfoImpl _value, $Res Function(_$FileInfoImpl) _then)
      : super(_value, _then);

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
    return _then(_$FileInfoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      hasFile: null == hasFile
          ? _value.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256: freezed == sha256
          ? _value.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      networkSpeed: null == networkSpeed
          ? _value.networkSpeed
          : networkSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      timeRemaining: null == timeRemaining
          ? _value.timeRemaining
          : timeRemaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      downloading: null == downloading
          ? _value.downloading
          : downloading // ignore: cast_nullable_to_non_nullable
              as bool,
      checkingSHA256: null == checkingSHA256
          ? _value.checkingSHA256
          : checkingSHA256 // ignore: cast_nullable_to_non_nullable
              as bool,
      sha256Verified: null == sha256Verified
          ? _value.sha256Verified
          : sha256Verified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FileInfoImpl extends _FileInfo {
  const _$FileInfoImpl(
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

  @override
  String toString() {
    return 'FileInfo(key: $key, hasFile: $hasFile, sha256: $sha256, progress: $progress, networkSpeed: $networkSpeed, timeRemaining: $timeRemaining, downloading: $downloading, checkingSHA256: $checkingSHA256, sha256Verified: $sha256Verified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileInfoImpl &&
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

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      __$$FileInfoImplCopyWithImpl<_$FileInfoImpl>(this, _$identity);
}

abstract class _FileInfo extends FileInfo {
  const factory _FileInfo(
      {required final FileKey key,
      final bool hasFile,
      final String? sha256,
      final double progress,
      final double networkSpeed,
      final Duration timeRemaining,
      final bool downloading,
      final bool checkingSHA256,
      final bool sha256Verified}) = _$FileInfoImpl;
  const _FileInfo._() : super._();

  @override
  FileKey get key;

  /// 是否存在本地文件
  @override
  bool get hasFile;
  @override
  String? get sha256;
  @override
  double get progress;
  @override
  double get networkSpeed;
  @override
  Duration get timeRemaining;
  @override
  bool get downloading;
  @override
  bool get checkingSHA256;
  @override
  bool get sha256Verified;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
