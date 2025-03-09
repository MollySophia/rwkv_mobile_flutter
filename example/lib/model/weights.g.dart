// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weights _$WeightsFromJson(Map<String, dynamic> json) => _Weights(
      name: json['name'] as String,
      type: json['type'] as String,
      modelSize: (json['modelSize'] as num?)?.toDouble(),
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      url: json['url'] as String,
      quantization: json['quantization'] as String?,
      platforms:
          (json['platforms'] as List<dynamic>).map((e) => e as String).toList(),
      backends: (json['backends'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sha256: json['sha256'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$WeightsToJson(_Weights instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'modelSize': instance.modelSize,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'url': instance.url,
      'quantization': instance.quantization,
      'platforms': instance.platforms,
      'backends': instance.backends,
      'sha256': instance.sha256,
      'tags': instance.tags,
      'source': instance.source,
    };
