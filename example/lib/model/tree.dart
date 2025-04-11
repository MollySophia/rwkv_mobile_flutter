class TreeNode {
  final int value;
  int? preferred;
  List<TreeNode> children;
  TreeNode? last;

  TreeNode(this.value, {this.preferred, this.children = const []});

  List get values {
    var result = [];
    TreeNode node = this;
    while (true) {
      result.add(node.value);
      if (node.children.isEmpty) break;
      node = node.children[node.preferred!];
    }
    assert(result.isNotEmpty);
    result = result.skip(1).toList();
    return result;
  }

  void addAtLast(int value) {
    late final TreeNode last;

    if (this.last == null) {
      last = this;
    } else {
      last = this.last!;
    }

    if (last.children.isNotEmpty) {
      throw "last.children is not empty";
    }

    final child = TreeNode(value);
    last.preferred = 0;
    last.children = [child];
    this.last = child;
  }

  void addAt(int value, int level) {
    TreeNode node = this;

    do {
      node = node.children[node.preferred!];
      level--;
    } while (level > 0);

    node.children = [...node.children, TreeNode(value)];
    node.preferred = node.children.length - 1;
  }
}
