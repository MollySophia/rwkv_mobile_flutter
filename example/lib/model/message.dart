import 'package:flutter/foundation.dart';

@immutable
final class Message {
  final int id;
  final String content;
  final bool isMine;
  final bool changing;
  final bool isReasoning;

  const Message({
    required this.id,
    required this.content,
    required this.isMine,
    this.changing = false,
    required this.isReasoning,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"] as int,
      content: json["content"] as String,
      isMine: json["roleType"] == 1,
      changing: false,
      isReasoning: json["isReasoning"] ?? false,
    );
  }

  Message copyWith({
    int? id,
    String? content,
    bool? isMine,
    bool? changing,
    bool? isReasoning,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      changing: changing ?? this.changing,
      isReasoning: isReasoning ?? this.isReasoning,
    );
  }

  @override
  String toString() {
    return "Message(\nid: $id\ncontent: $content\nisMine: $isMine\nchanging: $changing\nisReasoning: $isReasoning)";
  }
}
