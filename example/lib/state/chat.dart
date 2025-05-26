part of 'p.dart';

class _Chat {
  /// The key of it is the id of the message
  late final cotDisplayState = qsf<int, CoTDisplayState>(CoTDisplayState.showCotHeaderAndCotContent);

  /// The scroll controller of the chat page message list
  late final scrollController = ScrollController();

  /// The text editing controller of the chat page input
  late final textEditingController = TextEditingController(text: "");

  /// The focus node of the chat page input
  late final focusNode = FocusNode();

  late final textInInput = qs("");

  late final canSend = qp((ref) {
    final textInInput = ref.watch(this.textInInput);
    return textInInput.trim().isNotEmpty;
  });

  /// Disable sender
  ///
  /// TODO: Should be moved to state/rwkv.dart
  late final receivingTokens = qs(false);

  /// TODO: Should be moved to state/rwkv.dart
  late final receivedTokens = qs("");

  late final inputHeight = qs(77.0);

  late final receiveId = qsn<int>();

  late final editingIndex = qsn<int>();

  late final editingBotMessage = qp<bool>((ref) {
    final editingIndex = ref.watch(this.editingIndex);
    if (editingIndex == null) return false;
    return messages.q[editingIndex].isMine == false;
  });

  late final latestClickedMessage = qsn<Message>();

  late final hasFocus = qs(false);

  late final autoPauseId = qsn<int>();

  late final messages = qs<List<Message>>([]);

  /// 用于实现 DeepSeek 的 “分叉对话” 功能
  ///
  /// TODO: 想办法存到聊天记录中
  late final currentChain = qs(const MessageChain(ids: []));

  /// 用于实现 DeepSeek 的 “分叉对话” 功能
  late final chains = qs({const MessageChain(ids: [])});

  /// 用于在切换分叉时, 如果同一层级有多个分叉, 能切回原先的分叉
  late final chainSwitchingHistory = qs<List<MessageChain>>([]);

  late final branchesCountList = qs<List<List<int>>>([]);

  late final _sensitiveThrottler = Throttler(milliseconds: 333, trailing: true);
}

/// Public methods
extension $Chat on _Chat {
  void clearMessages() {
    messages.uc();
    branchesCountList.uc();
    chainSwitchingHistory.uc();
    currentChain.q = const MessageChain(ids: []);
    chains.q = {const MessageChain(ids: [])};
  }

  FV onInputRightButtonPressed() async {
    qq;
    if (P.rwkv.currentModel.q == null) {
      P.fileManager.modelSelectorShown.q = true;
      return;
    }

    if (!canSend.q) return;

    focusNode.unfocus();
    final textToSend = textInInput.q.trim();
    textInInput.uc();

    final _editingBotMessage = editingBotMessage.q;
    if (_editingBotMessage) {
      // final currentMessages = [...messages.q];
      final _editingIndex = editingIndex.q!;
      final id = HF.debugShorterUS;
      final newBotMessage = Message(
        id: id,
        content: textToSend,
        isMine: false,
        changing: false,
        isReasoning: messages.q[_editingIndex].isReasoning,
        paused: messages.q[_editingIndex].paused,
      );
      // currentMessages.replaceRange(_editingIndex, _editingIndex + 1, [newBotMessage]);
      final newMessages = [
        ...messages.q.sublist(0, _editingIndex),
        newBotMessage,
      ];
      messages.q = newMessages;
      P.conversation.updateMessages(newMessages);
      editingIndex.q = null;
      Alert.success(S.current.bot_message_edited);
      return;
    }

    await send(textToSend);
  }

  FV onEditingComplete() async {
    qq;
  }

  FV onSubmitted(String aString) async {
    qqq(aString);

    final receivingTokens = P.chat.receivingTokens.q;

    if (receivingTokens) {
      Alert.info("Please wait for the previous message to be generated");
      return;
    }

    if (P.app.demoType.q == DemoType.tts) {
      await P.tts.gen();
      P.suggestion.loadSuggestions();
      return;
    }

    final textToSend = textInInput.q.trim();
    if (textToSend.isEmpty) return;
    textInInput.uc();
    focusNode.unfocus();
    await send(textToSend);
  }

  FV onTapMessageList() async {
    qq;
    P.chat.focusNode.unfocus();
    P.tts.dismissAllShown();
    final _editingIndex = P.chat.editingIndex.q;
    if (_editingIndex == null) return;
    editingIndex.q = null;
    textEditingController.value = const TextEditingValue(text: "");
  }

  FV onTapEditInUserMessageBubble({required int index}) async {
    final loaded = P.rwkv.loaded.q;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.q = true;
      return;
    }
    final content = messages.q[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.q = index;
  }

  FV onTapEditInBotMessageBubble({required int index}) async {
    // TODO: 这里也要消息分叉
    final loaded = P.rwkv.loaded.q;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.q = true;
      return;
    }
    final content = messages.q[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.q = index;
  }

  FV onRegeneratePressed({required int index}) async {
    qqq("index: $index");
    final loaded = P.rwkv.loaded.q;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.q = true;
      return;
    }

    final userMessage = messages.q[index - 1];
    editingIndex.q = index;
    textInInput.uc();
    focusNode.unfocus();
    if (userMessage.type == MessageType.userAudio) {
      await send(
        "",
        type: MessageType.userAudio,
        audioUrl: userMessage.audioUrl,
        withHistory: false,
        audioLength: userMessage.audioLength,
      );
      return;
    }
    await send(userMessage.content, isRegenerate: true);
  }

  FV scrollToBottom({Duration? duration, bool? animate = true}) async {
    await scrollTo(offset: 0, duration: duration, animate: animate);
  }

  FV scrollTo({required double offset, Duration? duration, bool? animate = true}) async {
    if (scrollController.hasClients == false) return;
    if (scrollController.offset == offset) return;
    if (animate == true) {
      await scrollController.animateTo(
        offset,
        duration: duration ?? 300.ms,
        curve: Curves.easeInOut,
      );
    } else {
      scrollController.jumpTo(offset);
    }
  }

  FV startNewChat() async {
    Alert.success(S.current.new_chat_started);
    P.rwkv.clearStates();
    messages.uc();
  }

  FV send(
    String message, {
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
    int? audioLength,
    bool withHistory = true,
    bool isRegenerate = false,
  }) async {
    qqq("message: $message");

    final _editingIndex = editingIndex.q;
    if (_editingIndex != null) {
      qqq("editingIndex: $_editingIndex");
      assert(_editingIndex >= 0 && _editingIndex < messages.q.length);
      final messagesWithoutEditing = messages.q.sublist(0, _editingIndex);
      // 将 editingIndex, 及 editingIndex 之后的消息都删掉
      // TODO: 分叉
      messages.q = messagesWithoutEditing;
      if (Config.enableConversation) P.conversation.updateMessages(messagesWithoutEditing);
    }

    late final Message? msg;

    final id = HF.debugShorterUS;
    final receiveId = HF.debugShorterUS + 1;

    if (!isRegenerate) {
      msg = Message(
        id: id,
        content: message,
        isMine: true,
        type: type,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        audioLength: audioLength,
        isReasoning: false,
        paused: false,
      );
      messages.ua(msg);
      // if (Config.enableConversation) P.conversation.updateMessages([...messages.q, msg]);
    } else {
      msg = null;
    }

    Future.delayed(34.ms).then((_) {
      scrollToBottom();
    });

    if (type == MessageType.userImage) {
      // 在之前的操作中已经注入了 LLM 了
      return;
    }

    // if (Config.enableConversation) {
    //   try {
    //     P.conversation.addMessage(msg);
    //   } catch (e) {
    //     qqe(e);
    //   }
    // }

    final historyMessage = messages.q
        .where((e) {
          return e.type != MessageType.userImage;
        })
        .m((e) {
          if (!e.isReasoning) return e.content;
          if (!e.isCotFormat) return e.content;
          if (!e.containsCotEndMark) return e.content;
          final (cotContent, cotResult) = e.cotContentAndResult;
          return cotResult;
        });

    final history = withHistory ? historyMessage : [message];

    P.rwkv.sendMessages(history);
    editingIndex.q = null;

    receivedTokens.uc();
    receivingTokens.q = true;

    this.receiveId.q = receiveId;
    final receiveMsg = Message(
      id: receiveId,
      content: "",
      isMine: false,
      changing: true,
      isReasoning: P.rwkv.usingReasoningModel.q,
      paused: false,
    );

    messages.ua(receiveMsg);
    P.conversation.updateMessages([...messages.q, receiveMsg]);

    _checkSensitive(message);
  }

  FV onStopButtonPressed() async {
    qqq("receiveId: ${receiveId.q}");
    Gaimon.light();
    await Future.delayed(1.ms);
    final id = receiveId.q;
    if (id == null) {
      qqw("message id is null");
      return;
    }
    _pauseMessageById(id: id);
  }

  FV loadConversation(Conversation? conversation) async {
    if (conversation == null) {
      messages.uc();
      return;
    }
    messages.q = conversation.messages;
  }

  FV resumeMessageById({required int id, bool withHaptic = true}) async {
    qq;
    if (withHaptic) Gaimon.light();
    P.rwkv.sendMessages(_history());
    _updateMessageById(
      id: id,
      changing: true,
      paused: false,
      callingFunction: "resumeMessageById",
    );
  }

  void onTapSwitchAtIndex(int index, {required bool isBack, required Message msg}) {
    qq;
    final branches = P.chat.branchesCountList.q[index];
    if (branches.length <= 1) {
      qqw("No branches to switch");
      return;
    }
    final isFirstMessageSwitching = index == 0;
    final currentChain = this.currentChain.q;
    final previousMessageId = isFirstMessageSwitching ? null : currentChain.ids[index - 1];
    final history = chainSwitchingHistory.q.reversed;

    MessageChain? targetChain;

    if (previousMessageId == null) {
      targetChain = history.firstWhereOrNull((e) => e != currentChain);
      if (targetChain == null) {
        qqw("When switching the first message, no target chain found in history");
        return;
      }
      this.currentChain.q = targetChain;
      chainSwitchingHistory.ua(targetChain);
      return;
    }

    targetChain = history.firstWhereOrNull((e) => e.ids[index - 1] == previousMessageId && e != currentChain);
    if (targetChain != null) {
      qqr("Found target chain in history");
      this.currentChain.q = targetChain;
      chainSwitchingHistory.ua(targetChain);
      return;
    } else {
      qqw("No target chain found in history");
    }

    // 如果找不到, 则从 chains 中找
    targetChain = chains.q.firstWhereOrNull((e) => e.ids[index - 1] == previousMessageId && e != currentChain);
    if (targetChain != null) {
      qqr("Found target chain in chains");
      this.currentChain.q = targetChain;
      chainSwitchingHistory.ua(targetChain);
      return;
    } else {
      qqw("No target chain found in chains");
    }

    qqe("No target chain found");
    if (!kDebugMode) Sentry.captureException(Exception("No target chain found"), stackTrace: StackTrace.current);
  }
}

/// Private methods
extension _$Chat on _Chat {
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

    textEditingController.addListener(_onTextEditingControllerValueChanged);
    textInInput.l(_onTextChanged);

    P.app.pageKey.l(_onPageKeyChanged);

    P.rwkv.oldBroadcastStream.listen(
      _onStreamEvent,
      onDone: _onStreamDone,
      onError: _onStreamError,
    );

    P.world.audioFileStreamController.stream.listen(_onNewFileReceived);
    focusNode.addListener(_onFocusNodeChanged);
    hasFocus.q = focusNode.hasFocus;
    P.suggestion.loadSuggestions();

    receivingTokens.l(_onReceivingTokensChanged);

    P.app.lifecycleState.lb(_onLifecycleStateChanged);

    messages.lb(_onMessagesChanged);
    if (Config.enableChain) chains.lv(_syncBranchesCountList);
    if (Config.enableChain) currentChain.lv(_syncBranchesCountList);

    P.preference.preferredLanguage.lv(P.suggestion.loadSuggestions);
  }

  FV _checkSensitive(String content) async {
    final isSensitive = await P.guard.isSensitive(content);
    if (!isSensitive) return;

    final id = receiveId.q;
    if (id == null) {
      qqe("receiveId is null");
      return;
    }

    await Future.delayed(1.ms);

    _pauseMessageById(id: id, isSensitive: true);
  }

  void _onMessagesChanged(List<Message>? previous, List<Message> next) {
    if (Config.enableChain) _syncChains(previous, next);
  }

  void _syncBranchesCountList() {
    final chains = this.chains.q;
    final currentChain = this.currentChain.q;
    final List<List<int>> newValue = [];
    final currentMessageIds = currentChain.ids;
    for (var i = 0; i < currentMessageIds.length; i++) {
      if (i == 0) {
        final firstBranchIds = chains.m((e) => e.ids.first).toSet().sorted((a, b) => a.compareTo(b));
        newValue.add(firstBranchIds);
        continue;
      }
      // 获取上一个消息的 id
      final previousMessageId = currentMessageIds[i - 1];
      // 遍历所有消息链, 获取所有上一个消息的 id 等于 previousMessageId 的消息链
      final branchIds = chains
          .where((e) => e.ids[i - 1] == previousMessageId)
          .map((e) => e.ids[i])
          .sorted((a, b) => a.compareTo(b))
          .toList();
      newValue.add(branchIds);
    }
    if (listEquals(branchesCountList.q, newValue)) return;
    branchesCountList.q = newValue;
  }

  void _syncChains(List<Message>? previous, List<Message> next) {
    qq;
    if (previous == null) {
      qqe("previous is null");
      if (!kDebugMode) Sentry.captureException(Exception("previous is null"), stackTrace: StackTrace.current);
      return;
    }

    final previousIds = previous.map((e) => e.id).toList();
    final nextIds = next.map((e) => e.id).toList();
    final previousLength = previous.length;
    final nextLength = next.length;

    if (listEquals(previousIds, nextIds)) return;

    // Add a new chain
    if (previousLength == 0 && nextLength == 1) {
      final firstId = nextIds.first;
      final chain = MessageChain(ids: [firstId]);
      this.chains.q = {chain};
      this.currentChain.q = chain;
      return;
    }

    // 是否应该消息分叉?
    final shouldCreateNewBranch = nextLength <= previousLength;

    final chains = this.chains.q;
    final currentChain = this.currentChain.q;

    if (!chains.contains(currentChain)) {
      qqe("currentChain not found in chains");
      if (!kDebugMode) Sentry.captureException(Exception("currentChain not found in chains"), stackTrace: StackTrace.current);
      return;
    }

    late final MessageChain newChain;

    if (nextIds.isEmpty) {
      qqe("nextIds is empty");
      qqe("next: $next");
      if (!kDebugMode) Sentry.captureException(Exception("nextIds is empty"), stackTrace: StackTrace.current);
      debugger();
      return;
    }

    final latestId = nextIds.last;

    if (shouldCreateNewBranch) {
      newChain = currentChain.addAt(latestId, nextLength - 1);
    } else {
      newChain = currentChain.add(latestId);
    }

    if (!shouldCreateNewBranch) chains.remove(currentChain);
    chains.add(newChain);

    if (!setEquals(this.chains.q, chains)) this.chains.q = chains;
    this.currentChain.q = newChain;

    qqq("chains count: ${this.chains.q.length}, currentChain length: ${this.currentChain.q.ids.length}");
  }

  void _onLifecycleStateChanged(AppLifecycleState? previous, AppLifecycleState next) {
    final isToBackground = next == AppLifecycleState.paused || next == AppLifecycleState.hidden;
    if (isToBackground) {
      if (receiveId.q != null && autoPauseId.q == null && receivingTokens.q == true) {
        autoPauseId.q = receiveId.q!;
        _pauseMessageById(id: receiveId.q!);
      }
    } else {
      if (autoPauseId.q != null) {
        resumeMessageById(id: autoPauseId.q!, withHaptic: false);
        autoPauseId.uc();
      }
    }
    qqq("autoPauseId: ${autoPauseId.q}, receiveId: ${receiveId.q}, state: $next");
  }

  List<String> _history() {
    final history = messages.q.where((msg) => msg.type == MessageType.text).m((e) {
      if (!e.isReasoning) return e.content;
      if (!e.isCotFormat) return e.content;
      if (!e.containsCotEndMark) return e.content;
      if (e.paused) return e.content;
      final (cotContent, cotResult) = e.cotContentAndResult;
      return cotResult;
    });
    return history;
  }

  void _onReceivingTokensChanged(bool next) async {}

  FV _pauseMessageById({required int id, bool isSensitive = false}) async {
    qq;

    P.rwkv.stop();

    final msg = messages.q.firstWhereOrNull((e) => e.id == id);
    if (msg == null) {
      qqw("message not found");
      return;
    }

    if (msg.paused) {
      qqw("message already paused");
      return;
    }

    final newMessages = messages.q.map((e) {
      if (e.id == id) {
        return e.copyWith(paused: true, isSensitive: isSensitive);
      }
      return e;
    }).toList();
    messages.q = newMessages;
  }

  FV _onFocusNodeChanged() async {
    hasFocus.q = focusNode.hasFocus;
  }

  FV _onNewFileReceived((File, int) event) async {
    final demoType = P.app.demoType.q;
    if (demoType == DemoType.world) {
      final (file, length) = event;
      final path = file.path;

      qqq("new file received: $path, length: $length");

      final t0 = HF.debugShorterUS;
      P.rwkv.setAudioPrompt(path: path);
      final t1 = HF.debugShorterUS;
      qqq("setAudioPrompt done in ${t1 - t0}ms");
      send("", type: MessageType.userAudio, audioUrl: path, withHistory: false, audioLength: length);
      final t2 = HF.debugShorterUS;
      qqq("send done in ${t2 - t1}ms");
    }

    if (demoType == DemoType.tts) {
      final (file, length) = event;
      final path = file.path;
      qqq("new file received: $path, length: $length");
      P.tts.selectSourceAudioPath.q = path;
      P.tts.selectedSpkName.uc();
    }
  }

  void _onPageKeyChanged(PageKey pageKey) {
    qqq("_onPageKeyChanged: $pageKey");
    Future.delayed(200.ms).then((_) {
      messages.uc();
    });

    if (!P.rwkv.loaded.q) {
      P.fileManager.modelSelectorShown.q = true;
    }
  }

  void _onTextEditingControllerValueChanged() {
    // qqq("_onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (textInInput.q != textInController) textInInput.q = textInController;
  }

  void _onTextChanged(String next) {
    // qqq("_onTextChanged");
    final textInController = textEditingController.text;
    if (next != textInController) textEditingController.text = next;
  }

  void _fullyReceived({String? callingFunction}) {
    qqq("callingFunction: $callingFunction");

    final id = receiveId.q;

    if (id == null) {
      qqe("receiveId is null");
      return;
    }

    _updateMessageById(
      id: id,
      content: receivedTokens.q,
      changing: false,
      callingFunction: callingFunction,
    );
  }

  /// Update a message by id
  ///
  /// Should follow [Message] class
  void _updateMessageById({
    required int id,
    String? content,
    bool? isMine,
    bool? changing,
    MessageType? type,
    String? imageUrl,
    String? audioUrl,
    int? audioLength,
    bool? isReasoning,
    bool? paused,
    String? callingFunction,
    bool? isSensitive,
    double? ttsOverallProgress,
    List<double>? ttsPerWavProgress,
    List<String>? ttsFilePaths,
  }) {
    final currentMessages = [...messages.q];
    bool found = false;

    for (var i = 0; i < currentMessages.length; i++) {
      final msg = currentMessages[i];
      if (msg.id == id) {
        final newMsg = msg.copyWith(
          content: content ?? msg.content,
          isMine: isMine ?? msg.isMine,
          changing: changing ?? msg.changing,
          type: type ?? msg.type,
          imageUrl: imageUrl ?? msg.imageUrl,
          audioUrl: audioUrl ?? msg.audioUrl,
          audioLength: audioLength ?? msg.audioLength,
          isReasoning: isReasoning ?? msg.isReasoning,
          paused: paused ?? msg.paused,
          isSensitive: isSensitive ?? msg.isSensitive,
          ttsOverallProgress: ttsOverallProgress ?? msg.ttsOverallProgress,
          ttsPerWavProgress: ttsPerWavProgress ?? msg.ttsPerWavProgress,
          ttsFilePaths: ttsFilePaths ?? msg.ttsFilePaths,
        );
        currentMessages.replaceRange(i, i + 1, [newMsg]);
        found = true;
        break;
      }
    }

    if (!found) {
      qqe("message not found");
      if (!kDebugMode) {
        Sentry.captureException(Exception("message not found, callingFunction: $callingFunction"), stackTrace: StackTrace.current);
      }
    }
    messages.q = currentMessages;
    P.conversation.updateMessages(currentMessages);
  }

  FV _onStreamEvent(LLMEvent event) async {
    final demoType = P.app.demoType.q;
    // if (demoType != DemoType.chat && demoType != DemoType.world) return;
    switch (demoType) {
      case DemoType.chat:
      case DemoType.world:
      case DemoType.tts:
        break;
      default:
        return;
    }

    switch (event.type) {
      case _RWKVMessageType.isGenerating:
      case _RWKVMessageType.responseBufferContent:
        break;
      default:
        qqq("event: $event");
    }

    switch (event.type) {
      case _RWKVMessageType.responseBufferIds:
        break;

      case _RWKVMessageType.isGenerating:
        final isGenerating = event.content == "true";
        receivingTokens.q = isGenerating;
        if (!isGenerating) _fullyReceived(callingFunction: "_onStreamEvent:isGenerating");
        break;

      case _RWKVMessageType.responseBufferContent:
        receivedTokens.q = event.content;
        _sensitiveThrottler.call(() {
          _checkSensitive(event.content);
        });
        break;

      case _RWKVMessageType.response:
        receivedTokens.q = event.content;
        receivingTokens.q = false;
        _fullyReceived(callingFunction: "_onStreamEvent:response");
        break;

      case _RWKVMessageType.generateStart:
        receivedTokens.q = "";
        receivingTokens.q = true;
        break;

      case _RWKVMessageType.streamResponse:
        receivedTokens.q = event.content;
        receivingTokens.q = true;
        break;

      case _RWKVMessageType.currentPrompt:
        receivedTokens.q = event.content;
        break;

      case _RWKVMessageType.generateStop:
        receivedTokens.q = "";
        receivingTokens.q = false;
        break;
    }
  }

  FV _onStreamDone() async {
    qq;
    final demoType = P.app.demoType.q;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    receivingTokens.q = false;
  }

  FV _onStreamError(Object error, StackTrace stackTrace) async {
    qqe("error: $error");
    if (!kDebugMode) Sentry.captureException(error, stackTrace: stackTrace);
    final demoType = P.app.demoType.q;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    receivingTokens.q = false;
  }
}
