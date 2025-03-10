part of 'p.dart';

class _Chat {
  late final messages = _gs<List<Message>>([]);

  late final scrollController = ScrollController();

  late final textEditingController = TextEditingController();

  late final focusNode = FocusNode();

  late final text = _gs("");

  late final canSend = _gp((ref) {
    final _text = ref.watch(text);
    return _text.trim().isNotEmpty;
  });

  /// Disable sender
  late final receiving = _gs(false);

  late final received = _gs("");

  late final parsedStream = StreamController<String>();

  late final scrollOffset = _gs(0.0);

  late final inputHeight = _gs(77.0);

  late final useReverse = _gs(true);

  late final atBottom = _gp((ref) {
    final useReverse = ref.watch(this.useReverse);
    final scrollOffset = ref.watch(this.scrollOffset);
    if (useReverse) return scrollOffset <= 0;
    final maxScrollExtent = scrollController.position.maxScrollExtent;
    return scrollOffset >= maxScrollExtent;
  });

  late final receiveId = _gsn<int>();

  late final editingIndex = _gsn<int>();

  late final editingBotMessage = _gp<bool>((ref) {
    final editingIndex = ref.watch(this.editingIndex);
    if (editingIndex == null) return false;
    return messages.v[editingIndex].isMine == false;
  });

  late final loading = _gs(false);

  late final loaded = _gp((ref) {
    final currentModel = ref.watch(this.currentModel);
    return currentModel != null;
  });

  late final currentModel = _gsn<FileKey>();
  late final showingModelSelector = _gs(false);
  late final showingCharacterSelector = _gs(false);
  late final showingRoleSelector = _gs(false);
  late final roles = _gs<List<Role>>([]);

  late final cotDisplayState = StateProvider.family<CoTDisplayState, int>((ref, index) {
    return CoTDisplayState.showCotHeaderIfCotResultIsEmpty;
  });

  late final usingReasoningModel = _gs(false);
}

/// Public methods
extension $Chat on _Chat {
  FV onInputRightButtonPressed() async {
    focusNode.unfocus();
    final textToSend = text.v.trim();
    text.uc();

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
    final textToSend = text.v.trim();
    if (textToSend.isEmpty) return;
    text.uc();
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
    // TODO: @wangce
    final content = messages.v[index].content;
    textEditingController.value = TextEditingValue(text: content);
    focusNode.requestFocus();
    editingIndex.u(index);
  }

  FV onRegeneratePressed({required int index}) async {
    // final editingIndex = editingIndex.v;
    // if (editingIndex != null && editingIndex > index) return;
    // editingIndex.u(index - 1);
    // onSendPressed();
    editingIndex.u(index - 1);
    text.uc();
    focusNode.unfocus();
    await send(messages.v[index - 1].content);
  }

  FV scrollToBottom({Duration? duration, bool? animate = true}) async {
    final useReverse = P.chat.useReverse.v;

    if (useReverse) {
      await scrollTo(offset: 0, duration: duration, animate: animate);
      return;
    }

    await scrollTo(offset: scrollController.position.maxScrollExtent, duration: duration, animate: animate);
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

  FV send(String message) async {
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
    );
    messages.ua(msg);
    Future.delayed(34.ms).then((_) {
      scrollToBottom();
    });

    P.rwkv.send(messages.v.m((e) => e.content));
    editingIndex.u(null);

    received.uc();
    receiving.u(true);

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
}

/// Private methods
extension _$Chat on _Chat {
  FV _init() async {
    if (kDebugMode) print("💬 $runtimeType._init");

    textEditingController.addListener(_onTextEditingControllerValueChanged);
    text.l(_onTextChanged);

    scrollController.addListener(() {
      scrollOffset.u(scrollController.offset);
    });

    P.app.pageKey.l(_onPageKeyChanged);

    P.rwkv.broadcastStream.listen((event) {
      final demoType = P.rwkv.demoType.v;
      if (demoType != DemoType.chat) return;
      _onStreamEvent(event: event);
    }, onDone: () {
      final demoType = P.rwkv.demoType.v;
      if (demoType != DemoType.chat) return;
      _onStreamDone();
    }, onError: (error, stackTrace) {
      final demoType = P.rwkv.demoType.v;
      if (demoType != DemoType.chat) return;
      _onStreamError(error: error, stackTrace: stackTrace);
    });

    _loadRoles();
  }

  FV _loadRoles() async {
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

    if (!loaded.v) {
      showingModelSelector.u(true);
    }
  }

  void _onTextEditingControllerValueChanged() {
    // if (kDebugMode) print("💬 _onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (text.v != textInController) text.u(textInController);
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
          content: received.v,
          isMine: msg.isMine,
          changing: false,
        );
        // TODO: @wangce replace!
        currentMessages.replaceRange(i, i + 1, [newMsg]);
        found = true;
        break;
      }
    }
    assert(found, "😡 $runtimeType._fullyReceived: message not found");
    messages.u(currentMessages);
  }

  FV _onStreamEvent({required JSON event}) async {
    final type = RWKVMessageType.fromString(event["type"]);
    switch (type) {
      case RWKVMessageType.response:
        final content = event["content"];
        logTrace("content: $content");
        received.u(content);
        receiving.u(false);
        _fullyReceived();
        break;
      case RWKVMessageType.generateStart:
        receiving.u(true);
        received.u("");
        break;
      case RWKVMessageType.streamResponse:
        final content = event["content"];
        received.u(content);
        receiving.u(true);
        break;
      case RWKVMessageType.currentPrompt:
        final content = event["content"];
        received.u(content);
        break;
      case RWKVMessageType.samplerParams:
        final content = event["content"];
        received.u(content);
        break;
      case RWKVMessageType.generateStop:
        received.u("");
        break;
    }
  }

  FV _onStreamDone() async {
    if (kDebugMode) print("💬 _onStreamDone");
    receiving.u(false);
  }

  FV _onStreamError({
    required Object error,
    required StackTrace stackTrace,
  }) async {
    if (kDebugMode) print("💬 _onStreamError");
    if (kDebugMode) print("😡 error: $error");
    receiving.u(false);
  }
}

enum CoTDisplayState {
  showCotHeaderIfCotResultIsEmpty,
  hideCotHeader,
  showCotHeaderAndCotContent,
}
