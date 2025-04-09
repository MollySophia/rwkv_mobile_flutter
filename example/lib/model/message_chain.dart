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

  /// 用于消息分叉
  ///
  /// - index = 0, 就是重新创建分枝
  /// - index = 1, 刷新第一个 bot 会话
  /// - index = 2, 刷新第二个 user 消息
  /// - index = 3, 刷新第二个 bot 消息
  MessageChain addAt(int id, int index) => MessageChain(ids: [...ids.take(index), id]);

  @override
  String toString() => """
MessageChain(
  length: ${ids.length},
  ids: $ids,
)
""";
}
