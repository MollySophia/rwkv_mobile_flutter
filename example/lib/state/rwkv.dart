part of 'p.dart';

enum RWKVMessageType {
  currentPrompt,
  samplerParams,
  response,
  generateStart,
  streamResponse,
  generateStop;

  static RWKVMessageType fromString(String str) {
    return values.firstWhere((e) => e.name == str);
  }
}

enum DemoType {
  othello,
  chat,
  fifthteenPuzzle,
  sudoku,
}

enum ModelLoadingState {
  loading,
  ready,
  failed,
}

class _RWKV {
  SendPort? _sendPort;
  late final _receivePort = ReceivePort();

  late final _messagesController = StreamController<JSON>();

  /// 当前正在运行的任务
  late final demoType = _gsn<DemoType>();

  late final modelLoadingState = _gsn<ModelLoadingState>();

  late final generating = _gs(false);

  static Stream<JSON>? _broadcastStream;

  Stream<JSON> get broadcastStream {
    _broadcastStream ??= _messagesController.stream.asBroadcastStream();
    return _broadcastStream!;
  }

  late Completer<void> _initRuntimeCompleter = Completer<void>();
}

/// Public methods
extension $RWKV on _RWKV {
  void send(List<String> messages) {
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("😡 sendPort is null");
      return;
    }
    sendPort.send(("message", messages));
  }

  void clearStates() {
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("😡 sendPort is null");
      return;
    }
    sendPort.send(("clearStates", null));
  }

  void generate(String prompt) {
    final sendPort = _sendPort;
    if (sendPort == null) {
      if (kDebugMode) print("😡 sendPort is null");
      return;
    }
    sendPort.send(("generate", prompt));
  }

  FV initRuntime({
    required String modelPath,
    required Backend backend,
    required String tokenizerPath,
  }) {
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
    final tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");

    // TODO @Molly better solution here
    final qnnLibList = [
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
      "libQnnSystem.so",
      "libQnnRwkvWkvOpPackage.so",
    ];
    for (final lib in qnnLibList) {
      final path = await getModelPath("assets/model/$lib");
      if (kDebugMode) print("💬 path: $path");
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
      await rwkvMobile.runIsolate(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
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

    const prompt = """

User: hi

Assistant: Hi. I am your assistant and I will provide expert full response in full details. Please feel free to ask any question and I will always answer it.

""";

    demoType.u(DemoType.chat);

    _sendPort!.send(("setPrompt", prompt));
    _sendPort!.send(("getPrompt", null));
    _sendPort!.send(("setSamplerParams", {"temperature": 2.0, "top_k": 128, "top_p": 0.5, "presence_penalty": 0.5, "frequency_penalty": 0.5, "penalty_decay": 0.996}));
    _sendPort!.send(("getSamplerParams", null));
  }
}

/// Private methods
extension _$RWKV on _RWKV {
  FV _init() async {
    P.app.pageKey.lv(_onPageKeyChanged);
    _receivePort.listen(_onMessage);
  }

  FV _onPageKeyChanged() async {
    final pageKey = P.app.pageKey.v;
    switch (pageKey) {
      case PageKey.othello:
        await _loadOthello();
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

  FV _loadOthello() async {
    late final String modelPath;
    late final Backend backend;

    final tokenizerPath = await getModelPath("assets/model/b_othello_vocab.txt");

    if (Platform.isIOS || Platform.isMacOS) {
      modelPath = await getModelPath("assets/model/rwkv7_othello_26m_L10_D448_extended.st");
      backend = Backend.webRwkv;
    } else {
      modelPath = await getModelPath("assets/model/rwkv7_othello_26m_L10_D448_extended-ncnn.bin");
      await getModelPath("assets/model/rwkv7_othello_26m_L10_D448_extended-ncnn.param");
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
      await rwkvMobile.runIsolate(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
    }

    while (_sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    demoType.u(DemoType.othello);

    _sendPort!.send(("setMaxLength", 64000));
    _sendPort!.send(("setSamplerParams", {"temperature": 1.0, "top_k": 1, "top_p": 1.0, "presence_penalty": 0.0, "frequency_penalty": 0.0, "penalty_decay": 0.0}));
    _sendPort!.send(("getSamplerParams", null));
    _sendPort!.send(("setGenerationStopToken", 0));
    _sendPort!.send(("clearStates", null));
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
        "type": RWKVMessageType.samplerParams.name,
      });
      return;
    }

    if (message["currentPrompt"] != null) {
      if (kDebugMode) print("💬 Got currentPrompt: \"${message["currentPrompt"]}\"");
      _messagesController.add({
        "content": message["currentPrompt"].toString(),
        "type": RWKVMessageType.currentPrompt.name,
      });
      return;
    }

    if (message["generateStart"] == true) {
      generating.u(true);
      _messagesController.add({
        "content": "",
        "type": RWKVMessageType.generateStart.name,
      });
      return;
    }

    if (message["response"] != null) {
      final responseText = message["response"].toString();
      _messagesController.add({
        "content": responseText,
        "type": RWKVMessageType.response.name,
      });
      generating.u(false);
      return;
    }

    if (message["streamResponse"] != null) {
      final responseText = message["streamResponse"].toString();
      _messagesController.add({
        "content": responseText,
        "token": message["streamResponseToken"],
        "type": RWKVMessageType.streamResponse.name,
      });
      return;
    }

    if (message["generateStop"] != null) {
      _messagesController.add({
        "content": "",
        "type": RWKVMessageType.generateStop.name,
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

    if (kDebugMode) print("😡 unknown message: $message");
  }
}
