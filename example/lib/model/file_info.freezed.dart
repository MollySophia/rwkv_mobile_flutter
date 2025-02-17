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
  @Deprecated("")
  String? get taskId => throw _privateConstructorUsedError;

  /// 是否已下载
  bool get hasFile => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  double get networkSpeed => throw _privateConstructorUsedError;
  Duration get timeRemaining => throw _privateConstructorUsedError;
  bool get downloading => throw _privateConstructorUsedError;

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
      @Deprecated("") String? taskId,
      bool hasFile,
      double progress,
      double networkSpeed,
      Duration timeRemaining,
      bool downloading});
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
    Object? taskId = freezed,
    Object? hasFile = null,
    Object? progress = null,
    Object? networkSpeed = null,
    Object? timeRemaining = null,
    Object? downloading = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      hasFile: null == hasFile
          ? _value.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
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
      @Deprecated("") String? taskId,
      bool hasFile,
      double progress,
      double networkSpeed,
      Duration timeRemaining,
      bool downloading});
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
    Object? taskId = freezed,
    Object? hasFile = null,
    Object? progress = null,
    Object? networkSpeed = null,
    Object? timeRemaining = null,
    Object? downloading = null,
  }) {
    return _then(_$FileInfoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as FileKey,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      hasFile: null == hasFile
          ? _value.hasFile
          : hasFile // ignore: cast_nullable_to_non_nullable
              as bool,
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
    ));
  }
}

/// @nodoc

class _$FileInfoImpl extends _FileInfo {
  const _$FileInfoImpl(
      {required this.key,
      @Deprecated("") this.taskId,
      this.hasFile = false,
      this.progress = 0,
      this.networkSpeed = 0,
      this.timeRemaining = Duration.zero,
      this.downloading = false})
      : super._();

  @override
  final FileKey key;
  @override
  @Deprecated("")
  final String? taskId;

  /// 是否已下载
  @override
  @JsonKey()
  final bool hasFile;
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
  String toString() {
    return 'FileInfo(key: $key, taskId: $taskId, hasFile: $hasFile, progress: $progress, networkSpeed: $networkSpeed, timeRemaining: $timeRemaining, downloading: $downloading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileInfoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.hasFile, hasFile) || other.hasFile == hasFile) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.networkSpeed, networkSpeed) ||
                other.networkSpeed == networkSpeed) &&
            (identical(other.timeRemaining, timeRemaining) ||
                other.timeRemaining == timeRemaining) &&
            (identical(other.downloading, downloading) ||
                other.downloading == downloading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key, taskId, hasFile, progress,
      networkSpeed, timeRemaining, downloading);

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
      @Deprecated("") final String? taskId,
      final bool hasFile,
      final double progress,
      final double networkSpeed,
      final Duration timeRemaining,
      final bool downloading}) = _$FileInfoImpl;
  const _FileInfo._() : super._();

  @override
  FileKey get key;
  @override
  @Deprecated("")
  String? get taskId;

  /// 是否已下载
  @override
  bool get hasFile;
  @override
  double get progress;
  @override
  double get networkSpeed;
  @override
  Duration get timeRemaining;
  @override
  bool get downloading;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
