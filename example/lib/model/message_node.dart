import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MessageNode extends Equatable {
  final int messageId;
  final List<int> children;
  final int actived;

  const MessageNode(
    this.children,
    this.actived, {
    required this.messageId,
  });

  factory MessageNode.fromJson(Map<String, dynamic> json) {
    return MessageNode(
      json["c"] as List<int>,
      json["a"] as int,
      messageId: json["m"] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "c": children,
      "a": actived,
      "m": messageId,
    };
  }

  @override
  List<Object?> get props => [messageId, ...children, actived];
}
