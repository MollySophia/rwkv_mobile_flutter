part of 'p.dart';

class _TTS {
  late final spkNames = qs<List<String>>([]);
  late final ttsDone = qs(true);
}

/// Private methods
extension _$TTS on _TTS {
  FV _init() async {
    if (P.app.demoType.v != DemoType.tts) return;
    qq;
    getTTSSpkNames();
  }
}

/// Public methods
extension $TTS on _TTS {
  FV testSpk() async {
    qq;
    // await runTTS(
    //   ttsText: "你好，世界",
    //   instructionText: "",
    //   promptWavPath: "prompt.wav",
    //   outputWavPath: "output.wav",
    // );

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
    final ttsText = "你好，世界, 哈哈哈哈";
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
    this.spkNames.u(spkNames);
  }
}

List<String> _parseSpkNames(String message) {
  final list = HF.list(jsonDecode(message));
  return list.map((e) => e.toString()).toList();
}
