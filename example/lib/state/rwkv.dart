part of 'p.dart';

enum RWKVMessageType {
  currentPrompt,
  samplerParams,
  response,
  generateStart,
  streamResponse;

  static RWKVMessageType fromString(String str) {
    return values.firstWhere((e) => e.name == str);
  }
}

class _RWKV {
  SendPort? sendPort;

  late final messagesController = StreamController<JSON>();

  late final String firstMessage = "Hello!";

  late final ready = _gs(false);
  late final generating = _gs(false);
}

/// Public methods
extension $RWKV on _RWKV {
  void send(String message) {
    final existingMessages = P.chat.messages.v.m((e) => e.content);
    final newMessages = [...existingMessages];
    if (kDebugMode) print("💬 $runtimeType.send: ${newMessages.length} messages");
    sendPort!.send(("message", newMessages));
  }

  void sendAt(String message, int index) {
    // TODO: @wangce
    final existingMessages = P.chat.messages.v.m((e) => e.content);
    final newMessages = [...existingMessages];
    if (kDebugMode) print("💬 $runtimeType.sendAt: ${newMessages.length} messages");
    sendPort!.send(("message", newMessages));
  }

  void regenerateAt(int index) {
    // TODO: @wangce
    final existingMessages = P.chat.messages.v.m((e) => e.content);
    final newMessages = existingMessages.sublist(0, index);
    if (kDebugMode) print("💬 $runtimeType.regenerateAt: ${newMessages.length} messages");
    sendPort!.send(("message", newMessages));
  }

  void modifyAt(int index, String message) {
    // TODO: @wangce
    final existingMessages = P.chat.messages.v.m((e) => e.content);
    final newMessages = [...existingMessages];
    if (kDebugMode) print("💬 $runtimeType.modifyAt: ${newMessages.length} messages");
    sendPort!.send(("message", newMessages));
  }
}

/// Private methods
extension _$RWKV on _RWKV {
  FV _init() async {
    if (kDebugMode) print("✅ initRWKV start");
    ready.u(false);
    await _initRWKV();
    ready.u(true);
    if (kDebugMode) print("✅ initRWKV end");
  }

  Future<void> _initRWKV() async {
    late final String modelPath;
    late final String tokenizerPath;
    late final String backendName;

    if (Platform.isIOS || Platform.isMacOS) {
      modelPath = await getModelPath("assets/model/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096.st");
      tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");
      backendName = "web-rwkv";
    } else {
      modelPath = await getModelPath("assets/model/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin");
      await getModelPath("assets/model/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.param");
      tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");
      backendName = "ncnn";
    }

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();
    final availableBackendNames = rwkvMobile.getAvailableBackendNames();
    if (kDebugMode) print("💬 availableBackendNames: $availableBackendNames");
    final receivePort = ReceivePort();

    rwkvMobile.runIsolate(
      modelPath,
      tokenizerPath,
      backendName,
      receivePort.sendPort,
      rootIsolateToken!,
    );

    receivePort.listen(_onMessage);

    while (sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // TODO: Decide a better prompt to use
    sendPort!.send(("setPrompt", "User: hi\n\nAssistant: Hi. I am your assistant and I will provide expert full response in full details. Please feel free to ask any question and I will always answer it.\n\n"));
    sendPort!.send(("getPrompt", null));
    sendPort!.send(("setSamplerParams", {"temperature": 2.0, "top_k": 128, "top_p": 0.5, "presence_penalty": 0.5, "frequency_penalty": 0.5, "penalty_decay": 0.996}));
    sendPort!.send(("getSamplerParams", null));
  }

  void _onMessage(message) {
    if (message is SendPort) {
      sendPort = message;
      return;
    }

    if (message["samplerParams"] != null) {
      if (kDebugMode) print("💬 Got samplerParams: ${message["samplerParams"]}");
      messagesController.add({
        "content": message["samplerParams"].toString(),
        "type": RWKVMessageType.samplerParams.name,
      });
      return;
    }

    if (message["currentPrompt"] != null) {
      if (kDebugMode) print("💬 Got currentPrompt: \"${message["currentPrompt"]}\"");
      messagesController.add({
        "content": message["currentPrompt"].toString(),
        "type": RWKVMessageType.currentPrompt.name,
      });
      return;
    }

    if (message["generateStart"] == true) {
      generating.u(true);
      messagesController.add({
        "content": "",
        "type": RWKVMessageType.generateStart.name,
      });
      return;
    }

    if (message["response"] != null) {
      final responseText = message["response"].toString();
      messagesController.add({
        "content": responseText,
        "type": RWKVMessageType.response.name,
      });
      generating.u(false);
      return;
    }

    if (message["streamResponse"] != null) {
      final responseText = message["streamResponse"].toString();
      messagesController.add({
        "content": responseText,
        "type": RWKVMessageType.streamResponse.name,
      });
      return;
    }
  }
}
