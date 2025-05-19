part of 'p.dart';

class _RWKV {
  /// Send message to RWKV isolate
  SendPort? _sendPort;

  /// Receive message from RWKV isolate
  late final _receivePort = ReceivePort();

  @Deprecated("Use _streamController instead")
  late final _oldMessagesController = StreamController<LLMEvent>();

  @Deprecated("Use _broadcastStream instead")
  static Stream<LLMEvent>? _oldBroadcastStream;

  @Deprecated("Use broadcastStream instead")
  Stream<LLMEvent> get oldBroadcastStream {
    _oldBroadcastStream ??= _oldMessagesController.stream.asBroadcastStream();
    return _oldBroadcastStream!;
  }

  late final _messagesController = StreamController<from_rwkv.FromRWKV>();

  static Stream<from_rwkv.FromRWKV>? _broadcastStream;

  Stream<from_rwkv.FromRWKV> get broadcastStream {
    _broadcastStream ??= _messagesController.stream.asBroadcastStream();
    return _broadcastStream!;
  }

  late Completer<void> _initRuntimeCompleter = Completer<void>();

  late final prefillSpeed = qs<double>(.0);
  late final decodeSpeed = qs<double>(.0);
  late final argumentsPanelShown = qs(false);

  // TODO: @wangce 或许, 默认参数应该和 weights 绑定, 比如, Othello model 的 topK 应该始终是 1
  late final arguments = qsff<Argument, double>((ref, argument) {
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

extension $RWKVLoad on _RWKV {
  FV loadWorldVision({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
    required bool usingReasoningModel,
  }) async {
    qq;
    _loading.q = true;
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

    final tokenizerPath = await fromAssetsToTemp("assets/config/chat/b_rwkv_vocab_v20230424.txt");

    await _ensureQNNCopied();

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        send(to_rwkv.ReleaseWhisperEncoder());
        send(to_rwkv.ReleaseModel());
        final startMS = HF.debugShorterUS;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.debugShorterUS;
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

    send(to_rwkv.LoadVisionEncoder(encoderPath));
    await setModelConfig(
      usingReasoningModel: usingReasoningModel,
      preferChinese: false,
      setPrompt: false,
    );
    await resetSamplerParams(usingReasoningModel: usingReasoningModel);
    await resetMaxLength(usingReasoningModel: usingReasoningModel);
    send(to_rwkv.SetEosToken("\x17"));
    send(to_rwkv.SetBosToken("\x16"));
    send(to_rwkv.SetTokenBanned([0]));
    _loading.q = false;
  }

  FV loadWorldEngAudioQA({
    required String modelPath,
    required String encoderPath,
    required Backend backend,
  }) async {
    qq;
    _loading.q = true;
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

    final tokenizerPath = await fromAssetsToTemp("assets/config/chat/b_rwkv_vocab_v20230424.txt");

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      send(to_rwkv.ReleaseVisionEncoder());
      send(to_rwkv.ReleaseModel());
      final startMS = HF.debugShorterUS;
      await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
      final endMS = HF.debugShorterUS;
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

    send(to_rwkv.LoadWhisperEncoder(encoderPath));
    await setModelConfig(
      usingReasoningModel: false,
      preferChinese: false,
      setPrompt: false,
    );
    await resetSamplerParams(usingReasoningModel: false);
    await resetMaxLength(usingReasoningModel: false);
    send(to_rwkv.SetEosToken("\x17"));
    send(to_rwkv.SetBosToken("\x16"));
    send(to_rwkv.SetTokenBanned([0]));
    send(to_rwkv.SetUserRole(""));
    _loading.q = false;
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
    _loading.q = true;
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

    final tokenizerPath = await fromAssetsToTemp("assets/config/chat/b_rwkv_vocab_v20230424.txt");

    await _ensureQNNCopied();

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        send(to_rwkv.ReleaseTTSModels());
        final startMS = HF.debugShorterUS;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.debugShorterUS;
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
      send(to_rwkv.GetPrefillAndDecodeSpeed());
    });

    final ttsTokenizerPath = await fromAssetsToTemp("assets/config/chat/b_rwkv_vocab_v20230424_tts.txt");

    send(to_rwkv.LoadTTSModels(
      campPlusPath: campPlusPath,
      flowDecoderEstimatorPath: flowDecoderEstimatorPath,
      flowEncoderPath: flowEncoderPath,
      hiftGeneratorPath: hiftGeneratorPath,
      speechTokenizerPath: speechTokenizerPath,
      ttsTokenizerPath: ttsTokenizerPath,
    ));

    final ttsTextNormalizerDatePath = await fromAssetsToTemp("assets/config/chat/date-zh.fst");
    final ttsTextNormalizerNumberPath = await fromAssetsToTemp("assets/config/chat/number-zh.fst");
    final ttsTextNormalizerPhonePath = await fromAssetsToTemp("assets/config/chat/phone-zh.fst");
    // note: order matters here
    send(to_rwkv.LoadTTSTextNormalizer(ttsTextNormalizerDatePath));
    send(to_rwkv.LoadTTSTextNormalizer(ttsTextNormalizerPhonePath));
    send(to_rwkv.LoadTTSTextNormalizer(ttsTextNormalizerNumberPath));

    _loading.q = false;
  }

  FV loadChat({
    required String modelPath,
    required Backend backend,
    required bool usingReasoningModel,
  }) async {
    qq;
    _loading.q = true;
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;
    final tokenizerPath = await fromAssetsToTemp(Assets.config.chat.bRwkvVocabV20230424);

    await _ensureQNNCopied();

    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      try {
        final startMS = HF.debugShorterUS;
        await initRuntime(backend: backend, modelPath: modelPath, tokenizerPath: tokenizerPath);
        final endMS = HF.debugShorterUS;
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

    P.app.demoType.q = DemoType.chat;
    await setModelConfig(usingReasoningModel: usingReasoningModel);
    await resetSamplerParams(usingReasoningModel: usingReasoningModel);
    await resetMaxLength(usingReasoningModel: usingReasoningModel);
    send(to_rwkv.GetSamplerParams());
    _loading.q = false;
  }

  FV loadOthello() async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

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
      send(to_rwkv.InitRuntime(
        modelPath: modelPath,
        backend: backend,
        tokenizerPath: tokenizerPath,
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

    P.app.demoType.q = DemoType.othello;

    send(to_rwkv.SetMaxLength(64000));
    send(to_rwkv.SetSamplerParams(
      temperature: 1.0,
      topK: 1,
      topP: 1.0,
      presencePenalty: .0,
      frequencyPenalty: .0,
      penaltyDecay: .0,
    ));
    send(to_rwkv.SetGenerationStopToken(0));
    send(to_rwkv.ClearStates());
  }

  FV loadSudoku({
    required String modelPath,
    required Backend backend,
  }) async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

    final tokenizerPath = await fromAssetsToTemp("assets/config/chat/b_sudoku_vocab.txt");
    final data = await rootBundle.load("assets/config/chat/sudoku_rwkv_20241120_ncnn.param");
    final paramFile = File(P.app.documentsDir.q!.path + "/sudoku_rwkv_20241120_ncnn.param");
    await paramFile.writeAsBytes(data.buffer.asUint8List());

    await _ensureQNNCopied();
    final rootIsolateToken = RootIsolateToken.instance;

    if (_sendPort != null) {
      send(to_rwkv.InitRuntime(
        modelPath: modelPath,
        backend: backend,
        tokenizerPath: tokenizerPath,
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

    P.app.demoType.q = DemoType.sudoku;

    send(to_rwkv.SetMaxLength(6000_000));
    send(to_rwkv.SetSamplerParams(
      temperature: 1.0,
      topK: 1,
      topP: 1.0,
      presencePenalty: .0,
      frequencyPenalty: .0,
      penaltyDecay: .0,
    ));
    send(to_rwkv.SetGenerationStopToken(_Sudoku.tokenStop));
    send(to_rwkv.ClearStates());
    _loading.q = false;
  }
}

/// Public methods
extension $RWKV on _RWKV {
  FV setAudioPrompt({required String path}) async {
    send(to_rwkv.SetAudioPrompt(path));
  }

  FV sendMessages(List<String> messages) async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;

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

    send(to_rwkv.ChatAsync(messages));

    if (_getTokensTimer != null) {
      _getTokensTimer!.cancel();
    }

    _getTokensTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      send(to_rwkv.GetResponseBufferContent());
      if (HF.randomBool(truePercentage: .5)) send(to_rwkv.GetIsGenerating());
      if (HF.randomBool(truePercentage: .5)) send(to_rwkv.GetPrefillAndDecodeSpeed());
    });
  }

  FV generate(String prompt) async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }
    send(to_rwkv.Generate(prompt));

    if (_getTokensTimer != null) {
      _getTokensTimer!.cancel();
    }

    _getTokensTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      send(to_rwkv.GetResponseBufferIds());
      send(to_rwkv.GetPrefillAndDecodeSpeed());
      send(to_rwkv.GetResponseBufferContent());
      await Future.delayed(const Duration(milliseconds: 1000));
      send(to_rwkv.GetIsGenerating());
    });
  }

  FV setImagePath({required String path}) async {
    send(to_rwkv.SetVisionPrompt(path));
  }

  FV clearStates() async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }
    send(to_rwkv.ClearStates());
  }

  void send(to_rwkv.ToRWKV toRwkv) {
    final sendPort = _sendPort;
    if (sendPort == null) {
      qqw("sendPort is null");
      return;
    }
    sendPort.send(toRwkv);
    return;
  }

  FV stop() async => send(to_rwkv.Stop());

  FV initRuntime({
    required String modelPath,
    required Backend backend,
    required String tokenizerPath,
  }) async {
    prefillSpeed.q = 0;
    decodeSpeed.q = 0;
    _initRuntimeCompleter = Completer<void>();
    send(to_rwkv.InitRuntime(
      modelPath: modelPath,
      backend: backend,
      tokenizerPath: tokenizerPath,
    ));
    return _initRuntimeCompleter.future;
  }

  FV setModelConfig({
    bool? usingReasoningModel,
    bool? preferChinese,
    bool setPrompt = true,
  }) async {
    if (usingReasoningModel != null) _usingReasoningModel.q = usingReasoningModel;
    if (preferChinese != null) _preferChinese.q = preferChinese;

    late final String finalPrompt;

    finalPrompt = _preferChinese.q ? Config.promptCN : Config.prompt;

    if (setPrompt) qqq("setPrompt: $finalPrompt");

    send(to_rwkv.SetEnableReasoning(_usingReasoningModel.q));
    if (setPrompt) send(to_rwkv.SetPrompt(_usingReasoningModel.q ? "<EOD>" : finalPrompt));
    send(to_rwkv.SetThinkingToken(_preferChinese.q ? "<think>嗯" : "<think"));
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
    if (temperature != null) arguments(Argument.temperature).q = temperature;
    if (topK != null) arguments(Argument.topK).q = topK;
    if (topP != null) arguments(Argument.topP).q = topP;
    if (presencePenalty != null) arguments(Argument.presencePenalty).q = presencePenalty;
    if (frequencyPenalty != null) arguments(Argument.frequencyPenalty).q = frequencyPenalty;
    if (penaltyDecay != null) arguments(Argument.penaltyDecay).q = penaltyDecay;

    send(to_rwkv.SetSamplerParams(
      temperature: _intIfFixedDecimalsIsZero(Argument.temperature),
      topK: _intIfFixedDecimalsIsZero(Argument.topK),
      topP: _intIfFixedDecimalsIsZero(Argument.topP),
      presencePenalty: _intIfFixedDecimalsIsZero(Argument.presencePenalty),
      frequencyPenalty: _intIfFixedDecimalsIsZero(Argument.frequencyPenalty),
      penaltyDecay: _intIfFixedDecimalsIsZero(Argument.penaltyDecay),
    ));

    if (kDebugMode) send(to_rwkv.GetSamplerParams());
  }

  FV resetMaxLength({required bool usingReasoningModel}) async {
    await syncMaxLength(
      maxLength: usingReasoningModel ? Argument.maxLength.reasonDefaults : Argument.maxLength.defaults,
    );
  }

  FV syncMaxLength({num? maxLength}) async {
    if (maxLength != null) arguments(Argument.maxLength).q = maxLength.toDouble();
    send(to_rwkv.SetMaxLength(_intIfFixedDecimalsIsZero(Argument.maxLength).toInt()));
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
    soc.q = r;

    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      final currentLocale = Intl.getCurrentLocale().toLowerCase();
      _preferChinese.q = currentLocale.contains("zh") || currentLocale.contains("cn");
    });
  }

  num _intIfFixedDecimalsIsZero(Argument argument) {
    if (argument.fixedDecimals == 0) {
      return arguments(argument).q.toInt();
    } else {
      return double.parse(arguments(argument).q.toStringAsFixed(argument.fixedDecimals));
    }
  }

  FV _onPageKeyChanged() async {
    final pageKey = P.app.pageKey.q;
    switch (pageKey) {
      case PageKey.othello:
        await loadOthello();
        break;
      case PageKey.chat:
      case PageKey.test:
      case PageKey.sudoku:
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

    if (message is from_rwkv.FromRWKV) {
      _handleFromRWKV(message);
      return;
    }

    if (message["responseBufferContent"] != null) {
      final responseBufferContent = message["responseBufferContent"];
      _oldMessagesController.add(LLMEvent(
        content: responseBufferContent,
        type: _RWKVMessageType.responseBufferContent,
      ));
      return;
    }

    if (message["responseBufferIds"] != null) {
      final responseBufferIdsList = message["responseBufferIds"];
      _oldMessagesController.add(LLMEvent(
        responseBufferIds: (responseBufferIdsList as List).map((e) => e as int).toList(),
        type: _RWKVMessageType.responseBufferIds,
      ));
      return;
    }

    if (message["isGenerating"] != null) {
      final isGenerating = message["isGenerating"];
      _oldMessagesController.add(LLMEvent(
        content: isGenerating.toString(),
        type: _RWKVMessageType.isGenerating,
      ));
      if (!isGenerating) {
        _getTokensTimer?.cancel();
        _getTokensTimer = null;
      }
      return;
    }

    if (message["currentPrompt"] != null) {
      qqq("Got currentPrompt: \"${message["currentPrompt"]}\"");
      _oldMessagesController.add(LLMEvent(
        content: message["currentPrompt"].toString(),
        type: _RWKVMessageType.currentPrompt,
      ));
      return;
    }

    if (message["generateStart"] == true) {
      _oldMessagesController.add(const LLMEvent(
        content: "",
        type: _RWKVMessageType.generateStart,
      ));
      return;
    }

    if (message["response"] != null) {
      final responseText = message["response"].toString();
      _oldMessagesController.add(LLMEvent(
        content: responseText,
        type: _RWKVMessageType.response,
      ));
      return;
    }

    if (message["streamResponse"] != null) {
      final responseText = message["streamResponse"].toString();
      _oldMessagesController.add(LLMEvent(
        content: responseText,
        token: message["streamResponseToken"],
        type: _RWKVMessageType.streamResponse,
      ));
      if (message["prefillSpeed"] != null && message["prefillSpeed"] != -1.0) {
        prefillSpeed.q = message["prefillSpeed"];
      }
      if (message["decodeSpeed"] != null && message["decodeSpeed"] != -1.0) {
        decodeSpeed.q = message["decodeSpeed"];
      }
      return;
    }

    if (message["generateStop"] != null) {
      _oldMessagesController.add(const LLMEvent(
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

    qqe("unknown message: $message");
    if (!kDebugMode) Sentry.captureException(Exception("unknown message: $message"), stackTrace: StackTrace.current);
  }

  void _handleFromRWKV(from_rwkv.FromRWKV message) {
    _messagesController.add(message);
    switch (message) {
      case from_rwkv.Error response:
        if (kDebugMode) {
          String errorLog = "error: ${response.message}";
          if (message.to != null) errorLog += " in ${message.to.runtimeType}";
          if (message.to?.requestId != null) errorLog += " requestId: ${message.to?.requestId}";
          qqe(errorLog);
        }
        Alert.error(response.message);

      case from_rwkv.Speed response:
        prefillSpeed.q = response.prefillSpeed;
        decodeSpeed.q = response.decodeSpeed;

      case from_rwkv.TTSResult response:
        qqq(response.filePaths);
        qqq(response.perWavProgress);
        qqq(response.overallProgress);
        break;

      case from_rwkv.StreamResponse response:
        final decodeSpeed = response.decodeSpeed;
        final prefillSpeed = response.prefillSpeed;
        if (decodeSpeed != -1.0) this.decodeSpeed.q = decodeSpeed;
        if (prefillSpeed != -1.0) this.prefillSpeed.q = prefillSpeed;
        break;

      default:
        break;
    }
  }

  FV _ensureQNNCopied() async {
    if (Platform.isAndroid && !_qnnLibsCopied.q) {
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
        "libQnnRwkvWkvOpPackageV79.so",
      };
      for (final lib in qnnLibList) {
        await fromAssetsToTemp("assets/lib/qnn/$lib", targetPath: "assets/lib/$lib");
      }
      _qnnLibsCopied.q = true;
    }
  }
}

@Deprecated("Use FromRWKV instead")
enum _RWKVMessageType {
  /// 模型每吐一个token，调用一次, 调用内容为该次 generate 已经吐出的文本
  @Deprecated("Use FromRWKV instead")
  responseBufferContent,

  /// 模型吐完 token 了会被调用, 调用内容该次 generate 吐出的总文本
  @Deprecated("Use FromRWKV instead")
  response,

  /// 模型每吐一个token，调用一次, 调用内容为该次 generate 已经吐出的文本
  @Deprecated("Use FromRWKV instead")
  streamResponse,

  @Deprecated("Use FromRWKV instead")
  currentPrompt,

  @Deprecated("Use FromRWKV instead")
  generateStart,

  /// 模型是否正在生成
  @Deprecated("Use FromRWKV instead")
  isGenerating,

  @Deprecated("Use FromRWKV instead")
  responseBufferIds,

  @Deprecated("Use FromRWKV instead")
  generateStop,
  ;
}

@Deprecated("Use FromRWKV instead")
@immutable
final class LLMEvent {
  final _RWKVMessageType type;
  final String content;
  final List<int>? responseBufferIds;
  final int? token;

  const LLMEvent({
    required this.type,
    this.content = "",
    this.responseBufferIds,
    this.token,
  });

  @override
  String toString() {
    return "LLMEvent.type: $type";
  }
}
