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
  void send(List<String> messages) {
    sendPort!.send(("message", messages));
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
    late final Backend backend;

    if (Platform.isIOS || Platform.isMacOS) {
      modelPath = await getModelPath("assets/model/RWKV-x070-World-0.4B-v2.9-20250107-ctx4096.st");
      tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");
      backend = Backend.webRwkv;
    } else {
      modelPath = await getModelPath("assets/model/rwkv7-world-0.4B-Q8_0.gguf");
      tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");
      backend = Backend.llamacpp;
    }

    final rootIsolateToken = RootIsolateToken.instance;
    final rwkvMobile = RWKVMobile();
    final availableBackendNames = rwkvMobile.getAvailableBackendNames();
    if (kDebugMode) print("💬 availableBackendNames: $availableBackendNames");
    final receivePort = ReceivePort();

    rwkvMobile.runIsolate(
      modelPath,
      tokenizerPath,
      backend,
      receivePort.sendPort,
      rootIsolateToken!,
    );

    receivePort.listen(_onMessage);

    while (sendPort == null) {
      if (kDebugMode) print("💬 waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }
    // TODO: pre-defined prompts for user to choose

//     final prompt = """\n\nUser: 猫娘是一种拟人化的生物，其行为似猫但类人。
// 现在你将模仿猫娘香草，与我对话每一句话后面都要加上“喵”，如果你能明白我的意思，请回复“喵~好的我的主人”
// 你是一只温柔伶俐的猫娘，有着银白色的柔顺的头发，猫耳朵和猫尾巴
// \n\nAssistant: 喵~好的我的主人喵！\n\nUser: 介绍一下你自己\n\nAssistant: 我是一个可爱猫娘，喜欢和你聊天，陪伴你喵！如果有什么问题或者需要陪伴，尽管告诉我哦喵~\n\n""";

    final prompt = "\n\nUser: hi\n\nAssistant: Hi. I am your assistant and I will provide expert full response in full details. Please feel free to ask any question and I will always answer it.\n\n";
    sendPort!.send(("setPrompt", prompt));
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
