part of 'p.dart';

class _Conversation {
  final conversations = qs<List<Conversation>>([]);
  final current = qs<Conversation?>(null);
}

/// Private methods
extension _$Conversation on _Conversation {
  FV _init() async {
    qq;
    if (!Config.enableConversation) return;
    await load();
  }

  String _getConversationPath(int id) {
    final dir = P.app.documentsDir.v;
    if (dir == null) return "";
    return "$dir/conversation_$id.json";
  }
}

/// Public methods
extension $Conversation on _Conversation {
  FV load() async {
    final dir = P.app.documentsDir.v;
    if (dir == null) {
      qqe("Failed to load conversations: No documents directory found");
      return;
    }

    final directory = Directory(dir.path);
    final files = await directory.list().toList();
    final conversationFiles = files.where((file) => file.path.contains('conversation_')).toList();

    final loadedConversations = <Conversation>[];
    for (final file in conversationFiles) {
      try {
        final content = await File(file.path).readAsString();
        final json = jsonDecode(content);
        final conversation = Conversation.fromJson(json);
        loadedConversations.add(conversation);
      } catch (e) {
        qqe("Failed to load conversation");
        qqe(e);
      }
    }

    // Sort conversations by id in descending order (newest first)
    loadedConversations.sort((a, b) => b.id.compareTo(a.id));
    conversations.u(loadedConversations);
  }

  FV delete(int id) async {
    // Remove from memory
    conversations.u(conversations.v.where((c) => c.id != id).toList());
    if (current.v?.id == id) {
      current.u(null);
    }

    // Delete file
    final file = File(_getConversationPath(id));
    if (await file.exists()) {
      await file.delete();
    }
  }

  FV addMessage(Message message, [Conversation? conversation]) async {
    if (conversation == null) {
      // Create new conversation
      final newId = conversations.v.isEmpty ? 1 : (conversations.v.firstOrNull?.id ?? 0) + 1;
      conversation = Conversation(
        id: newId,
        name: message.content.substring(0, message.content.length.clamp(0, 30)) + (message.content.length > 30 ? "..." : ""),
        messages: [message],
      );
    } else {
      // Add message to existing conversation
      conversation = Conversation(
        id: conversation.id,
        name: conversation.name,
        messages: [...conversation.messages, message],
      );
    }

    // Update memory
    if (conversations.v.any((c) => c.id == conversation!.id)) {
      final updatedConversations = conversations.v.map((c) {
        if (c.id == conversation!.id) {
          return conversation;
        }
        return c;
      }).toList();
      conversations.u(updatedConversations);
    } else {
      conversations.u([conversation, ...conversations.v]);
    }
    current.u(conversation);

    // Save to file
    final file = File(_getConversationPath(conversation.id));
    await file.writeAsString(jsonEncode(conversation.toJson()));
  }

  FV removeMessage(Message message, {required Conversation conversation}) async {}

  FV updateMessage(Message message, {required Conversation conversation}) async {}
}
