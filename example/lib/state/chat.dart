part of 'p.dart';

class _Chat {
  late final messages = qs<List<Message>>([]);

  /// The key of it is the id of the message
  late final cotDisplayState = qsff<CoTDisplayState, int>((ref, index) {
    return CoTDisplayState.showCotHeaderAndCotContent;
  });

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

  late final scrollOffset = qs(0.0);

  late final inputHeight = qs(77.0);

  late final atBottom = qp((ref) {
    final scrollOffset = ref.watch(this.scrollOffset);
    return scrollOffset <= 0;
  });

  late final receiveId = qsn<int>();

  late final editingIndex = qsn<int>();

  late final editingBotMessage = qp<bool>((ref) {
    final editingIndex = ref.watch(this.editingIndex);
    if (editingIndex == null) return false;
    return messages.v[editingIndex].isMine == false;
  });

  /// TODO: Should be moved to state/remote_file.dart
  late final showingModelSelector = qs(false);

  late final showingCharacterSelector = qs(false);

  late final roles = qs<List<Role>>([]);

  late final latestClickedMessage = qsn<Message>();

  late final hasFocus = qs(false);

  late final suggestions = qs<List<String>>([]);
}

/// Public methods
extension $Chat on _Chat {
  FV onInputRightButtonPressed() async {
    if (P.rwkv.currentModel.v == null) {
      showingModelSelector.u(true);
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
      final id = DateTime.now().microsecondsSinceEpoch;
      final newBotMessage = Message(
        id: id,
        content: textToSend,
        isMine: false,
        changing: false,
        isReasoning: messages.v[_editingIndex].isReasoning,
      );
      // currentMessages.replaceRange(_editingIndex, _editingIndex + 1, [newBotMessage]);
      final newMessages = [
        ...messages.v.sublist(0, _editingIndex),
        newBotMessage,
      ];
      messages.u(newMessages);
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
    final content = messages.v[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.u(index);
  }

  FV onTapEditInBotMessageBubble({required int index}) async {
    final content = messages.v[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.u(index);
  }

  FV onRegeneratePressed({required int index}) async {
    final userMessage = messages.v[index - 1];
    editingIndex.u(index - 1);
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
    await send(userMessage.content);
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
    P.rwkv.clearStates();
    messages.u([]);
  }

  FV send(
    String message, {
    MessageType type = MessageType.text,
    String? imageUrl,
    String? audioUrl,
    int? audioLength,
    bool withHistory = true,
  }) async {
    qqq(message);

    final _editingIndex = editingIndex.v;
    if (_editingIndex != null) {
      assert(_editingIndex >= 0 && _editingIndex < messages.v.length);
      final messagesWithoutEditing = messages.v.sublist(0, _editingIndex);
      // debugger();
      messages.u(messagesWithoutEditing);
    }

    final id = DateTime.now().microsecondsSinceEpoch;
    final msg = Message(
      id: id,
      content: message,
      isMine: true,
      type: type,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      audioLength: audioLength,
      isReasoning: false,
    );
    messages.ua(msg);
    Future.delayed(34.ms).then((_) {
      scrollToBottom();
    });

    if (type == MessageType.userImage) return;

    if (Config.enableConversation) {
      try {
        P.conversation.addMessage(msg);
      } catch (e) {
        qqe(e);
      }
    }

    final historyMessage = messages.v.where((e) {
      return e.type != MessageType.userImage;
    }).m((e) {
      if (!e.isReasoning) return e.content;
      if (!e.isCotFormat) return e.content;
      if (!e.containsCotEndMark) return e.content;
      final (cotContent, cotResult) = e.cotContentAndResult;
      return cotResult;
    });

    final history = withHistory ? historyMessage : [message];

    P.rwkv.send(history);
    editingIndex.u(null);

    receivedTokens.uc();
    receivingTokens.u(true);

    final receiveId = DateTime.now().microsecondsSinceEpoch;
    this.receiveId.u(receiveId);
    final receiveMsg = Message(
      id: receiveId,
      content: "",
      isMine: false,
      changing: true,
      isReasoning: P.rwkv.usingReasoningModel.v,
    );

    messages.ua(receiveMsg);
  }

  FV onStopButtonPressed() async {
    qq;
    Gaimon.light();
    await Future.delayed(50.ms);
    P.rwkv.stop();
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
}

/// Private methods
extension _$Chat on _Chat {
  FV _init() async {
    qq;

    textEditingController.addListener(_onTextEditingControllerValueChanged);
    _textInInput.l(_onTextChanged);

    scrollController.addListener(() {
      scrollOffset.u(scrollController.offset);
    });

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
  }

  void _onReceivingTokensChanged(bool next) async {}

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

    final t0 = DateTime.now().millisecondsSinceEpoch;
    P.rwkv.setAudioPrompt(path: path);
    final t1 = DateTime.now().millisecondsSinceEpoch;
    qqq("setAudioPrompt done in ${t1 - t0}ms");
    send("", type: MessageType.userAudio, audioUrl: path, withHistory: false, audioLength: length);
    final t2 = DateTime.now().millisecondsSinceEpoch;
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
    Future.delayed(200.ms).then((_) {
      messages.u([]);
    });

    if (!P.rwkv.loaded.v) {
      showingModelSelector.u(true);
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

  FV _fullyReceived() async {
    final currentMessages = [...messages.v];
    bool found = false;
    for (var i = 0; i < currentMessages.length; i++) {
      final msg = currentMessages[i];
      if (msg.id == receiveId.v) {
        final newMsg = Message(
          id: msg.id,
          content: receivedTokens.v,
          isMine: msg.isMine,
          changing: false,
          isReasoning: msg.isReasoning,
        );
        currentMessages.replaceRange(i, i + 1, [newMsg]);
        found = true;
        break;
      }
    }
    qqe("message not found");
    messages.u(currentMessages);
  }

  FV _onStreamEvent(LLMEvent event) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;

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
        receivingTokens.u(true);
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
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    qqq("_onStreamError");
    if (kDebugMode) print("😡 error: $error");
    receivingTokens.u(false);
  }
}

enum CoTDisplayState {
  showCotHeaderIfCotResultIsEmpty,
  hideCotHeader,
  showCotHeaderAndCotContent,
}
