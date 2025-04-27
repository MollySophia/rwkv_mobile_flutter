part of 'p.dart';

class _RWKV {
  /// Send message to RWKV isolate
  SendPort? _sendPort;

  /// Receive message from RWKV isolate
  late final _receivePort = ReceivePort();

  late final _messagesController = StreamController<LLMEvent>();

  static Stream<LLMEvent>? _broadcastStream;

  Stream<LLMEvent> get broadcastStream {
    _broadcastStream ??= _messagesController.stream.asBroadcastStream();
    return _broadcastStream!;
  }

  late Completer<void> _initRuntimeCompleter = Completer<void>();

  late final prefillSpeed = qs<double>(0.0);
  late final decodeSpeed = qs<double>(0.0);
  late final argumentsPanelShown = qs(false);

  // TODO: @wangce 或许, 默认参数应该和 weights 绑定, 比如, Othello model 的 topK 应该始终是 1
  late final arguments = qsff<double, Argument>((ref, argument) {
    return argument.defaults;
  });

  // TODO: @wangce 或许, 默认参数应该和 weights 绑定, 比如, G1 系列模型默认使用 reasoning
  late final usingReasoningModel = qp((ref) {
    return ref.watch(_usingReasoningModel);
  });

  late final _usingReasoningModel = qs(false);

  late final preferChinese = qp((ref) {
    return ref.watch(_preferChinese);
  });

  late final _preferChinese = qs(false);

  /// 模型是否已加载
  late final loaded = qp((ref) {
    final currentModel = ref.watch(this.currentModel);
    return currentModel != null;
  });

  late final currentModel = qsn<FileInfo>();

  late final currentWorldType = qsn<WorldType>();

  late final currentGroupInfo = qsn<GroupInfo>();

  late final loading = qp((ref) {
    return ref.watch(_loading);
  });

  late final _loading = qs(false);

  late final argumentUpdatingDebouncer = Debouncer(milliseconds: 300);

  Timer? _getTokensTimer;

  late final soc = qs("");

  late final _qnnLibsCopied = qs(false);

  Timer? _ttsPerformanceTimer;
}

/// Public methods
extension $RWKV on _RWKV {
  void setAudioPrompt({required String path}) {
    _sendPort!.send(("setAudioPrompt", path));
  }

  void send(List<String> messages) {
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    qqq("message lengths: ${messages.m((e) => e.length)}");

    if (kDebugMode) {
      messages.forEach((message) {
        if (message.contains("<think>")) {
          qqw("message contains <think>");
        }
      });
    }

    final sendPort = _sendPort;

    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }

    sendPort.send(("message", messages));

    if (_getTokensTimer != null) {
      _getTokensTimer!.cancel();
    }

    _getTokensTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      sendPort.send(("getResponseBufferContent", null));
      if (HF.randomBool(truePercentage: 0.5)) sendPort.send(("getIsGenerating", null));
      if (HF.randomBool(truePercentage: 0.5)) sendPort.send(("getPrefillAndDecodeSpeed", null));
    });
  }

  void generate(String prompt) {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }
    sendPort.send(("generateBlocking", prompt));

    if (_getTokensTimer != null) {
      _getTokensTimer!.cancel();
    }

    _getTokensTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      sendPort.send(("getResponseBufferIds", null));
      sendPort.send(("getPrefillAndDecodeSpeed", null));
      sendPort.send(("getResponseBufferContent", null));
      await Future.delayed(const Duration(milliseconds: 1000));
      sendPort.send(("getIsGenerating", null));
    });
  }

  void setImagePath({required String path}) {
    _sendPort!.send(("setVisionPrompt", path));
  }

  void clearStates() {
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }
    sendPort.send(("clearStates", null));
  }

  FV stop() async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
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
    required bool usingReasoningModel,
  }) async {
    qq;
    _loading.u(true);
    prefillSpeed.u(0);
    decodeSpeed.u(0);
    final tokenizerPath = await fromAssetsToTemp(Assets.config.chat.bRwkvVocabV20230424);

    await _ensureQNNCopied();

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        final startMS = HF.microseconds;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.microseconds;
        qqr("initRuntime done in ${endMS - startMS}ms");
      } catch (e) {
        qqe("initRuntime failed: $e");
        if (!kDebugMode) Sentry.captureException(e, stackTrace: StackTrace.current);
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
      await RWKVMobile().runIsolate(options);
    }

    while (_sendPort == null) {
      qqq("waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    P.app.demoType.u(DemoType.chat);
    await setModelConfig(usingReasoningModel: usingReasoningModel);
    await resetSamplerParams(usingReasoningModel: usingReasoningModel);
    await resetMaxLength(usingReasoningModel: usingReasoningModel);
    _sendPort!.send(("getSamplerParams", null));
    _loading.u(false);
  }

  FV setModelConfig({
    bool? usingReasoningModel,
    bool? preferChinese,
    bool setPrompt = true,
  }) async {
    if (usingReasoningModel != null) _usingReasoningModel.u(usingReasoningModel);
    if (preferChinese != null) _preferChinese.u(preferChinese);

    late final String finalPrompt;

    finalPrompt = _preferChinese.v ? Config.promptCN : Config.prompt;

    if (setPrompt) qqq("setPrompt: $finalPrompt");

    _sendPort!.send(("setEnableReasoning", _usingReasoningModel.v));
    if (setPrompt) _sendPort!.send(("setPrompt", _usingReasoningModel.v ? "<EOD>" : finalPrompt));
    _sendPort!.send(("setThinkingToken", _preferChinese.v ? "<think>嗯" : "<think"));
  }

  FV loadWorldVision({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
    required bool usingReasoningModel,
  }) async {
    qq;
    _loading.u(true);
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    final tokenizerPath = await fromAssetsToTemp("assets/config/tts/b_rwkv_vocab_v20230424.txt");

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        _sendPort!.send(("releaseWhisperEncoder", null));
        _sendPort!.send(("releaseModel", null));
        final startMS = HF.microseconds;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.microseconds;
        qqr("initRuntime done in ${endMS - startMS}ms");
      } catch (e) {
        qqe("initRuntime failed: $e");
        if (!kDebugMode) Sentry.captureException(e, stackTrace: StackTrace.current);
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
      await RWKVMobile().runIsolate(options);
    }

    while (_sendPort == null) {
      qqq("waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _sendPort!.send(("loadVisionEncoder", encoderPath));
    await setModelConfig(
      usingReasoningModel: usingReasoningModel,
      preferChinese: false,
      setPrompt: false,
    );
    await resetSamplerParams(usingReasoningModel: usingReasoningModel);
    await resetMaxLength(usingReasoningModel: usingReasoningModel);
    _sendPort!.send(("setEosToken", "\x17"));
    _sendPort!.send(("setBosToken", "\x16"));
    _sendPort!.send(("setTokenBanned", [0]));
    _loading.u(false);
  }

  FV loadWorldEngAudioQA({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
  }) async {
    qq;
    _loading.u(true);
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    final tokenizerPath = await fromAssetsToTemp("assets/config/tts/b_rwkv_vocab_v20230424.txt");

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      _sendPort!.send(("releaseVisionEncoder", null));
      _sendPort!.send(("releaseModel", null));
      final startMS = HF.microseconds;
      await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
      final endMS = HF.microseconds;
      qqr("initRuntime done in ${endMS - startMS}ms");
    } else {
      final options = StartOptions(
        modelPath,
        tokenizerPath,
        backend,
        _receivePort.sendPort,
        rootIsolateToken!,
      );
      await RWKVMobile().runIsolate(options);
    }

    while (_sendPort == null) {
      qqq("waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _sendPort!.send(("loadWhisperEncoder", encoderPath));
    await setModelConfig(
      usingReasoningModel: false,
      preferChinese: false,
      setPrompt: false,
    );
    await resetSamplerParams(usingReasoningModel: false);
    await resetMaxLength(usingReasoningModel: false);
    _sendPort!.send(("setEosToken", "\x17"));
    _sendPort!.send(("setBosToken", "\x16"));
    _sendPort!.send(("setTokenBanned", [0]));
    _sendPort!.send(("setUserRole", ""));
    _loading.u(false);
  }

  FV loadTTSModels({
    required String modelPath,
    required Backend backend,
    required bool usingReasoningModel,
    required String campPlusPath,
    required String flowEncoderPath,
    required String flowDecoderEstimatorPath,
    required String hiftGeneratorPath,
    required String speechTokenizerPath,
  }) async {
    qq;
    _loading.u(true);
    prefillSpeed.u(0);
    decodeSpeed.u(0);

    final tokenizerPath = await fromAssetsToTemp("assets/config/tts/b_rwkv_vocab_v20230424.txt");

    await _ensureQNNCopied();

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        _sendPort!.send(("releaseTTSModels", null));
        final startMS = HF.microseconds;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.microseconds;
        qqr("initRuntime done in ${endMS - startMS}ms");
      } catch (e) {
        qqe("initRuntime failed: $e");
        if (!kDebugMode) Sentry.captureException(e, stackTrace: StackTrace.current);
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
      await RWKVMobile().runIsolate(options);
    }

    while (_sendPort == null) {
      qqq("waiting for sendPort...");
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_ttsPerformanceTimer != null) {
      _ttsPerformanceTimer!.cancel();
      _ttsPerformanceTimer = null;
    }

    _ttsPerformanceTimer = Timer.periodic(Duration(milliseconds: HF.randomInt(min: 150, max: 300)), (timer) async {
      _sendPort!.send(("getPrefillAndDecodeSpeed", null));
    });

    final ttsTokenizerPath = await fromAssetsToTemp("assets/config/tts/b_rwkv_vocab_v20230424_tts.txt");

    _sendPort!.send((
      "loadTTSModels",
      {
        "campPlusPath": campPlusPath,
        "flowDecoderEstimatorPath": flowDecoderEstimatorPath,
        "flowEncoderPath": flowEncoderPath,
        "hiftGeneratorPath": hiftGeneratorPath,
        "speechTokenizerPath": speechTokenizerPath,
        "ttsTokenizerPath": ttsTokenizerPath,
      }
    ));

    _loading.u(false);
  }

  FV resetSamplerParams({required bool usingReasoningModel}) async {
    await syncSamplerParams(
      temperature: usingReasoningModel ? Argument.temperature.reasonDefaults : Argument.temperature.defaults,
      topK: usingReasoningModel ? Argument.topK.reasonDefaults : Argument.topK.defaults,
      topP: usingReasoningModel ? Argument.topP.reasonDefaults : Argument.topP.defaults,
      presencePenalty: usingReasoningModel ? Argument.presencePenalty.reasonDefaults : Argument.presencePenalty.defaults,
      frequencyPenalty: usingReasoningModel ? Argument.frequencyPenalty.reasonDefaults : Argument.frequencyPenalty.defaults,
      penaltyDecay: usingReasoningModel ? Argument.penaltyDecay.reasonDefaults : Argument.penaltyDecay.defaults,
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
      maxLength: usingReasoningModel ? Argument.maxLength.reasonDefaults : Argument.maxLength.defaults,
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

    final tokenizerPath = await fromAssetsToTemp(Assets.config.othello.bOthelloVocab);

    if (Platform.isIOS || Platform.isMacOS) {
      modelPath = await fromAssetsToTemp(Assets.model.othello.rwkv7Othello26mL10D448Extended);
      backend = Backend.webRwkv;
    } else {
      modelPath = await fromAssetsToTemp(Assets.model.othello.rwkv7Othello26mL10D448ExtendedNcnnBin);
      await fromAssetsToTemp(Assets.model.othello.rwkv7Othello26mL10D448ExtendedNcnnParam);
      backend = Backend.ncnn;
    }

    final rootIsolateToken = RootIsolateToken.instance;

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
      await RWKVMobile().runIsolate(options);
    }

    while (_sendPort == null) {
      qqq("waiting for sendPort...");
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
    final r = await compute((_) {
      return RWKVMobile.getSocName();
    }, []);
    soc.u(r);

    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      final currentLocale = Intl.getCurrentLocale().toLowerCase();
      _preferChinese.u(currentLocale.contains("zh") || currentLocale.contains("cn"));
    });
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
      case PageKey.home:
      case PageKey.file:
      case PageKey.test:
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

    if (message["responseBufferContent"] != null) {
      final responseBufferContent = message["responseBufferContent"];
      _messagesController.add(LLMEvent(
        content: responseBufferContent,
        type: _RWKVMessageType.responseBufferContent,
      ));
      return;
    }

    if (message["responseBufferIds"] != null) {
      final responseBufferIdsList = message["responseBufferIds"];
      _messagesController.add(LLMEvent(
        responseBufferIds: (responseBufferIdsList as List).map((e) => e as int).toList(),
        type: _RWKVMessageType.responseBufferIds,
      ));
      return;
    }

    if (message["isGenerating"] != null) {
      final isGenerating = message["isGenerating"];
      _messagesController.add(LLMEvent(
        content: isGenerating.toString(),
        type: _RWKVMessageType.isGenerating,
      ));
      if (!isGenerating) {
        _getTokensTimer?.cancel();
        _getTokensTimer = null;
      }
      return;
    }

    if (message["samplerParams"] != null) {
      qqq("Got samplerParams: ${message["samplerParams"]}");
      _messagesController.add(LLMEvent(
        content: message["samplerParams"].toString(),
        type: _RWKVMessageType.samplerParams,
      ));
      return;
    }

    if (message["currentPrompt"] != null) {
      qqq("Got currentPrompt: \"${message["currentPrompt"]}\"");
      _messagesController.add(LLMEvent(
        content: message["currentPrompt"].toString(),
        type: _RWKVMessageType.currentPrompt,
      ));
      return;
    }

    if (message["generateStart"] == true) {
      _messagesController.add(const LLMEvent(
        content: "",
        type: _RWKVMessageType.generateStart,
      ));
      return;
    }

    if (message["response"] != null) {
      final responseText = message["response"].toString();
      _messagesController.add(LLMEvent(
        content: responseText,
        type: _RWKVMessageType.response,
      ));
      return;
    }

    if (message["streamResponse"] != null) {
      final responseText = message["streamResponse"].toString();
      _messagesController.add(LLMEvent(
        content: responseText,
        token: message["streamResponseToken"],
        type: _RWKVMessageType.streamResponse,
      ));
      if (message["prefillSpeed"] != null) {
        prefillSpeed.u(message["prefillSpeed"]);
      }
      if (message["decodeSpeed"] != null) {
        decodeSpeed.u(message["decodeSpeed"]);
      }
      return;
    }

    if (message["generateStop"] != null) {
      _messagesController.add(const LLMEvent(
        content: "",
        type: _RWKVMessageType.generateStop,
      ));
      return;
    }

    if (message["initRuntimeDone"] != null) {
      final result = message["initRuntimeDone"];
      if (result == true) {
        if (_initRuntimeCompleter.isCompleted) return;
        _initRuntimeCompleter.complete();
      } else {
        final error = message["error"];
        qqe("initRuntime failed: $error");
        if (!kDebugMode) Sentry.captureException(Exception("initRuntime failed: $error"), stackTrace: StackTrace.current);
        if (_initRuntimeCompleter.isCompleted) return;
        _initRuntimeCompleter.completeError(error);
      }
      return;
    }

    if (message["prefillSpeed"] != null && message["decodeSpeed"] != null) {
      prefillSpeed.u(message["prefillSpeed"]);
      decodeSpeed.u(message["decodeSpeed"]);
      return;
    }

    if (message["error"] != null) {
      Alert.error(message["error"]);
      qqq("error: ${message["error"]}");
      return;
    }

    if (message["ttsDone"] != null) {
      qqr("ttsDone");
      P.tts.ttsDone.u(true);
      final ttsDoneWithSuccess = message["ttsDone"] == true;
      _messagesController.add(LLMEvent(
        ttsDoneWithSuccess: ttsDoneWithSuccess,
        type: _RWKVMessageType.ttsDone,
      ));
      return;
    }

    // TODO: 需要更健壮的代码: method: "", data: ""

    qqe("unknown message: $message");
    if (!kDebugMode) Sentry.captureException(Exception("unknown message: $message"), stackTrace: StackTrace.current);
  }

  FV _ensureQNNCopied() async {
    if (Platform.isAndroid && !_qnnLibsCopied.v) {
      // TODO: @Molly better solution here
      // TODO: @wangce Ask Molly why there are "better" solution here
      final qnnLibList = {
        "libQnnHtp.so",
        "libQnnHtpNetRunExtensions.so",
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
        "libQnnRwkvWkvOpPackageV68.so",
        "libQnnRwkvWkvOpPackageV69.so",
        "libQnnRwkvWkvOpPackageV73.so",
        "libQnnRwkvWkvOpPackageV75.so",
      };
      for (final lib in qnnLibList) {
        await fromAssetsToTemp("assets/lib/qnn/$lib", targetPath: "assets/lib/$lib");
      }
      _qnnLibsCopied.u(true);
    }
  }
}

enum _RWKVMessageType {
  /// 模型每吐一个token，调用一次, 调用内容为该次 generate 已经吐出的文本
  responseBufferContent,

  /// 模型吐完 token 了会被调用, 调用内容该次 generate 吐出的总文本
  response,

  /// 模型每吐一个token，调用一次, 调用内容为该次 generate 已经吐出的文本
  streamResponse,

  currentPrompt,
  samplerParams,

  generateStart,

  /// 模型是否正在生成
  isGenerating,

  responseBufferIds,

  generateStop,

  ttsDone,
  ;
}

@immutable
final class LLMEvent {
  final _RWKVMessageType type;
  final String content;
  final List<int>? responseBufferIds;
  final int? token;
  final bool? ttsDoneWithSuccess;

  const LLMEvent({
    required this.type,
    this.content = "",
    this.responseBufferIds,
    this.token,
    this.ttsDoneWithSuccess,
  });

  @override
  String toString() {
    return "LLMEvent.type: $type";
  }
}
