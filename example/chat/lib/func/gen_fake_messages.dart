import 'package:chat/model/message.dart';
import 'package:halo/halo.dart';

Future<List<Message>> genFakeMessages() async {
  final ms = HF.randomInt(max: 1000);
  await Future.delayed(ms.ms);
  final iter = HF.randomInt(max: 50);
  final count = iter * 2;
  final messages = <Message>[];
  for (var i = 0; i < count; i++) {
    final isMine = i % 2 == 0;
    final content = HF.randomString(max: isMine ? 100 : 500);
    final message = Message(id: i, content: content, isMine: isMine);
    messages.add(message);
  }
  return messages;
}
