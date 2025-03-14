import 'package:flutter/foundation.dart';

enum MessageType {
  text,
  image,
  audio,
}

@immutable
final class Message {
  final int id;
  final String content;
  final bool isMine;
  final bool changing;
  final MessageType type;
  final String? imageUrl;
  final String? audioUrl;

  const Message({
    required this.id,
    required this.content,
    required this.isMine,
    this.changing = false,
    this.type = MessageType.text,
    this.imageUrl,
    this.audioUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"] as int,
      content: json["content"] as String,
      isMine: json["roleType"] == 1,
      changing: false,
      type: json["type"] as MessageType,
      imageUrl: json["imageUrl"] as String?,
      audioUrl: json["audioUrl"] as String?,
    );
  }

  Message copyWith({
    int? id,
    String? content,
    bool? isMine,
    bool? changing,
    MessageType? type,
    String? imageUrl,
    String? audioUrl,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      changing: changing ?? this.changing,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  String toString() {
    return "Message(\nid: $id\ncontent: $content\nisMine: $isMine\nchanging: $changing\ntype: $type\nimageUrl: $imageUrl\naudioUrl: $audioUrl)";
  }
}
