part of 'p.dart';

class _Chat {
  /// The key of it is the id of the message
  late final cotDisplayState = qsff<CoTDisplayState, int>((_, __) => CoTDisplayState.showCotHeaderAndCotContent);

  late final scrollController = ScrollController();

  late final textEditingController = TextEditingController();

  late final focusNode = FocusNode();

  late final _textInInput = qs("");

  late final canSend = qp((ref) {
    final textInInput = ref.watch(_textInInput);
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
    return messages.v[editingIndex].isMine == false;
  });

  late final showingCharacterSelector = qs(false);

  late final roles = qs<List<Role>>([]);

  late final latestClickedMessage = qsn<Message>();

  late final hasFocus = qs(false);

  late final suggestions = qs<List<String>>([]);

  late final autoPauseId = qsn<int>();

  late final messages = qp<List<Message>>((ref) {
    ref.watch(msgRefreshMark);

    final values = tree.values;
    return values
        .map((e) {
          return ref.watch(msgPool(e));
        })
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  });
  // late final messages = qs<List<Message>>([]);

  late final msgPool = qsff<Message?, int>((_, __) => null);
  var tree = TreeNode(0);
  late final msgRefreshMark = qs(0);
}

/// Public methods
extension $Chat on _Chat {
  void clearMessages() {
    tree = TreeNode(0);
  }

  FV onInputRightButtonPressed() async {
    if (P.rwkv.currentModel.v == null) {
      P.fileManager.modelSelectorShown.u(true);
      return;
    }

    if (!canSend.v) return;

    focusNode.unfocus();
    final textToSend = _textInInput.v.trim();
    _textInInput.uc();

    final _editingBotMessage = editingBotMessage.v;
    if (_editingBotMessage) {
      // final currentMessages = [...messages.v];
      final _editingIndex = editingIndex.v!;
      final id = qDebugShorterMilliseconds;
      final newBotMessage = Message(
        id: id,
        content: textToSend,
        isMine: false,
        changing: false,
        isReasoning: messages.v[_editingIndex].isReasoning,
        paused: messages.v[_editingIndex].paused,
      );
      // currentMessages.replaceRange(_editingIndex, _editingIndex + 1, [newBotMessage]);
      msgPool(_editingIndex).u(newBotMessage);
      editingIndex.u(null);
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
    final textToSend = _textInInput.v.trim();
    if (textToSend.isEmpty) return;
    _textInInput.uc();
    focusNode.unfocus();
    await send(textToSend);
  }

  FV onTapMessageList() async {
    P.chat.focusNode.unfocus();
    final _editingIndex = P.chat.editingIndex.v;
    if (_editingIndex == null) return;
    editingIndex.u(null);
    textEditingController.value = const TextEditingValue(text: "");
  }

  FV onTapEditInUserMessageBubble({required int index}) async {
    final loaded = P.rwkv.loaded.v;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.u(true);
      return;
    }
    final content = messages.v[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.u(index);
  }

  FV onTapEditInBotMessageBubble({required int index}) async {
    // TODO: 这里也要消息分叉
    final loaded = P.rwkv.loaded.v;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.u(true);
      return;
    }
    final content = messages.v[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.u(index);
  }

  FV onRegeneratePressed({required int index}) async {
    qqq("index: $index");
    final loaded = P.rwkv.loaded.v;
    if (!loaded) {
      Alert.info("Please load model first");
      P.fileManager.modelSelectorShown.u(true);
      return;
    }
    final userMessage = messages.v[index - 1];
    editingIndex.u(index);
    _textInInput.uc();
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
    await send(userMessage.content, regenerateIndex: index);
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
    qq;
    P.rwkv.clearStates();
  }

  FV send(
    String message, {
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
    int? audioLength,
    bool withHistory = true,
    int? regenerateIndex,
  }) async {
    qqq("message: $message");

    late final Message? msg;

    final id = qDebugShorterMilliseconds;
    if (regenerateIndex == null) {
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
      msgPool(id).u(msg);
      tree.addAtLast(id);
      msgRefreshMark.ua(1);
    } else {
      // TODO: 分叉
      msg = null;
    }

    Future.delayed(34.ms).then((_) {
      scrollToBottom();
    });

    if (type == MessageType.userImage) {
      return;
    }

    qqq("_tree.values: ${tree.values}");
    final messages = this.messages.v;
    // debugger();
    final historyMessage = messages.where((e) {
      return e.type != MessageType.userImage;
    }).m((e) {
      if (!e.isReasoning) return e.content;
      if (!e.isCotFormat) return e.content;
      if (!e.containsCotEndMark) return e.content;
      final (cotContent, cotResult) = e.cotContentAndResult;
      return cotResult;
    });

    final history = withHistory ? historyMessage : [message];
    // debugger();

    P.rwkv.send(history);
    editingIndex.u(null);

    receivedTokens.uc();
    receivingTokens.u(true);

    final receiveId = qDebugShorterMilliseconds;
    this.receiveId.u(receiveId);
    final receiveMsg = Message(
      id: receiveId,
      content: "",
      isMine: false,
      changing: true,
      isReasoning: P.rwkv.usingReasoningModel.v,
      paused: false,
    );

    msgPool(receiveId).u(receiveMsg);
    if (regenerateIndex == null) {
      tree.addAtLast(receiveId);
    } else {
      tree.addAt(receiveId, regenerateIndex);
    }
    msgRefreshMark.ua(1);
  }

  FV onStopButtonPressed() async {
    qqq("receiveId: ${receiveId.v}");
    Gaimon.light();
    await Future.delayed(1.ms);
    final id = receiveId.v;
    if (id == null) {
      qqw("message id is null");
      return;
    }
    _pauseMessageById(id: id);
  }

  FV loadSuggestions() async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat) return;
    final currentLocale = Intl.getCurrentLocale();
    bool useEn = currentLocale.startsWith("en");

    final assetPath = useEn ? "assets/config/chat/suggestions.en-US${kDebugMode ? ".debug" : ""}.json" : "assets/config/chat/suggestions.zh-hans${kDebugMode ? ".debug" : ""}.json";
    final anotherAssetPath = !useEn ? "assets/config/chat/suggestions.en-US${kDebugMode ? ".debug" : ""}.json" : "assets/config/chat/suggestions.zh-hans${kDebugMode ? ".debug" : ""}.json";

    final jsonString = await rootBundle.loadString(assetPath);
    final list = HF.list(jsonDecode(jsonString));
    final s = list.map((e) => e.toString()).shuffled().take(3).toList();
    suggestions.u(s);

    if (kDebugMode) {
      // Merge suggestions
      final anotherJsonString = await rootBundle.loadString(anotherAssetPath);
      final anotherList = HF.list(jsonDecode(anotherJsonString));
      final anotherSuggestions = anotherList.map((e) => e.toString()).toList();
      suggestions.ul(anotherSuggestions);
    }

    suggestions.u(suggestions.v.shuffled.take(3).toList());
  }

  FV loadConversation(Conversation? conversation) async {}

  FV resumeMessageById({required int id, bool withHaptic = true}) async {
    qq;
    if (withHaptic) Gaimon.light();
    P.rwkv.send(_history());
    _updateMessageById(id: id, changing: true, paused: false);
  }

  void onTapSwitchAtIndex(int index, {required bool isBack, required Message msg}) {
    // TODO: 分叉
  }
}

/// Private methods
extension _$Chat on _Chat {
  FV _init() async {
    qq;

    textEditingController.addListener(_onTextEditingControllerValueChanged);
    _textInInput.l(_onTextChanged);

    P.app.pageKey.l(_onPageKeyChanged);

    P.rwkv.broadcastStream.listen(
      _onStreamEvent,
      onDone: _onStreamDone,
      onError: _onStreamError,
    );

    _loadRoles();

    P.world.audioFileStreamController.stream.listen(_onNewFileReceived);
    focusNode.addListener(_onFocusNodeChanged);
    hasFocus.u(focusNode.hasFocus);
    loadSuggestions();

    receivingTokens.l(_onReceivingTokensChanged);

    P.app.lifecycleState.lb(_onLifecycleStateChanged);

    if (Config.enableChain) messages.lb(_onMessagesChanged);
  }

  void _onMessagesChanged(List<Message>? previous, List<Message> next) {}

  void _onLifecycleStateChanged(AppLifecycleState? previous, AppLifecycleState next) {
    final isToBackground = next == AppLifecycleState.paused || next == AppLifecycleState.hidden;
    if (isToBackground) {
      if (receiveId.v != null && autoPauseId.v == null && receivingTokens.v == true) {
        autoPauseId.u(receiveId.v!);
        _pauseMessageById(id: receiveId.v!);
      }
    } else {
      if (autoPauseId.v != null) {
        resumeMessageById(id: autoPauseId.v!, withHaptic: false);
        autoPauseId.uc();
      }
    }
    qqq("autoPauseId: ${autoPauseId.v}, receiveId: ${receiveId.v}, state: $next");
  }

  List<String> _history() {
    final history = messages.v.where((msg) => msg.type == MessageType.text).m((e) {
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

  FV _pauseMessageById({required int id}) async {
    qq;

    P.rwkv.stop();

    final msg = messages.v.firstWhereOrNull((e) => e.id == id);
    if (msg == null) {
      qqw("message not found");
      return;
    }

    if (msg.paused) {
      qqw("message already paused");
      return;
    }

    msgPool(id).u(msgPool(id).v?.copyWith(paused: true));
  }

  FV _onFocusNodeChanged() async {
    hasFocus.u(focusNode.hasFocus);
  }

  FV _onNewFileReceived((File, int) event) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.world) return;

    final (file, length) = event;
    final path = file.path;
    // final duration = Duration(milliseconds: length);
    // final durationString = Duration(milliseconds: length).toString();

    final t0 = qDebugShorterMicroseconds;
    P.rwkv.setAudioPrompt(path: path);
    final t1 = qDebugShorterMicroseconds;
    qqq("setAudioPrompt done in ${t1 - t0}ms");
    send("", type: MessageType.userAudio, audioUrl: path, withHistory: false, audioLength: length);
    final t2 = qDebugShorterMicroseconds;
    qqq("send done in ${t2 - t1}ms");
  }

  FV _loadRoles() async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat) return;
    final currentLocale = Intl.getCurrentLocale();
    final useEn = currentLocale.startsWith("en");
    final jsonString = await rootBundle.loadString(useEn ? Assets.config.chat.promptsEnUS : Assets.config.chat.promptsZhHans);
    final json = HF.listJSON(jsonDecode(jsonString));
    final roles = json.map((e) => Role.fromJson(e)).toList().shuffled;
    this.roles.u(roles);
  }

  void _onPageKeyChanged(PageKey pageKey) {
    qqq("_onPageKeyChanged: $pageKey");
    if (!P.rwkv.loaded.v) {
      P.fileManager.modelSelectorShown.u(true);
    }
  }

  void _onTextEditingControllerValueChanged() {
    // qqq("_onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (_textInInput.v != textInController) _textInInput.u(textInController);
  }

  void _onTextChanged(String next) {
    // qqq("_onTextChanged");
    final textInController = textEditingController.text;
    if (next != textInController) textEditingController.text = next;
  }

  void _fullyReceived() {
    qq;

    _updateMessageById(
      id: receiveId.v!,
      content: receivedTokens.v,
      changing: false,
    );
  }

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
  }) {
    qqq("id: $id, changing: $changing");

    // debugger();
    final currentMessages = [...messages.v];
    bool found = false;
    for (var i = 0; i < currentMessages.length; i++) {
      final msg = currentMessages[i];
      if (msg.id == id) {
        final newMsg = Message(
          id: msg.id,
          content: content ?? msg.content,
          isMine: isMine ?? msg.isMine,
          changing: changing ?? msg.changing,
          type: type ?? msg.type,
          imageUrl: imageUrl ?? msg.imageUrl,
          audioUrl: audioUrl ?? msg.audioUrl,
          audioLength: audioLength ?? msg.audioLength,
          isReasoning: isReasoning ?? msg.isReasoning,
          paused: paused ?? msg.paused,
        );
        currentMessages.replaceRange(i, i + 1, [newMsg]);
        found = true;
        msgPool(id).u(newMsg);
        break;
      }
    }
    if (!found) qqe("message not found");
  }

  FV _onStreamEvent(LLMEvent event) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;

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
        receivingTokens.u(isGenerating);
        if (!isGenerating) _fullyReceived();
        break;
      case _RWKVMessageType.responseBufferContent:
        receivedTokens.u(event.content);
        break;
      case _RWKVMessageType.response:
        receivedTokens.u(event.content);
        receivingTokens.u(false);
        _fullyReceived();
        break;
      case _RWKVMessageType.generateStart:
        receivedTokens.u("");
        receivingTokens.u(true);
        break;
      case _RWKVMessageType.streamResponse:
        receivedTokens.u(event.content);
        receivingTokens.u(true);
        break;
      case _RWKVMessageType.currentPrompt:
        receivedTokens.u(event.content);
        break;
      case _RWKVMessageType.samplerParams:
        receivedTokens.u(event.content);
        break;
      case _RWKVMessageType.generateStop:
        receivedTokens.u("");
        receivingTokens.u(false);
        break;
    }
  }

  FV _onStreamDone() async {
    qq;
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    receivingTokens.u(false);
  }

  FV _onStreamError(Object error, StackTrace stackTrace) async {
    qqe("error: $error");
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    receivingTokens.u(false);
  }
}
