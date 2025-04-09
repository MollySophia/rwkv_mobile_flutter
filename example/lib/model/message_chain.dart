import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
final class MessageChain extends Equatable {
  final List<int> ids;

  const MessageChain({required this.ids});

  @override
  List<Object?> get props => [...ids];

  factory MessageChain.fromJson(List<int> json) => MessageChain(ids: json);

  Map<String, dynamic> toJson() => {"ids": ids};

  MessageChain add(int id) => MessageChain(ids: [...ids, id]);
}
