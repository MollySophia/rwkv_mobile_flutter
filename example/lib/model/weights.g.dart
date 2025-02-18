// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightsImpl _$$WeightsImplFromJson(Map<String, dynamic> json) =>
    _$WeightsImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      modelSize: (json['modelSize'] as num).toDouble(),
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      fileSizeString: json['fileSizeString'] as String,
      url: json['url'] as String,
      quantization: json['quantization'] as String,
      platforms:
          (json['platforms'] as List<dynamic>).map((e) => e as String).toList(),
      backends:
          (json['backends'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$WeightsImplToJson(_$WeightsImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'modelSize': instance.modelSize,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'fileSizeString': instance.fileSizeString,
      'url': instance.url,
      'quantization': instance.quantization,
      'platforms': instance.platforms,
      'backends': instance.backends,
    };
