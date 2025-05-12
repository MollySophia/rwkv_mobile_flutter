part of 'p.dart';

extension _Instruction on Language {
  String get _instruct => switch (this) {
        Language.none => "",
        Language.en => "",
        Language.ja => "日本語で話してください。",
        Language.ko => "한국어로 말씀해주세요.",
        Language.zh_Hans => "",
        Language.zh_Hant => "",
      };
}

class _TTS {
  late final audioInteractorShown = qs(false);
  late final cfmSteps = qs(_defaultCfmSteps);
  late final focusNode = FocusNode();
  late final hasFocus = qs(false);
  late final instructions = qsf<TTSInstruction, int?>(null);
  late final interactingInstruction = qs(TTSInstruction.none);
  late final intonationShown = qs(false);
  late final selectSourceAudioPath = qsn<String>();
  late final selectedLanguage = qs(Language.none);

  /// 若用户选择自己的声音作为源声音, 则该 value 为 null
  late final selectedSpkName = qsn<String>();

  late final selectedSpkPanelFilter = qs(Language.none);
  late final spkPairs = qs<JSON>({});
  late final spkShown = qs(false);
  late final textEditingController = TextEditingController(text: _defaultTextInInput);
  late final textInInput = qs(_defaultTextInInput);
  late final ttsDone = qs(true);

  static const _defaultTextInInput = "请用正常的语气说";
  static const _cfmStepsKey = "cfmSteps";
  static const _defaultCfmSteps = 5;
  static const _replaceMap = {
    "English": "🇺🇸",
    "Japanese": "🇯🇵",
    "Korean": "🇰🇷",
    "Chinese(PRC)": "🇨🇳",
  };

  static const _spkNameToLanguageMap = {
    "English": Language.en,
    "Japanese": Language.ja,
    "Korean": Language.ko,
    "Chinese(PRC)": Language.zh_Hans,
  };
}

/// Private methods
extension _$TTS on _TTS {
  FV _init() async {
    if (P.app.demoType.q != DemoType.tts) return;
    qq;
    P.chat.focusNode.addListener(_onChatFocusNodeChanged);

    textEditingController.addListener(_onTextEditingControllerValueChanged);
    textInInput.l(_onTextChanged);
    await getTTSSpkNames();

    final prefs = await SharedPreferences.getInstance();
    final cfmSteps = prefs.getInt(_TTS._cfmStepsKey);
    if (cfmSteps == null) {
      this.cfmSteps.q = _TTS._defaultCfmSteps;
    } else {
      this.cfmSteps.q = cfmSteps;
    }

    final spkPairs = this.spkPairs.q;

    selectedSpkName.q = spkPairs.keys.where((e) => e.contains("Chinese")).random;

    selectSourceAudioPath.q = null;

    focusNode.addListener(() {
      hasFocus.q = focusNode.hasFocus;
    });

    selectedSpkName.l(_onSelectSpkNameChanged, fireImmediately: true);
    spkShown.l(_onSpkShownChanged, fireImmediately: true);
  }

  void _onSpkShownChanged(bool next) {
    selectedSpkPanelFilter.q = selectedLanguage.q;
  }

  void _onSelectSpkNameChanged(String? next) {
    qq;
    if (next == null) {
      selectedLanguage.q = Language.none;
      return;
    }

    for (final key in _TTS._spkNameToLanguageMap.keys) {
      final contains = next.contains(key);
      if (contains) {
        selectedLanguage.q = _TTS._spkNameToLanguageMap[key]!;
        return;
      }
    }
  }

  void _onChatFocusNodeChanged() {
    qqq("P.chat.focusNode.hasFocus: ${P.chat.focusNode.hasFocus}");
    if (P.chat.focusNode.hasFocus) {
      dismissAllShown(intonationShown: intonationShown.q);
    }
  }

  void _onTextChanged(String next) {
    // qqq("_onTextChanged");
    final textInController = textEditingController.text;
    if (next != textInController) textEditingController.text = next;
  }

  void _onTextEditingControllerValueChanged() {
    // qqq("_onTextEditingControllerValueChanged");
    final textInController = textEditingController.text;
    if (textInInput.q != textInController) textInInput.q = textInController;
  }

  FV _runTTS({
    required String ttsText,
    required String instructionText,
    required String promptWavPath,
    required String outputWavPath,
    required String promptSpeechText,
  }) async {
    qq;
    if (!ttsDone.q) {
      qqe("ttsDone is true");
      Alert.warning("TTS is running, please wait for it to finish");
      return;
    }

    ttsDone.q = false;
    P.rwkv.send(to_rwkv.RunTTSAsync(
      ttsText: ttsText,
      instructionText: instructionText,
      promptWavPath: promptWavPath,
      outputWavPath: outputWavPath,
      promptSpeechText: promptSpeechText,
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
      this.spkPairs.q = spkPairs;
    } catch (e) {
      qqe("$e");
      Sentry.captureException(e, stackTrace: StackTrace.current);
    }
  }

  FV onAudioInteractorButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    audioInteractorShown.q = !audioInteractorShown.q;
    if (audioInteractorShown.q) {
      intonationShown.q = false;
      spkShown.q = false;
    }
  }

  FV onSpkButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    spkShown.q = !spkShown.q;
    if (spkShown.q) {
      audioInteractorShown.q = false;
      intonationShown.q = false;
    }
  }

  FV onIntonationButtonPressed() async {
    qq;
    Gaimon.light();
    if (focusNode.hasFocus) focusNode.unfocus();
    if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    intonationShown.q = !intonationShown.q;
    if (intonationShown.q) {
      audioInteractorShown.q = false;
      spkShown.q = false;
    }

    if (intonationShown.q) {
      P.chat.focusNode.unfocus();
      await Future.delayed(300.ms);
      P.chat.focusNode.requestFocus();
    } else {
      if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
    }
  }

  @Deprecated("想想更面向状态的方法")
  String safe(String input) {
    const replaceMap = {};

    String name = input;
    replaceMap.forEach((key, value) {
      name = name.replaceAll(key, value);
    });

    name = name.replaceAll(name.split("_").first + "_", "");

    name = name.replaceAll(RegExp(r"_[0-9]+"), "");

    return name;
  }

  @Deprecated("想想更面向状态的方法")
  String flagChange(String input) {
    String name = input;
    _TTS._replaceMap.forEach((key, value) {
      name = name.replaceAll(key, value);
    });

    return name;
  }

  Future<String> getPrebuiltSpkAudioPathFromTemp(String spkName) async {
    qq;
    final fileName = "$spkName.wav";
    final path = "assets/lib/tts/$fileName";
    final localPath = await fromAssetsToTemp(path);
    return localPath;
  }

  Future<String> getPromptSpeechText(String spkName) async {
    qq;
    final fileName = "$spkName.json";
    final data = await rootBundle.loadString("assets/lib/tts/$fileName");
    final json = HF.json(jsonDecode(data));
    return json["transcription"];
  }

  FV gen() async {
    qq;
    if (P.rwkv.currentModel.q == null) {
      P.fileManager.modelSelectorShown.q = true;
      return;
    }

    if (!P.chat.canSend.q) return;

    late final Message? msg;
    final id = HF.shorterUS;
    final receiveId = HF.shorterUS + 1;
    final spkName = selectedSpkName.q;

    if (spkName == null && this.selectSourceAudioPath.q == null) {
      Alert.warning("Please select a spk or a wav file");
      return;
    }

    final promptSpeechText = spkName == null ? "" : await getPromptSpeechText(spkName);
    final selectSourceAudioPath = this.selectSourceAudioPath.q ?? await getPrebuiltSpkAudioPathFromTemp(spkName!);
    final ttsText = P.chat.textEditingController.text;

    final instructionText = textInInput.q;

    final outputWavPrefix = P.app.cacheDir.q!.path + "/$receiveId.output";
    // TODO: handle multiple wav output via getTTSOutputFileList
    final outputWavPath = P.app.cacheDir.q!.path + "/$receiveId.output.0.wav";

    if (ttsText.isEmpty) {
      Alert.warning("Please enter text to generate TTS");
      return;
    }

    P.chat.textEditingController.text = "";
    P.chat.focusNode.unfocus();

    audioInteractorShown.q = false;
    intonationShown.q = false;
    spkShown.q = false;

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
      ttsCFMSteps: cfmSteps.q,
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
      isReasoning: P.rwkv.usingReasoningModel.q,
      paused: false,
      type: MessageType.ttsGeneration,
      audioUrl: outputWavPath,
    );

    P.chat.receiveId.q = receiveId;
    P.chat.messages.ua(receiveMsg);

    qqr("""ttsText: $ttsText
instructionText: $instructionText
promptWavPath: $selectSourceAudioPath
promptSpeechText: $promptSpeechText
outputWavPath: $outputWavPath""");

    await _runTTS(
      ttsText: ttsText,
      instructionText: instructionText,
      promptWavPath: selectSourceAudioPath,
      promptSpeechText: promptSpeechText,
      outputWavPath: outputWavPrefix,
    );
  }

  void dismissAllShown({bool intonationShown = false}) {
    qqq("intonationShown: $intonationShown");

    if (P.app.demoType.q != DemoType.tts) return;

    audioInteractorShown.q = false;
    spkShown.q = false;
    this.intonationShown.q = intonationShown;

    focusNode.unfocus();
    interactingInstruction.q = TTSInstruction.none;
  }

  void onRefreshButtonPressed() {
    qq;
    textInInput.q = _TTS._defaultTextInInput;
    TTSInstruction.values.forEach((action) {
      instructions(action).q = null;
    });
  }

  void onClearButtonPressed() {
    qq;
    textInInput.q = "";
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
    textInInput.q = instruction;
    textEditingController.text = instruction;
  }

  FV setTTSCFMSteps(int steps) async {
    qq;
    cfmSteps.q = steps;
    P.rwkv.send(to_rwkv.SetTTSCFMSteps(cfmSteps: steps));
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_TTS._cfmStepsKey, steps);
  }

  FV showTTSCFMStepsSelector() async {
    qq;
    final context = getContext();
    if (context == null) return;
    if (!context.mounted) return;
    final currentQ = cfmSteps.q;
    final res = await showConfirmationDialog<int?>(
      context: context,
      title: "TTS CFM Steps",
      message: "范围3～10吧，越高越慢越精细",
      initialSelectedActionKey: currentQ,
      actions: [3, 4, 5, 6, 7, 8, 9, 10].m((value) => AlertDialogAction<int>(label: value.toString(), key: value)),
    );
    qqq("$res");

    if (res == null) return;

    cfmSteps.q = res;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_TTS._cfmStepsKey, res);
    setTTSCFMSteps(res);
  }
}

JSON _parseSpkNames(String message) {
  return HF.json(jsonDecode(message));
}
