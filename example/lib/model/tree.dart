import 'package:halo/halo.dart';

class TreeNode<T extends Comparable> {
  final T value;
  int? preferred;
  List<TreeNode<T>> children;
  TreeNode<T>? last;

  TreeNode(
    this.value, {
    this.preferred,
    this.children = const [],
  });

  List<T> get values {
    final result = <T>[];
    TreeNode<T> node = this;
    while (node.children.isNotEmpty) {
      if (node.value == 0) continue;
      result.add(node.value);
      final preferred = node.preferred;
      if (preferred == null) break;
      node = node.children[preferred];
    }
    return result;
  }

  void addAtLast(T value) {
    final last = this.last ?? this;
    if (last.children.isNotEmpty) {
      qqe("last.children is not empty");
      return;
    }

    final child = TreeNode(value);
    last.preferred = 0;
    last.children = [child];
    this.last = child;
  }
}
