import 'package:flutter/foundation.dart';

@immutable
final class Message {
  final int id;
  final String content;
  final bool isMine;
  final bool changing;

  const Message({
    required this.id,
    required this.content,
    required this.isMine,
    this.changing = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"] as int,
      content: json["content"] as String,
      isMine: json["roleType"] == 1,
      changing: false,
    );
  }

  // TODO: Use cursor to add "其他的" 结构
}

