part of 'p.dart';

class _Chat {
  late final messages = _gs<List<Message>>([]);

  /// The key of it is the id of the message
  late final cotDisplayState = StateProvider.family<CoTDisplayState, int>((ref, index) {
    return CoTDisplayState.showCotHeaderIfCotResultIsEmpty;
  });

  late final scrollController = ScrollController();

  late final textEditingController = TextEditingController();

  late final focusNode = FocusNode();

  late final _textInInput = _gs("");

  late final canSend = _gp((ref) {
    final textInInput = ref.watch(_textInInput);
    return textInInput.trim().isNotEmpty;
  });

  /// Disable sender
  ///
  /// TODO: Should be moved to state/rwkv.dart
  late final receivingTokens = _gs(false);

  /// TODO: Should be moved to state/rwkv.dart
  late final receivedTokens = _gs("");

  late final scrollOffset = _gs(0.0);

  late final inputHeight = _gs(77.0);

  late final atBottom = _gp((ref) {
    final scrollOffset = ref.watch(this.scrollOffset);
    return scrollOffset <= 0;
  });

  late final receiveId = _gsn<int>();

  late final editingIndex = _gsn<int>();

  late final editingBotMessage = _gp<bool>((ref) {
    final editingIndex = ref.watch(this.editingIndex);
    if (editingIndex == null) return false;
    return messages.v[editingIndex].isMine == false;
  });

  /// TODO: Should be moved to state/remote_file.dart
  late final showingModelSelector = _gs(false);

  late final showingCharacterSelector = _gs(false);

  late final roles = _gs<List<Role>>([]);

  late final latestClickedMessage = _gsn<Message>();

  late final hasFocus = _gs(false);
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
      final newBotMessage = Message(id: id, content: textToSend, isMine: false, changing: false);
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
    if (kDebugMode) print("💬 $runtimeType.onEditingComplete");
  }

  FV onSubmitted(String aString) async {
    if (kDebugMode) print("💬 $runtimeType.onSubmitted: $aString");
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
    // debugger();
    if (kDebugMode) print("💬 $runtimeType.send: $message");

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
    );
    messages.ua(msg);
    Future.delayed(34.ms).then((_) {
      scrollToBottom();
    });

    if (type == MessageType.userImage) return;

    final historyMessage = messages.v.where((e) => e.type != MessageType.userImage).m((e) => e.content);
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
    );

    messages.ua(receiveMsg);
  }

  FV onStopButtonPressed() async {
    logTrace();
    P.rwkv.stop();
  }
}

/// Private methods
extension _$Chat on _Chat {
  FV _init() async {
    if (kDebugMode) print("💬 $runtimeType._init");

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
  }

  FV _onFocusNodeChanged() async {
    hasFocus.u(focusNode.hasFocus);
  }

  FV _onNewFileReceived((File, int) event) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.world) return;

    final (file, length) = event;
    final path = file.path;
    final duration = Duration(milliseconds: length);
    final durationString = Duration(milliseconds: length).toString();

    final t0 = DateTime.now().millisecondsSinceEpoch;
    P.rwkv.setAudioPrompt(path: path);
    final t1 = DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) print("💬 setAudioPrompt done in ${t1 - t0}ms");
    send("", type: MessageType.userAudio, audioUrl: path, withHistory: false, audioLength: length);
    final t2 = DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) print("💬 send done in ${t2 - t1}ms");
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
    if (kDebugMode) print("💬 _onPageKeyChanged: $pageKey");
    Future.delayed(200.ms).then((_) {
      messages.u([]);
    });

    if (!P.rwkv.loaded.v) {
      showingModelSelector.u(true);
    }
  }

  void _onTextEditingControllerValueChanged() {
    // if (kDebugMode) print("💬 _onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (_textInInput.v != textInController) _textInInput.u(textInController);
  }

  void _onTextChanged(String next) {
    // if (kDebugMode) print("💬 _onTextChanged");
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
        );
        currentMessages.replaceRange(i, i + 1, [newMsg]);
        found = true;
        break;
      }
    }
    assert(found, "😡 $runtimeType._fullyReceived: message not found");
    messages.u(currentMessages);
  }

  FV _onStreamEvent(JSON event) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    final type = _RWKVMessageType.fromString(event["type"]);
    switch (type) {
      case _RWKVMessageType.response:
        final content = event["content"];
        logTrace("content: $content");
        receivedTokens.u(content);
        receivingTokens.u(false);
        _fullyReceived();
        break;
      case _RWKVMessageType.generateStart:
        receivedTokens.u("");
        receivingTokens.u(true);
        break;
      case _RWKVMessageType.streamResponse:
        final content = event["content"];
        receivedTokens.u(content);
        receivingTokens.u(true);
        break;
      case _RWKVMessageType.currentPrompt:
        final content = event["content"];
        receivedTokens.u(content);
        break;
      case _RWKVMessageType.samplerParams:
        final content = event["content"];
        receivedTokens.u(content);
        break;
      case _RWKVMessageType.generateStop:
        receivedTokens.u("");
        break;
    }
  }

  FV _onStreamDone() async {
    logTrace();
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    receivingTokens.u(false);
  }

  FV _onStreamError(Object error, StackTrace stackTrace) async {
    final demoType = P.app.demoType.v;
    if (demoType != DemoType.chat && demoType != DemoType.world) return;
    if (kDebugMode) print("💬 _onStreamError");
    if (kDebugMode) print("😡 error: $error");
    receivingTokens.u(false);
  }
}

enum CoTDisplayState {
  showCotHeaderIfCotResultIsEmpty,
  hideCotHeader,
  showCotHeaderAndCotContent,
}
