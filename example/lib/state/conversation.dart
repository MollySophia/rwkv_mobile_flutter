part of 'p.dart';

class _Conversation {
  final conversations = qs<List<Conversation>>([]);
  final current = qs<Conversation?>(null);
}

/// Private methods
extension _$Conversation on _Conversation {
  FV _init() async {}
}

/// Public methods
extension $Conversation on _Conversation {
  FV load() async {
    // 从 sandbox 中遍历文件夹下的所有文件, 以 string 方式读取, 并解析为 json
    // json 被解析为 Conversation 对象, 并添加到 _conversations 中
  }

  FV delete(int id) async {
    // 从 _conversations 中删除 id 对应的 Conversation 对象
    // 从 sandbox 中删除 id 对应的文件
  }

  FV add(Message message, [Conversation? conversation]) async {
    // 如果 conversation 为 null, 则创建一个新的 Conversation 对象
    // 如果 conversation 不为 null, 则将 message 添加到 conversation 中
    // 将 conversation 保存到 sandbox 中
  }
}
