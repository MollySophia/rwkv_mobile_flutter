part of 'p.dart';

class _Msg {
  late final pool = qs<Map<int, Message>>({});
  late final ids = qs<List<int>>([]);
  late final latestClicked = qs<Message?>(null);

  late final editingOrRegeneratingIndex = qs<int?>(null);

  MsgNode _msgNode = MsgNode(0);

  late final list = qp<List<Message>>((ref) {
    final ids = ref.watch(this.ids);
    final pool = ref.watch(this.pool);
    return ids.m((id) => pool[id]).withoutNull;
  });

  late final editingBotMessage = qp<bool>((ref) {
    final editingIndex = ref.watch(editingOrRegeneratingIndex);
    if (editingIndex == null) return false;
    final list = ref.watch(P.msg.list);
    return list[editingIndex].isMine == false;
  });
}

/// Private methods
extension _$Msg on _Msg {
  FV _init() async {
    switch (P.app.demoType.q) {
      case DemoType.fifthteenPuzzle:
      case DemoType.othello:
      case DemoType.sudoku:
        return;
      case DemoType.chat:
      case DemoType.tts:
      case DemoType.world:
    }
    qq;
  }

  Message? findByIndex(int index) {
    final currentMessages = [...P.msg.list.q];
    if (index < 0 || index >= currentMessages.length) return null;
    return currentMessages[index];
  }
}

/// Public methods
extension $Msg on _Msg {
  void clear() {
    ids.q = [];
    _msgNode = MsgNode(0);
  }
}
