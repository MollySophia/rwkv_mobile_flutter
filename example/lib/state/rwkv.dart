part of 'p.dart';

class _RWKV {
  SendPort? _sendPort;

  late final _receivePort = ReceivePort();

  late final _messagesController = StreamController<JSON>();

  static Stream<JSON>? _broadcastStream;

  Stream<JSON> get broadcastStream {
    _broadcastStream ??= _messagesController.stream.asBroadcastStream();
    return _broadcastStream!;
  }

  late Completer<void> _initRuntimeCompleter = Completer<void>();

  late final prefillSpeed = _gs<double>(0.0);
  late final decodeSpeed = _gs<double>(0.0);
  late final argumentsPanelShown = _gs(false);

  // TODO: @wangce 或许, 默认参数应该和 weights 绑定, 比如, Othello model 的 topK 应该始终是 1
  late final arguments = StateProvider.family<double, Argument>((ref, argument) {
    return argument.chatDefaults;
  });

  // TODO: @wangce 或许, 默认参数应该和 weights 绑定, 比如, G1 系列模型默认使用 reasoning
  late final usingReasoningModel = _gs(false);

  /// 模型是否已加载
  late final loaded = _gp((ref) {
    final currentModel = ref.watch(this.currentModel);
    return currentModel != null;
  });

  late final currentModel = _gsn<FileKey>();
  late final currentWorldType = _gsn<WorldType>();

  late final loading = _gs(false);

  late final argumentUpdatingDebouncer = Debouncer(milliseconds: 300);
}

/// Public methods
extension $RWKV on _RWKV {
  void setAudioPrompt({required String path}) {
    _sendPort!.send(("setAudioPrompt", path));
  }

  void send(List<String> messages) {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("🚧 sendPort is null");
      return;
    }
    sendPort.send(("message", messages));
  }

  void setImagePath({required String path}) {
    _sendPort!.send(("setVisionPrompt", path));
  }

  void clearStates() {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("🚧 sendPort is null");
      return;
    }
    sendPort.send(("clearStates", null));
  }

  void generate(String prompt) {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("🚧 sendPort is null");
      return;
    }
    sendPort.send(("generate", prompt));
  }

  FV stop() async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("🚧 sendPort is null");
      return;
    }
    sendPort.send(("stop", null));
  }

  FV initRuntime({
    required String modelPath,
    required Backend backend,
    required String tokenizerPath,
  }) {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    _initRuntimeCompleter = Completer<void>();
    _sendPort!.send((
      "initRuntime",
      {
        "modelPath": modelPath,
        "backend": backend,
        "tokenizerPath": tokenizerPath,
      },
    ));

    return _initRuntimeCompleter.future;
  }

  FV loadChat({
    required String modelPath,
    required Backend backend,
  }) async {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final tokenizerPath = await getModelPath(Assets.config.chat.bRwkvVocabV20230424);

    if (Platform.isAndroid) {
      // TODO: @Molly better solution here
      // TODO: @wangce Ask Molly why there are "better" solution here
      final qnnLibList = {
        "libQnnHtp.so",
        "libQnnHtpV68Stub.so",
        "libQnnHtpV69Stub.so",
        "libQnnHtpV73Stub.so",
        "libQnnHtpV75Stub.so",
        "libQnnHtpV79Stub.so",
        "libQnnHtpV68Skel.so",
        "libQnnHtpV69Skel.so",
        "libQnnHtpV73Skel.so",
        "libQnnHtpV75Skel.so",
        "libQnnHtpV79Skel.so",
        "libQnnHtpPrepare.so",
        "libQnnSystem.so",
        "libQnnRwkvWkvOpPackage.so",
      };
      for (final lib in qnnLibList) {
        final path = await getModelPath("assets/lib/$lib");
        if (kDebugMode) print("💬 copied QNN library, path: $path");
      }
    }

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();
    final availableBackendNames = rwkvMobile.getAvailableBackendNames();
    if (kDebugMode) print("💬 availableBackendNames: $availableBackendNames");

    if (_sendPort != null) {
      try {
        final startMS = DateTime.now().millisecondsSinceEpoch;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = DateTime.now().millisecondsSinceEpoch;
        if (kDebugMode) print("✅ initRuntime done in ${endMS - startMS}ms");
      } catch (e) {
        if (kDebugMode) print("😡 initRuntime failed: $e");
        Alert.error("Failed to load model: $e");
        return;
      }
    } else {
      final options = StartOptions(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
      await rwkvMobile.runIsolate(options);
    }

    while (_sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }
    // TODO: pre-defined prompts for user to choose

//     final prompt = """\n\nUser: 猫娘是一种拟人化的生物，其行为似猫但类人。
// 现在你将模仿猫娘香草，与我对话每一句话后面都要加上“喵”，如果你能明白我的意思，请回复“喵~好的我的主人”
// 你是一只温柔伶俐的猫娘，有着银白色的柔顺的头发，猫耳朵和猫尾巴
// \n\nAssistant: 喵~好的我的主人喵！\n\nUser: 介绍一下你自己\n\nAssistant: 我是一个可爱猫娘，喜欢和你聊天，陪伴你喵！如果有什么问题或者需要陪伴，尽管告诉我哦喵~\n\n""";

    final usingReasoningModel = P.rwkv.usingReasoningModel.v;
    P.app.demoType.u(DemoType.chat);

    const promptForNormalChat = """

User: hi

Assistant: Hi. I am your assistant and I will provide expert full response in full details. Please feel free to ask any question and I will always answer it.

""";

    const promptForReasoning = "";

    _sendPort!.send(("setPrompt", usingReasoningModel ? promptForReasoning : promptForNormalChat));
    _sendPort!.send(("setEnableReasoning", usingReasoningModel));
    _sendPort!.send(("getPrompt", null));
    await resetSamplerParams(usingReasoningModel: usingReasoningModel);
    await resetMaxLength(usingReasoningModel: usingReasoningModel);
    _sendPort!.send(("getSamplerParams", null));
  }

  FV loadWorldVision({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
  }) async {
    logTrace();
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    final tokenizerPath = await getModelPath("assets/config/world/b_rwkv_vocab_v20230424.txt");

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();

    if (_sendPort != null) {
      try {
        _sendPort!.send(("releaseWhisperEncoder", null));
        _sendPort!.send(("releaseModel", null));
        final startMS = DateTime.now().millisecondsSinceEpoch;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = DateTime.now().millisecondsSinceEpoch;
        if (kDebugMode) print("✅ initRuntime done in ${endMS - startMS}ms");
      } catch (e) {
        if (kDebugMode) print("😡 initRuntime failed: $e");
        Alert.error("Failed to load model: $e");
        return;
      }
    } else {
      final options = StartOptions(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
      await rwkvMobile.runIsolate(options);
    }

    while (_sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _sendPort!.send(("loadVisionEncoder", encoderPath));
    await resetSamplerParams(usingReasoningModel: false);
    await resetMaxLength(usingReasoningModel: false);
    _sendPort!.send(("setEosToken", "\x17"));
    _sendPort!.send(("setBosToken", "\x16"));
    _sendPort!.send(("setTokenBanned", [0]));
  }

  FV loadWorldEngAudioQA({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
  }) async {
    logTrace();
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    final tokenizerPath = await getModelPath("assets/config/world/b_rwkv_vocab_v20230424.txt");

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();

    if (_sendPort != null) {
      _sendPort!.send(("releaseVisionEncoder", null));
      _sendPort!.send(("releaseModel", null));
      final startMS = DateTime.now().millisecondsSinceEpoch;
      await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
      final endMS = DateTime.now().millisecondsSinceEpoch;
      if (kDebugMode) print("✅ initRuntime done in ${endMS - startMS}ms");
    } else {
      final options = StartOptions(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
      await rwkvMobile.runIsolate(options);
    }

    while (_sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _sendPort!.send(("loadWhisperEncoder", encoderPath));
    await resetSamplerParams(usingReasoningModel: false);
    await resetMaxLength(usingReasoningModel: false);
    _sendPort!.send(("setEosToken", "\x17"));
    _sendPort!.send(("setBosToken", "\x16"));
    _sendPort!.send(("setTokenBanned", [0]));
    _sendPort!.send(("setUserRole", ""));
  }

  FV resetSamplerParams({required bool usingReasoningModel}) async {
    await syncSamplerParams(
      temperature: usingReasoningModel ? Argument.temperature.reasonDefaults : Argument.temperature.chatDefaults,
      topK: usingReasoningModel ? Argument.topK.reasonDefaults : Argument.topK.chatDefaults,
      topP: usingReasoningModel ? Argument.topP.reasonDefaults : Argument.topP.chatDefaults,
      presencePenalty: usingReasoningModel ? Argument.presencePenalty.reasonDefaults : Argument.presencePenalty.chatDefaults,
      frequencyPenalty: usingReasoningModel ? Argument.frequencyPenalty.reasonDefaults : Argument.frequencyPenalty.chatDefaults,
      penaltyDecay: usingReasoningModel ? Argument.penaltyDecay.reasonDefaults : Argument.penaltyDecay.chatDefaults,
    );
  }

  FV syncSamplerParams({
    double? temperature,
    double? topK,
    double? topP,
    double? presencePenalty,
    double? frequencyPenalty,
    double? penaltyDecay,
  }) async {
    if (temperature != null) arguments(Argument.temperature).u(temperature);
    if (topK != null) arguments(Argument.topK).u(topK);
    if (topP != null) arguments(Argument.topP).u(topP);
    if (presencePenalty != null) arguments(Argument.presencePenalty).u(presencePenalty);
    if (frequencyPenalty != null) arguments(Argument.frequencyPenalty).u(frequencyPenalty);
    if (penaltyDecay != null) arguments(Argument.penaltyDecay).u(penaltyDecay);

    _sendPort!.send((
      "setSamplerParams",
      {
        "temperature": _intIfFixedDecimalsIsZero(Argument.temperature),
        "top_k": _intIfFixedDecimalsIsZero(Argument.topK),
        "top_p": _intIfFixedDecimalsIsZero(Argument.topP),
        "presence_penalty": _intIfFixedDecimalsIsZero(Argument.presencePenalty),
        "frequency_penalty": _intIfFixedDecimalsIsZero(Argument.frequencyPenalty),
        "penalty_decay": _intIfFixedDecimalsIsZero(Argument.penaltyDecay),
      },
    ));

    if (kDebugMode) _sendPort!.send(("getSamplerParams", null));
  }

  FV resetMaxLength({required bool usingReasoningModel}) async {
    await syncMaxLength(
      maxLength: usingReasoningModel ? Argument.maxLength.reasonDefaults : Argument.maxLength.chatDefaults,
    );
  }

  FV syncMaxLength({num? maxLength}) async {
    if (maxLength != null) arguments(Argument.maxLength).u(maxLength.toDouble());
    _sendPort!.send(("setMaxLength", _intIfFixedDecimalsIsZero(Argument.maxLength)));
  }

  FV loadOthello() async {
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    late final String modelPath;
    late final Backend backend;

    final tokenizerPath = await getModelPath(Assets.config.othello.bOthelloVocab);

    if (Platform.isIOS || Platform.isMacOS) {
      modelPath = await getModelPath(Assets.model.othello.rwkv7Othello26mL10D448Extended);
      backend = Backend.webRwkv;
    } else {
      modelPath = await getModelPath(Assets.model.othello.rwkv7Othello26mL10D448ExtendedNcnnBin);
      await getModelPath(Assets.model.othello.rwkv7Othello26mL10D448ExtendedNcnnParam);
      backend = Backend.ncnn;
    }

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();
    final availableBackendNames = rwkvMobile.getAvailableBackendNames();
    if (kDebugMode) print("💬 availableBackendNames: $availableBackendNames");

    if (_sendPort != null) {
      _sendPort!.send((
        "initRuntime",
        {"modelPath": modelPath, "backend": backend, "tokenizerPath": tokenizerPath},
      ));
    } else {
      final options = StartOptions(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
      await rwkvMobile.runIsolate(options);
    }

    while (_sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    P.app.demoType.u(DemoType.othello);

    _sendPort!.send(("setMaxLength", 64000));
    _sendPort!.send(("setSamplerParams", {"temperature": 1.0, "top_k": 1, "top_p": 1.0, "presence_penalty": 0.0, "frequency_penalty": 0.0, "penalty_decay": 0.0}));
    _sendPort!.send(("getSamplerParams", null));
    _sendPort!.send(("setGenerationStopToken", 0));
    _sendPort!.send(("clearStates", null));
  }
}

/// Private methods
extension _$RWKV on _RWKV {
  FV _init() async {
    P.app.pageKey.lv(_onPageKeyChanged);
    _receivePort.listen(_onMessage);
  }

  num _intIfFixedDecimalsIsZero(Argument argument) {
    if (argument.fixedDecimals == 0) {
      return arguments(argument).v.toInt();
    } else {
      return double.parse(arguments(argument).v.toStringAsFixed(argument.fixedDecimals));
    }
  }

  FV _onPageKeyChanged() async {
    final pageKey = P.app.pageKey.v;
    switch (pageKey) {
      case PageKey.othello:
        await loadOthello();
        break;
      case PageKey.chat:
        // await _loadChat();
        break;
      case PageKey.fifthteenPuzzle:
        await _loadFifthteenPuzzle();
        break;
      case PageKey.sudoku:
        await _loadSudoku();
        break;
      case PageKey.home:
      case PageKey.empty:
      case PageKey.file:
        break;
    }
  }

  // ignore: unused_element
  FV _loadFifthteenPuzzle() async {
    throw "Not support, please contact the developer";
  }

  // ignore: unused_element
  FV _loadSudoku() async {
    throw "Not support, please contact the developer";
  }

  void _onMessage(message) {
    if (message is SendPort) {
      _sendPort = message;
      return;
    }

    // if (kDebugMode) print(message);

    if (message["samplerParams"] != null) {
      if (kDebugMode) print("💬 Got samplerParams: ${message["samplerParams"]}");
      _messagesController.add({
        "content": message["samplerParams"].toString(),
        "type": _RWKVMessageType.samplerParams.name,
      });
      return;
    }

    if (message["currentPrompt"] != null) {
      if (kDebugMode) print("💬 Got currentPrompt: \"${message["currentPrompt"]}\"");
      _messagesController.add({
        "content": message["currentPrompt"].toString(),
        "type": _RWKVMessageType.currentPrompt.name,
      });
      return;
    }

    if (message["generateStart"] == true) {
      _messagesController.add({
        "content": "",
        "type": _RWKVMessageType.generateStart.name,
      });
      return;
    }

    if (message["response"] != null) {
      final responseText = message["response"].toString();
      _messagesController.add({
        "content": responseText,
        "type": _RWKVMessageType.response.name,
      });
      return;
    }

    if (message["streamResponse"] != null) {
      final responseText = message["streamResponse"].toString();
      _messagesController.add({
        "content": responseText,
        "token": message["streamResponseToken"],
        "type": _RWKVMessageType.streamResponse.name,
      });
      if (message["prefillSpeed"] != null) {
        prefillSpeed.u(message["prefillSpeed"]);
      }
      if (message["decodeSpeed"] != null) {
        decodeSpeed.u(message["decodeSpeed"]);
      }
      return;
    }

    if (message["generateStop"] != null) {
      _messagesController.add({
        "content": "",
        "type": _RWKVMessageType.generateStop.name,
      });
      return;
    }

    if (message["initRuntimeDone"] != null) {
      final result = message["initRuntimeDone"];
      if (result == true) {
        _initRuntimeCompleter.complete();
      } else {
        final error = message["error"];
        if (kDebugMode) print("😡 initRuntime failed: $error");
        _initRuntimeCompleter.completeError(error);
      }
      return;
    }

    if (message["prefillSpeed"] != null && message["decodeSpeed"] != null) {
      prefillSpeed.u(message["prefillSpeed"]);
      decodeSpeed.u(message["decodeSpeed"]);
      return;
    }

    // TODO: 需要更健壮的代码: method: "", data: ""

    if (kDebugMode) print("😡 unknown message: $message");
  }
}

enum _RWKVMessageType {
  /// 模型吐完 token 了会被调用, 调用内容该次 generate 吐出的总文本
  response,

  /// 模型每吐一个token，调用一次, 调用内容为该次 generate 已经吐出的文本
  streamResponse,

  currentPrompt,
  samplerParams,

  generateStart,

  generateStop;

  static _RWKVMessageType fromString(String str) {
    return values.firstWhere((e) => e.name == str);
  }
}

enum DemoType {
  othello,
  chat,
  world,
  fifthteenPuzzle,
  sudoku,
}
