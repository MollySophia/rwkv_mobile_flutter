// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weights.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Weights {
  String get name;
  String get type;
  double? get modelSize;
  String get fileName;
  int get fileSize;
  String get url;
  String? get quantization;
  List<String> get platforms;
  List<String>? get backends;
  String? get sha256;
  List<String>? get tags;
  String? get source;
  List<String>? get socLimitations;

  /// Create a copy of Weights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WeightsCopyWith<Weights> get copyWith =>
      _$WeightsCopyWithImpl<Weights>(this as Weights, _$identity);

  /// Serializes this Weights to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Weights &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.modelSize, modelSize) ||
                other.modelSize == modelSize) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.quantization, quantization) ||
                other.quantization == quantization) &&
            const DeepCollectionEquality().equals(other.platforms, platforms) &&
            const DeepCollectionEquality().equals(other.backends, backends) &&
            (identical(other.sha256, sha256) || other.sha256 == sha256) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality()
                .equals(other.socLimitations, socLimitations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      type,
      modelSize,
      fileName,
      fileSize,
      url,
      quantization,
      const DeepCollectionEquality().hash(platforms),
      const DeepCollectionEquality().hash(backends),
      sha256,
      const DeepCollectionEquality().hash(tags),
      source,
      const DeepCollectionEquality().hash(socLimitations));

  @override
  String toString() {
    return 'Weights(name: $name, type: $type, modelSize: $modelSize, fileName: $fileName, fileSize: $fileSize, url: $url, quantization: $quantization, platforms: $platforms, backends: $backends, sha256: $sha256, tags: $tags, source: $source, socLimitations: $socLimitations)';
  }
}

/// @nodoc
abstract mixin class $WeightsCopyWith<$Res> {
  factory $WeightsCopyWith(Weights value, $Res Function(Weights) _then) =
      _$WeightsCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String type,
      double? modelSize,
      String fileName,
      int fileSize,
      String url,
      String? quantization,
      List<String> platforms,
      List<String>? backends,
      String? sha256,
      List<String>? tags,
      String? source,
      List<String>? socLimitations});
}

/// @nodoc
class _$WeightsCopyWithImpl<$Res> implements $WeightsCopyWith<$Res> {
  _$WeightsCopyWithImpl(this._self, this._then);

  final Weights _self;
  final $Res Function(Weights) _then;

  /// Create a copy of Weights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? modelSize = freezed,
    Object? fileName = null,
    Object? fileSize = null,
    Object? url = null,
    Object? quantization = freezed,
    Object? platforms = null,
    Object? backends = freezed,
    Object? sha256 = freezed,
    Object? tags = freezed,
    Object? source = freezed,
    Object? socLimitations = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      modelSize: freezed == modelSize
          ? _self.modelSize
          : modelSize // ignore: cast_nullable_to_non_nullable
              as double?,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      quantization: freezed == quantization
          ? _self.quantization
          : quantization // ignore: cast_nullable_to_non_nullable
              as String?,
      platforms: null == platforms
          ? _self.platforms
          : platforms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      backends: freezed == backends
          ? _self.backends
          : backends // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sha256: freezed == sha256
          ? _self.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      source: freezed == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      socLimitations: freezed == socLimitations
          ? _self.socLimitations
          : socLimitations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Weights extends Weights {
  const _Weights(
      {required this.name,
      required this.type,
      required this.modelSize,
      required this.fileName,
      required this.fileSize,
      required this.url,
      required this.quantization,
      required final List<String> platforms,
      required final List<String>? backends,
      required this.sha256,
      required final List<String>? tags,
      required this.source,
      required final List<String>? socLimitations})
      : _platforms = platforms,
        _backends = backends,
        _tags = tags,
        _socLimitations = socLimitations,
        super._();
  factory _Weights.fromJson(Map<String, dynamic> json) =>
      _$WeightsFromJson(json);

  @override
  final String name;
  @override
  final String type;
  @override
  final double? modelSize;
  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final String url;
  @override
  final String? quantization;
  final List<String> _platforms;
  @override
  List<String> get platforms {
    if (_platforms is EqualUnmodifiableListView) return _platforms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_platforms);
  }

  final List<String>? _backends;
  @override
  List<String>? get backends {
    final value = _backends;
    if (value == null) return null;
    if (_backends is EqualUnmodifiableListView) return _backends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? sha256;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? source;
  final List<String>? _socLimitations;
  @override
  List<String>? get socLimitations {
    final value = _socLimitations;
    if (value == null) return null;
    if (_socLimitations is EqualUnmodifiableListView) return _socLimitations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of Weights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WeightsCopyWith<_Weights> get copyWith =>
      __$WeightsCopyWithImpl<_Weights>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WeightsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Weights &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.modelSize, modelSize) ||
                other.modelSize == modelSize) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.quantization, quantization) ||
                other.quantization == quantization) &&
            const DeepCollectionEquality()
                .equals(other._platforms, _platforms) &&
            const DeepCollectionEquality().equals(other._backends, _backends) &&
            (identical(other.sha256, sha256) || other.sha256 == sha256) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality()
                .equals(other._socLimitations, _socLimitations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      type,
      modelSize,
      fileName,
      fileSize,
      url,
      quantization,
      const DeepCollectionEquality().hash(_platforms),
      const DeepCollectionEquality().hash(_backends),
      sha256,
      const DeepCollectionEquality().hash(_tags),
      source,
      const DeepCollectionEquality().hash(_socLimitations));

  @override
  String toString() {
    return 'Weights(name: $name, type: $type, modelSize: $modelSize, fileName: $fileName, fileSize: $fileSize, url: $url, quantization: $quantization, platforms: $platforms, backends: $backends, sha256: $sha256, tags: $tags, source: $source, socLimitations: $socLimitations)';
  }
}

/// @nodoc
abstract mixin class _$WeightsCopyWith<$Res> implements $WeightsCopyWith<$Res> {
  factory _$WeightsCopyWith(_Weights value, $Res Function(_Weights) _then) =
      __$WeightsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String type,
      double? modelSize,
      String fileName,
      int fileSize,
      String url,
      String? quantization,
      List<String> platforms,
      List<String>? backends,
      String? sha256,
      List<String>? tags,
      String? source,
      List<String>? socLimitations});
}

/// @nodoc
class __$WeightsCopyWithImpl<$Res> implements _$WeightsCopyWith<$Res> {
  __$WeightsCopyWithImpl(this._self, this._then);

  final _Weights _self;
  final $Res Function(_Weights) _then;

  /// Create a copy of Weights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? modelSize = freezed,
    Object? fileName = null,
    Object? fileSize = null,
    Object? url = null,
    Object? quantization = freezed,
    Object? platforms = null,
    Object? backends = freezed,
    Object? sha256 = freezed,
    Object? tags = freezed,
    Object? source = freezed,
    Object? socLimitations = freezed,
  }) {
    return _then(_Weights(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      modelSize: freezed == modelSize
          ? _self.modelSize
          : modelSize // ignore: cast_nullable_to_non_nullable
              as double?,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      quantization: freezed == quantization
          ? _self.quantization
          : quantization // ignore: cast_nullable_to_non_nullable
              as String?,
      platforms: null == platforms
          ? _self._platforms
          : platforms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      backends: freezed == backends
          ? _self._backends
          : backends // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sha256: freezed == sha256
          ? _self.sha256
          : sha256 // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      source: freezed == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      socLimitations: freezed == socLimitations
          ? _self._socLimitations
          : socLimitations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

// dart format on
