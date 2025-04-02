import 'package:equatable/equatable.dart';
import 'package:zone/model/message.dart';

final class Conversation extends Equatable {
  final int id;
  final String name;
  final List<Message> messages;

  const Conversation({required this.id, required this.name, required this.messages});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      name: json['name'],
      messages: json['messages'].map((message) => Message.fromJson(message)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}
