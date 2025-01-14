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

  Message copyWith({
    int? id,
    String? content,
    bool? isMine,
    bool? changing,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      changing: changing ?? this.changing,
    );
  }

  @override
  String toString() {
    return "Message(\nid: $id\ncontent: $content\nisMine: $isMine\nchanging: $changing)";
  }
}
