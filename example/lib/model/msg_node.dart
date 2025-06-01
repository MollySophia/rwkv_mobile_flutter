final class MsgNode {
  int id;
  List<MsgNode> children;
  MsgNode? latest;
  MsgNode? parent;
  MsgNode? root;

  MsgNode(
    this.id, {
    this.children = const [],
    this.latest,
    this.parent,
    this.root,
  });

  void addChild(MsgNode child, {bool keepLatest = false}) {
    child.parent = this;
    child.root = root;
    children.add(child);
    if (!keepLatest) latest = child;
  }

  MsgNode? findNodeByMsgId(int msgId) => root?.findInChildren(msgId);

  MsgNode? findParentByMsgId(int msgId) => root?.findInChildren(msgId)?.parent;

  MsgNode? findInChildren(int msgId) {
    for (final child in children) {
      if (child.id == msgId) return child;
      final res = child.findInChildren(msgId);
      if (res != null) return res;
    }
    return null;
  }

  List<int> msgIdsFrom(MsgNode node) {
    final msgIds = <int>[node.id];
    var current = node.parent;
    while (current != null) {
      msgIds.add(current.id);
      current = current.parent;
    }
    return msgIds;
  }
}
