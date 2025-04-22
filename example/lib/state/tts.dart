part of 'p.dart';

class _TTS {
  late final spkNames = qs<List<String>>([]);
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

  late final selectSpkName = qsn<String>();
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
    selectSpkName.u(spkNames.v.random);
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
}

/// Public methods
extension $TTS on _TTS {
  FV testSpk() async {
    qq;

    final spkName = spkNames.v.random!;
    final outputWavPath = P.app.cacheDir.v!.path + "/output.wav";
    final ttsText = "你好，世界";
    final instructionText = "";
    qqr(outputWavPath);
    qqr(spkName);
    qqr(ttsText);
    qqr(instructionText);

    await runTTSWithPredefinedSpk(
      ttsText: ttsText,
      instructionText: instructionText,
      spkName: spkName,
      outputWavPath: outputWavPath,
    );

    int count = 2000;
    while (!ttsDone.v) {
      await HF.wait(50);
      count--;
      if (count <= 0) {
        qqw("TTS done timeout");
        break;
      }
    }

    final result = await Share.shareXFiles([XFile(outputWavPath)], text: '''spk: $spkName
ttsText: $ttsText
instructionText: $instructionText
outputWavPath: $outputWavPath''');

    if (result.status == ShareResultStatus.success) {
      qqr("Share success");
    } else {
      qqw("Share failed");
    }
  }

  FV testWav() async {
    qq;

    final outputWavPath = P.app.cacheDir.v!.path + "/output.wav";
    final ttsText = "奇怪奇怪真奇怪";
    final instructionText = "";
    final promptWavPath = await fromAssetsToTemp("assets/lib/tts/Trump.wav");
    qqr(outputWavPath);
    qqr(ttsText);
    qqr(instructionText);

    await runTTS(
      ttsText: ttsText,
      instructionText: instructionText,
      promptWavPath: promptWavPath,
      outputWavPath: outputWavPath,
    );

    int count = 2000;
    while (!ttsDone.v) {
      await HF.wait(50);
      count--;
      if (count <= 0) {
        qqw("TTS done timeout");
        break;
      }
    }

    final result = await Share.shareXFiles([XFile(outputWavPath)], text: '''ttsText: $ttsText
instructionText: $instructionText
promptWavPath: $promptWavPath
outputWavPath: $outputWavPath''');

    if (result.status == ShareResultStatus.success) {
      qqr("Share success");
    } else {
      qqw("Share failed");
    }
  }

  FV runTTS({
    required String ttsText,
    required String instructionText,
    required String promptWavPath,
    required String outputWavPath,
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
      }
    ));
  }

  FV runTTSWithPredefinedSpk({
    required String ttsText,
    required String instructionText,
    required String spkName,
    required String outputWavPath,
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
      "runTTSWithPredefinedSpk",
      {
        "ttsText": ttsText,
        "instructionText": instructionText,
        "spkName": spkName,
        "outputWavPath": outputWavPath,
      }
    ));
  }

  FV getTTSSpkNames() async {
    qq;
    final data = await rootBundle.loadString("assets/config/tts/spk_names.json");
    final spkNames = await compute(_parseSpkNames, data);
    this.spkNames.u(spkNames.shuffled);
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
      "(PRC)": ")",
      "_": " (",
      "Japanese": "Japanese)",
      "Korean": "Korean)",
      "English": "English)",
    };

    String name = input;
    replaceMap.forEach((key, value) {
      name = name.replaceAll(key, value);
    });
    return name;
  }

  FV gen() async {
    if (P.rwkv.currentModel.v == null) {
      P.fileManager.modelSelectorShown.u(true);
      return;
    }

    if (!P.chat.canSend.v) return;

    qq;
    late final Message? msg;
    final id = HF.shorterMS;
    final receiveId = HF.shorterMS + 1;
    final selectSourceAudioPath = this.selectSourceAudioPath.q;
    final spkName = selectSpkName.q;
    final ttsText = P.chat.textEditingController.text;

    // TODO: implement instructionText
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

    if (spkName == null && selectSourceAudioPath == null) {
      Alert.warning("Please select a spk or a wav file");
      return;
    }

    final locale = Intl.getCurrentLocale();
    final useEn = locale.startsWith("en");

    final fileName = selectSourceAudioPath?.split("/").last;

    final finalUserMessageContent = useEn
        ? """User:
${spkName != null ? "- Use ${P.tts.safe(spkName)} as the speaker" : ""}
${fileName != null ? "- Use $fileName as the clone sound" : ""}
- Use $ttsText as the speaking content
${instructionText.isNotEmpty ? "- Use \"$instructionText\" as the speaking instruction" : ""}"""
        : """用户要求：
${spkName != null ? "- 使用 ${P.tts.safe(spkName)} 作为说话人" : ""}
${fileName != null ? "- 使用 $fileName 作为克隆声音" : ""}
- 使用 $ttsText 作为说话内容
${instructionText.isNotEmpty ? "- 使用“$instructionText”作为说话指令" : ""}""";

    msg = Message(
      id: id,
      content: finalUserMessageContent,
      isMine: true,
      type: MessageType.userTTS,
      isReasoning: false,
      paused: false,
      ttsTarget: ttsText,
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

    if (spkName != null) {
      await runTTSWithPredefinedSpk(
        ttsText: ttsText,
        instructionText: instructionText,
        spkName: spkName,
        outputWavPath: outputWavPath,
      );
    }

    if (selectSourceAudioPath != null) {
      await runTTS(
        ttsText: ttsText,
        instructionText: instructionText,
        promptWavPath: selectSourceAudioPath,
        outputWavPath: outputWavPath,
      );
    }
  }

  void dismissAllShown() {
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
    print(instruction);
    textInInput.u(instruction);
    textEditingController.text = instruction;
  }
}

List<String> _parseSpkNames(String message) {
  final list = HF.list(jsonDecode(message));
  return list.map((e) => e.toString()).toList();
}
