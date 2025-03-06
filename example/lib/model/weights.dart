// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'weights.freezed.dart';
part 'weights.g.dart';

@freezed
class Weights with _$Weights {
  const Weights._();

  const factory Weights({
    required String name,
    required String type,
    required double modelSize,
    required String fileName,
    required int fileSize,
    required String url,
    required String quantization,
    required List<String> platforms,
    required List<String> backends,
    required String? sha256,
  }) = _Weights;

  factory Weights.fromJson(Map<String, dynamic> json) => _$WeightsFromJson(json);
}
