// ignore_for_file: unused_element

import 'dart:collection'; // For Queue used in level-order traversal

/// Represents a node in an N-ary tree.
class _TreeNode<T> {
  T data;
  List<_TreeNode<T>> children;

  _TreeNode(this.data) : children = [];

  /// Adds a child node to this node.
  void addChild(_TreeNode<T> child) {
    children.add(child);
  }

  /// Adds a child node with the given data to this node.
  void addChildData(T data) {
    children.add(_TreeNode(data));
  }

  /// Removes a child node from this node.
  /// Returns true if the child was found and removed, false otherwise.
  bool removeChild(_TreeNode<T> child) {
    return children.remove(child);
  }

  /// Removes a child node with the specified data.
  /// Note: This removes the first child found with matching data.
  /// Returns true if a child was found and removed, false otherwise.
  bool removeChildData(T data) {
    final index = children.indexWhere((node) => node.data == data);
    if (index == -1) {
      return false;
    }
    children.removeAt(index);
    return true;
  }
}

/// Represents an N-ary tree structure.
class _NaryTree<T> {
  _TreeNode<T>? root;

  _NaryTree([this.root]);

  /// Checks if the tree is empty.
  bool get isEmpty => root == null;

  /// Finds a node with the specified data using Breadth-First Search (Level Order).
  /// Returns the node if found, null otherwise.
  _TreeNode<T>? find(T data) {
    if (root == null) return null;

    final queue = Queue<_TreeNode<T>>();
    queue.add(root!);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current.data == data) return current;

      for (final child in current.children) {
        queue.add(child);
      }
    }
    return null;
  }

  /// Performs a pre-order traversal of the tree.
  List<T> preOrderTraversal() {
    if (root == null) return [];
    final result = <T>[];
    _preOrder(root!, result);
    return result;
  }

  void _preOrder(_TreeNode<T> node, List<T> result) {
    result.add(node.data);
    for (final child in node.children) {
      _preOrder(child, result);
    }
  }

  /// Performs a post-order traversal of the tree.
  List<T> postOrderTraversal() {
    if (root == null) return [];
    final result = <T>[];
    _postOrder(root!, result);
    return result;
  }

  void _postOrder(_TreeNode<T> node, List<T> result) {
    for (final child in node.children) {
      _postOrder(child, result);
    }
    result.add(node.data);
  }

  /// Performs a level-order (BFS) traversal of the tree.
  List<T> levelOrderTraversal() {
    if (root == null) return [];

    final result = <T>[];
    final queue = Queue<_TreeNode<T>>();
    queue.add(root!);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(current.data);
      for (final child in current.children) {
        queue.add(child);
      }
    }
    return result;
  }

  /// Calculates the height of the tree.
  /// The height of an empty tree is -1, a tree with only a root is 0.
  int height() {
    if (root == null) return -1;
    return _height(root!);
  }

  int _height(_TreeNode<T> node) {
    if (node.children.isEmpty) return 0;

    var maxHeight = 0;
    for (final child in node.children) {
      final childHeight = _height(child);
      if (childHeight > maxHeight) {
        maxHeight = childHeight;
      }
    }
    return maxHeight + 1;
  }

  /// Counts the total number of nodes in the tree.
  int countNodes() {
    if (root == null) return 0;
    return _countNodesRecursive(root!);
  }

  int _countNodesRecursive(_TreeNode<T> node) {
    var count = 1; // Count the current node
    for (final child in node.children) {
      count += _countNodesRecursive(child);
    }
    return count;
  }

  // --- Potential Methods to Add ---

  // TODO: Implement insert(T data, T parentData) - Insert data as a child of parentData
  // TODO: Implement remove(T data) - Remove node with data (and its subtree)
  // TODO: Implement clear() - Remove all nodes from the tree
  // TODO: Implement getDepth(T data) - Find the depth of a node with specific data
  // TODO: Implement getLevel(T data) - Alias for getDepth
  // TODO: Implement toString() for better representation
}
