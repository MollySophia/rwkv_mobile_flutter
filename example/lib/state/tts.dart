part of 'p.dart';

class _TTS {
  late final spkPairs = qs<JSON>({});
  late final selectSpkName = qsn<String>();

  late final ttsDone = qs(true);

  late final focusNode = FocusNode();
  late final hasFocus = qs(false);

  late final defaultTextInInput = "请用正常的语气说";
  late final textEditingController = TextEditingController(text: defaultTextInInput);
  late final textInInput = qs(defaultTextInInput);

  late final interactingInstruction = qs(TTSInstruction.none);
  late final instructions = qsf<int?, TTSInstruction>(null);

  late final audioInteractorShown = qs(false);
  late final spkShown = qs(false);
  late final intonationShown = qs(false);

  late final selectSourceAudioPath = qsn<String>();
}

/// Private methods
extension _$TTS on _TTS {
  FV _init() async {
    if (P.app.demoType.v != DemoType.tts) return;
    qq;
    P.chat.focusNode.addListener(() {
      if (P.chat.focusNode.hasFocus) {
        dismissAllShown();
      }
    });
    textEditingController.addListener(_onTextEditingControllerValueChanged);
    textInInput.l(_onTextChanged);
    await getTTSSpkNames();
    selectSpkName.u(spkPairs.q.keys.random);
    selectSourceAudioPath.u(null);

    focusNode.addListener(() {
      hasFocus.u(focusNode.hasFocus);
    });
  }

  void _onTextChanged(String next) {
    // qqq("_onTextChanged");
    final textInController = textEditingController.text;
    if (next != textInController) textEditingController.text = next;
  }

  void _onTextEditingControllerValueChanged() {
    // qqq("_onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (textInInput.v != textInController) textInInput.u(textInController);
  }

  FV _runTTS({
    required String ttsText,
    required String instructionText,
    required String promptWavPath,
    required String outputWavPath,
    required String promptSpeechText,
  }) async {
    qq;
    final sendPort = P.rwkv._sendPort;
    if (sendPort == null) {
      qqe("sendPort is null");
      return;
    }
    if (!ttsDone.v) {
      qqe("ttsDone is true");
      Alert.warning("TTS is running, please wait for it to finish");
      return;
    }
    ttsDone.u(false);
    sendPort.send((
      "runTTS",
      {
        "ttsText": ttsText,
        "instructionText": instructionText,
        "promptWavPath": promptWavPath,
        "outputWavPath": outputWavPath,
        "promptSpeechText": promptSpeechText,
      }
    ));
  }
}

/// Public methods
extension $TTS on _TTS {
  FV getTTSSpkNames() async {
    qq;
    try {
      final data = await rootBundle.loadString("assets/lib/tts/pairs.json");
      final spkPairs = await compute(_parseSpkNames, data);
      this.spkPairs.u(spkPairs);
    } catch (e) {
      qqe("$e");
      Sentry.captureException(e);
    }
  }

  FV onAudioInteractorButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    audioInteractorShown.u(!audioInteractorShown.v);
    if (audioInteractorShown.v) {
      intonationShown.u(false);
      spkShown.u(false);
    }
  }

  FV onSpkButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    spkShown.u(!spkShown.v);
    if (spkShown.v) {
      audioInteractorShown.u(false);
      intonationShown.u(false);
    }
  }

  FV onIntonationButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    intonationShown.u(!intonationShown.v);
    if (intonationShown.v) {
      audioInteractorShown.u(false);
      spkShown.u(false);
    }
  }

  String safe(String input) {
    const replaceMap = {
      // "(PRC)": ")",
      // "_": " (",
      // "Japanese": "Japanese)",
      // "Korean": "Korean)",
      // "English": "English)",
    };

    String name = input;
    replaceMap.forEach((key, value) {
      name = name.replaceAll(key, value);
    });

    name = name.split("_").first;

    return name;
  }

  Future<String> getPrebuiltSpkAudioPathFromTemp(String spkName) async {
    qq;
    final fileName = "Chinese(PRC)_$spkName.wav";
    final path = "assets/lib/tts/$fileName";
    final localPath = await fromAssetsToTemp(path);
    return localPath;
  }

  Future<String> getPromptSpeechText(String spkName) async {
    qq;
    final fileName = "Chinese(PRC)_$spkName.json";
    final data = await rootBundle.loadString("assets/lib/tts/$fileName");
    final json = HF.json(jsonDecode(data));
    return json["transcription"];
  }

  FV gen() async {
    qq;
    if (P.rwkv.currentModel.v == null) {
      P.fileManager.modelSelectorShown.u(true);
      return;
    }

    if (!P.chat.canSend.v) return;

    late final Message? msg;
    final id = HF.milliseconds;
    final receiveId = HF.milliseconds + 1;
    final spkName = selectSpkName.q;

    if (spkName == null && this.selectSourceAudioPath.q == null) {
      Alert.warning("Please select a spk or a wav file");
      return;
    }

    final promptSpeechText = spkName == null ? "" : await getPromptSpeechText(spkName);
    final selectSourceAudioPath = this.selectSourceAudioPath.q ?? await getPrebuiltSpkAudioPathFromTemp(spkName!);
    final ttsText = P.chat.textEditingController.text;

    final instructionText = textInInput.q;

    final outputWavPath = P.app.cacheDir.v!.path + "/$receiveId.output.wav";

    if (ttsText.isEmpty) {
      Alert.warning("Please enter text to generate TTS");
      return;
    }

    P.chat.textEditingController.text = "";
    P.chat.focusNode.unfocus();

    audioInteractorShown.u(false);
    intonationShown.u(false);
    spkShown.u(false);

    P.chat.textEditingController.clear();

    msg = Message(
      id: id,
      content: "",
      isMine: true,
      type: MessageType.userTTS,
      isReasoning: false,
      paused: false,
      ttsTarget: ttsText,
      ttsSpeakerName: spkName,
      ttsSourceAudioPath: selectSourceAudioPath,
      ttsInstruction: instructionText,
      audioUrl: selectSourceAudioPath,
    );

    P.chat.messages.ua(msg);

    Future.delayed(34.ms).then((_) {
      P.chat.scrollToBottom();
    });

    final receiveMsg = Message(
      id: receiveId,
      content: "",
      isMine: false,
      changing: true,
      isReasoning: P.rwkv.usingReasoningModel.v,
      paused: false,
      type: MessageType.ttsGeneration,
      audioUrl: outputWavPath,
    );

    P.chat.receiveId.u(receiveId);
    P.chat.messages.ua(receiveMsg);

    qqq("""
ttsText: $ttsText
instructionText: $instructionText
promptWavPath: $selectSourceAudioPath
promptSpeechText: $promptSpeechText
outputWavPath: $outputWavPath""");

    await _runTTS(
      ttsText: ttsText,
      instructionText: instructionText,
      promptWavPath: selectSourceAudioPath!,
      promptSpeechText: promptSpeechText,
      outputWavPath: outputWavPath,
    );
  }

  void dismissAllShown() {
    if (P.app.demoType.v != DemoType.tts) return;
    qq;
    audioInteractorShown.q = false;
    spkShown.q = false;
    intonationShown.q = false;
    focusNode.unfocus();
    interactingInstruction.q = TTSInstruction.none;
  }

  void onRefreshButtonPressed() {
    qq;
    textInInput.u(defaultTextInInput);
    TTSInstruction.values.forEach((action) {
      instructions(action).q = null;
    });
  }

  void onClearButtonPressed() {
    qq;
    textInInput.u("");
    TTSInstruction.values.forEach((action) {
      instructions(action).q = null;
    });
  }

  void syncInstruction() {
    qq;
    String instruction = "请用";
    TTSInstruction.values.where((e) => e.forInstruction).forEach((action) {
      final index = instructions(action).q;
      if (index != null) {
        instruction += "${action.head}${action.options[index]}${action.tail}";
      }
    });
    instruction += "说一下";
    instruction = instruction.replaceAll("用用", "用");
    instruction = instruction.replaceAll("用以", "以");
    instruction = instruction.replaceAll("用模仿", "模仿");
    textInInput.u(instruction);
    textEditingController.text = instruction;
  }
}

JSON _parseSpkNames(String message) {
  return HF.json(jsonDecode(message));
}
