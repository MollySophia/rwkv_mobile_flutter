import 'package:flutter/foundation.dart';

enum MessageType {
  text,
  userImage,
  userAudio,
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
  final int? audioLength;
  final bool isReasoning;

  const Message({
    required this.id,
    required this.content,
    required this.isMine,
    required this.isReasoning,
    this.changing = false,
    this.type = MessageType.text,
    this.imageUrl,
    this.audioUrl,
    this.audioLength,
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
      audioLength: json["audioLength"] as int?,
      isReasoning: json["isReasoning"] as bool,
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
    int? audioLength,
    bool? isReasoning,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isMine: isMine ?? this.isMine,
      changing: changing ?? this.changing,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      audioLength: audioLength ?? this.audioLength,
      isReasoning: isReasoning ?? this.isReasoning,
    );
  }

  @override
  String toString() {
    return """
Message(
  id: $id,
  content: $content,
  isMine: $isMine,
  changing: $changing,
  type: $type,
  imageUrl: $imageUrl,
  audioUrl: $audioUrl,
  audioLength: $audioLength,
  isReasoning: $isReasoning,
)""";
  }
}
