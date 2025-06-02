import 'package:test/test.dart';
import 'package:zone/model/msg_node.dart';

// Helper class to build test data
class TestMsgBuilder {
  final MsgNode rootNode;

  TestMsgBuilder(this.rootNode);

  MsgNode buildChain(List<int> ids, {MsgNode? startNode, bool keepLatest = false}) {
    var current = startNode ?? rootNode;
    for (final id in ids) {
      current = current.add(MsgNode(id), keepLatest: keepLatest);
    }
    return current; // Returns the last added node
  }

  // Builds a linear conversation alternating user/bot
  List<MsgNode> buildLinearConversation(int turns, {int startId = 1}) {
    final nodes = <MsgNode>[];
    var currentParent = rootNode;
    var currentId = startId;

    for (var i = 0; i < turns; i++) {
      final userMsg = currentParent.add(MsgNode(currentId++));
      nodes.add(userMsg);
      if (i < turns) {
        // Add bot message corresponding to user message
        final botMsg = userMsg.add(MsgNode(currentId++));
        nodes.add(botMsg);
        currentParent = botMsg;
      } else {
        currentParent = userMsg;
      }
    }
    return nodes;
  }
}

void main() {
  late MsgNode root;
  late TestMsgBuilder builder;

  setUp(() {
    root = MsgNode(0);
    builder = TestMsgBuilder(root);
  });

  group('基本构造和属性', () {
    test('节点初始化正确', () {
      expect(root.id, 0);
      expect(root.children, isEmpty);
      expect(root.latest, isNull);
      expect(root.parent, isNull);
      expect(root.root, isNull);
    });

    test('子节点被添加后, parent 和 root 被正确设置', () {
      final child = MsgNode(1);
      root.add(child);
      expect(child.parent, root);
      expect(child.root, root);
      expect(root.children, contains(child));
    });

    test('深层子节点的 root 仍指向初始根节点', () {
      final child1 = root.add(MsgNode(1));
      final child2 = child1.add(MsgNode(2));
      expect(child2.root, root);
    });
  });

  group('`add` 方法', () {
    test('可以添加子节点, `latest` 默认更新', () {
      final child1 = root.add(MsgNode(1));
      expect(root.latest, child1);
      expect(root.children, contains(child1));

      final child2 = root.add(MsgNode(2));
      expect(root.latest, child2, reason: "Latest should update to the newest child");
      expect(root.children, containsAll([child1, child2]));
    });

    test('使用 `keepLatest: true` 时, `latest` 不更新', () {
      final child1 = root.add(MsgNode(1));
      expect(root.latest, child1);

      final child2 = root.add(MsgNode(2), keepLatest: true);
      expect(root.latest, child1, reason: "Latest should not update if keepLatest is true");
      expect(root.children, contains(child2));
    });

    test('不允许添加重复 ID 的直接子节点', () {
      root.add(MsgNode(1));
      expect(
        () => root.add(MsgNode(1)),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('`rootAdd` 方法', () {
    // This method's behavior is a bit intricate as child.parent becomes wholeLatestNode,
    // but child is added to 'this.children'.
    test('简单调用 (当 this 是 wholeLatestNode 时, 行为类似 add)', () {
      final child1 = root.rootAdd(MsgNode(1)); // root.wholeLatestNode is root itself
      expect(child1.parent, root);
      expect(root.children, contains(child1));
      expect(root.latest, child1);

      final child2 = child1.rootAdd(MsgNode(2)); // child1.wholeLatestNode is child1
      expect(child2.parent, child1);
      expect(child1.children, contains(child2));
      expect(child1.latest, child2);
      expect(root.latestMsgIds, [0, 1, 2]);
    });

    test('使用 `keepLatest: true` 时, `latest` 不更新 (当 this 是 wholeLatestNode)', () {
      final child1 = root.rootAdd(MsgNode(1));
      expect(root.latest, child1);

      root.rootAdd(MsgNode(2), keepLatest: true);
      expect(root.latest, child1, reason: "Latest should not update for rootAdd if keepLatest is true");
    });
  });

  group('`latestMsgIds` 属性', () {
    test('空树返回自身 ID', () {
      expect(root.latestMsgIds, [0]);
    });

    test('单链消息列表', () {
      builder.buildLinearConversation(3, startId: 1); // 0->1->2->3->4->5->6
      expect(root.latestMsgIds, [0, 1, 2, 3, 4, 5, 6]);
    });

    test('编辑历史消息并创建新分支后, `latestMsgIds` 反映新分支', () {
      final nodes = builder.buildLinearConversation(2, startId: 1); // 0->1->2->3->4
      final botMsg0 = nodes[1]; // This is node(2), parent is node(1)

      botMsg0.add(MsgNode(5)); // botMsg0 (node 2) now has a new latest child node(5)
      // root.latest is node(1), node(1).latest is node(2), node(2).latest is node(5)
      expect(root.latestMsgIds, [0, 1, 2, 5]);
    });

    test('切换分支 (手动修改 parent.latest) 后 `latestMsgIds` 更新', () {
      final node1 = root.add(MsgNode(1));
      final node2 = node1.add(MsgNode(2)); // node1.latest = node2 (original branch)
      node1.add(MsgNode(3)); // node1.latest = node3 (new branch)

      expect(root.latestMsgIds, [0, 1, 3], reason: "Should follow the newest branch by default");

      node1.latest = node2; // Manually switch node1's latest back to node2
      expect(root.latestMsgIds, [0, 1, 2], reason: "Should follow the manually set latest branch");
    });
  });

  group('`wholeLatestMsgId` 和 `wholeLatestNode` 属性', () {
    test('空树的 `wholeLatestMsgId` 是自身 ID', () {
      expect(root.wholeLatestMsgId, 0);
      expect(root.wholeLatestNode, root);
    });

    test('单链消息列表的 `wholeLatestMsgId`', () {
      builder.buildLinearConversation(3, startId: 1); // Ends at ID 6
      expect(root.wholeLatestMsgId, 6);
      expect(root.wholeLatestNode.id, 6);
    });

    test('有分支时, `wholeLatestMsgId` 指向最新的分支的末端', () {
      final node1 = root.add(MsgNode(1));
      node1.add(MsgNode(2)); // Main branch: 0 -> 1 -> 2. root.latest=1, node1.latest=2

      final node3 = node1.add(MsgNode(3)); // New branch from node1: 0 -> 1 -> 3. node1.latest=3
      // root.latest is node1. node1.latest is node3.
      expect(root.wholeLatestMsgId, 3);
      expect(root.wholeLatestNode, node3);

      // If another branch from root
      final node4 = root.add(MsgNode(4)); // root.latest=4
      expect(root.wholeLatestMsgId, 4); // Now the whole latest from root is node4
      expect(root.wholeLatestNode, node4);
    });
  });

  group('`findNodeByMsgId` 和 `findParentByMsgId`', () {
    setUp(() {
      // Structure:
      // 0
      // |- 1
      //    |- 2
      //    |- 3
      //       |- 4
      // |- 5
      final node1 = root.add(MsgNode(1));
      node1.add(MsgNode(2));
      final node3 = node1.add(MsgNode(3));
      node3.add(MsgNode(4));
      root.add(MsgNode(5));
    });

    test('可以找到存在的节点', () {
      expect(root.findNodeByMsgId(0)?.id, 0);
      expect(root.findNodeByMsgId(1)?.id, 1);
      expect(root.findNodeByMsgId(4)?.id, 4);
      expect(root.findNodeByMsgId(5)?.id, 5);
    });

    test('找不到不存在的节点时返回 null', () {
      expect(root.findNodeByMsgId(99), isNull);
    });

    test('可以找到节点的父节点', () {
      expect(root.findParentByMsgId(1)?.id, 0);
      expect(root.findParentByMsgId(4)?.id, 3);
      expect(root.findParentByMsgId(5)?.id, 0);
    });

    test('根节点的父节点为 null (通过find)', () {
      // root.findNodeByMsgId(0) is root. root.parent is null.
      expect(root.findNodeByMsgId(0)?.parent, isNull);
      // findParentByMsgId(0) would search for node 0, then get its parent.
      expect(root.findParentByMsgId(0), isNull);
    });

    test('查找不存在的节点的父节点返回 null', () {
      expect(root.findParentByMsgId(99), isNull);
    });
  });

  group('`msgIdsFrom` 方法', () {
    test('从指定节点追溯到根的 ID 列表', () {
      final node1 = root.add(MsgNode(1));
      final node2 = node1.add(MsgNode(2));
      final node3 = node2.add(MsgNode(3));

      // Expected order: [current, parent, grandparent, ...]
      expect(root.msgIdsFrom(node3), [3, 2, 1, 0]);
      expect(root.msgIdsFrom(node1), [1, 0]);
      expect(root.msgIdsFrom(root), [0]);
    });

    test('从孤立节点（未添加到树）调用', () {
      final isolatedNode = MsgNode(100);
      // Assuming msgIdsFrom is called on an instance that has access to this isolatedNode somehow,
      // or it's a static method (it's not). If called as isolatedNode.msgIdsFrom(isolatedNode):
      final tempRoot = MsgNode(99); // just to call the instance method
      expect(tempRoot.msgIdsFrom(isolatedNode), [100]);

      final childOfIsolated = MsgNode(101);
      childOfIsolated.parent = isolatedNode; // Manually linking
      expect(tempRoot.msgIdsFrom(childOfIsolated), [101, 100]);
    });
  });

  group('边界条件和错误处理', () {
    test('在空消息树上操作', () {
      expect(root.latestMsgIds, [0]);
      expect(root.wholeLatestMsgId, 0);
      expect(root.findNodeByMsgId(0)?.id, 0);
      expect(root.findNodeByMsgId(1), isNull);
    });

    test('重复添加相同 ID 的子节点抛出 AssertionError (using add)', () {
      root.add(MsgNode(1));
      expect(
        () => root.add(MsgNode(1)),
        throwsA(isA<AssertionError>()),
        reason: '不应该允许通过 `add` 添加重复ID的消息',
      );
    });

    test('重复添加相同 ID 的子节点抛出 AssertionError (using rootAdd)', () {
      root.rootAdd(MsgNode(1)); // Assumes root is wholeLatestNode here
      expect(
        () => root.rootAdd(MsgNode(1)),
        throwsA(isA<AssertionError>()),
        reason: '不应该允许通过 `rootAdd` 添加重复ID的消息到当前节点的 children',
      );
    });
  });

  // Preserving some of your original structural tests if they cover specific scenarios
  group('原有消息树操作场景 (复核)', () {
    test('链式调用构建消息树 (`add`)', () {
      root.add(MsgNode(1)).add(MsgNode(2)); // User message then bot message
      expect(root.latestMsgIds, [0, 1, 2]);
    });

    test('Random test B from original, step-by-step with `add` and `latest` updates', () {
      // 用户输入消息 0
      final userMsg0 = root.add(MsgNode(1)); // root.latest = 1
      expect(root.latestMsgIds, [0, 1]);
      expect(root.wholeLatestMsgId, 1);
      // 回复消息 0
      final botMsg0 = userMsg0.add(MsgNode(2)); // userMsg0.latest = 2
      expect(root.latestMsgIds, [0, 1, 2]);
      expect(root.wholeLatestMsgId, 2);

      // ... (continuing the logic from your "Random test, B")
      final userMsg1 = botMsg0.add(MsgNode(3)); // botMsg0.latest = 3
      final botMsg1 = userMsg1.add(MsgNode(4)); // userMsg1.latest = 4
      expect(root.latestMsgIds, [0, 1, 2, 3, 4]);

      // 编辑了 user message 2 (original test implies editing leads to a new branch from botMsg1)
      // Your original "Random test, B" was effectively testing branching by adding to a previous node.
      // "编辑了 user message 2" -> let's assume this means adding a new response to botMsg1 (node 4)
      // Original sequence was: 0-1-2-3-4-5-6-7-8
      // Then "编辑 user message 1" (node 3) which was parent of node 4 (botMsg1)
      // Effectively doing: botMsg0.add(MsgNode(9)) -> userMsg4

      // Recreating a similar scenario:
      // Original line: 0 -> 1 -> 2 -> 3 -> 4
      // At this point, root.latest=1, node(1).latest=2, node(2).latest=3, node(3).latest=4

      // User "edits" by branching off node(2) (botMsg0)
      final userMsg4 = botMsg0.add(MsgNode(9)); // botMsg0.latest = 9. Old child node(3) is still there.
      expect(root.latestMsgIds, [0, 1, 2, 9], reason: "Path should follow new latest from botMsg0");
      expect(botMsg0.children.length, 2); // node(3) and node(9)
      expect(botMsg0.latest?.id, 9);

      final botMsg4 = userMsg4.add(MsgNode(10)); // userMsg4.latest = 10
      expect(root.latestMsgIds, [0, 1, 2, 9, 10]);
      expect(root.wholeLatestMsgId, 10);

      // "通过点击第二个用户消息下方的切换按钮, 切回了第一条线"
      // This means botMsg0.latest is set back to node(3)
      botMsg0.latest = userMsg1; // userMsg1 is node(3)
      expect(root.latestMsgIds, [0, 1, 2, 3, 4], reason: "Path restored to original branch up to node(4)");
      expect(root.wholeLatestMsgId, 4);

      // Continue adding to the end of this restored branch (node 4, which is botMsg1)
      final _ = botMsg1.add(MsgNode(15));
      expect(root.latestMsgIds, [0, 1, 2, 3, 4, 15]);
      expect(root.wholeLatestMsgId, 15);
    });
  });
}
