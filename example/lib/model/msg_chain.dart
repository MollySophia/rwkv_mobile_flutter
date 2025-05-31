import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
final class MsgChain extends Equatable {
  final int id;
  final List<int> messageIds;

  const MsgChain({required this.id, required this.messageIds});

  @override
  List<Object?> get props => [id, ...messageIds];

  factory MsgChain.fromJson(Map<String, dynamic> json) => MsgChain(
    id: json["id"],
    messageIds: json["messageIds"],
  );
}
