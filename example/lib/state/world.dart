part of 'p.dart';

class _World {
  // 🔥 Vision

  late final imagePath = qsn<String>();
  late final imageHeight = qsn<double>();
  late final visualFloatHeight = qsn<double>();

  // 🔥 Audio

  /// in milliseconds
  late final startTime = qs(0);

  /// in milliseconds
  late final endTime = qs(0);
  late final audioPath = qs("");
  late final audioDuration = qs(0);
  late final recording = qs(false);
  late final playing = qs(false);
  late final _recorder = ar.AudioRecorder();
  late final _audioPlayer = ap.AudioPlayer();

  /// TODO: Use it!
  late final streaming = qs(false);
  late final audioFileStreamController = StreamController<(File file, int length)>.broadcast();
  final List<Uint8List> _audioData = [];
  Stream<Uint8List>? _currentRecorderStream;
  StreamController<Uint8List>? _currentStreamController;
}

/// Public methods
extension $World on _World {
  FV startRecord() async {
    qq;
    recording.u(true);
    await stopPlaying();
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      Alert.warning("Please grant permission to use microphone.");
      return;
    }

    final t = qDebugShorterMicroseconds;
    startTime.u(t);
    _currentStreamController = StreamController<Uint8List>();
    final rawAudioStream = _currentStreamController!.stream;
    final audioStream = rawAudioStream.asBroadcastStream();

    _audioData.clear();
    audioStream.listen(
      (data) {
        _audioData.add(data);
      },
      onDone: () {
        qqq("AudioStream Done");
      },
      onError: (error, stackTrace) {
        qqe("AudioStream Error: $error");
        qqe("AudioStream StackTrace: $stackTrace");
      },
    );
  }

  FV stopRecord({bool isCancel = false}) async {
    qq;
    recording.u(false);

    final cc = _currentStreamController;
    cc?.close();
    _currentStreamController = null;

    if (isCancel) {
      _audioData.clear();
      return;
    }

    final t = qDebugShorterMicroseconds;
    endTime.u(t);

    final audioLengthInMilliseconds = endTime.v - startTime.v;

    if (audioLengthInMilliseconds < 1000) {
      Alert.warning("Your voice is too short, please press the button longer to retrieve your voice.");
      return;
    }

    if (_audioData.isEmpty) throw Exception("😡 audioData is empty");

    final cacheDir = P.app.cacheDir.v;
    if (cacheDir == null) throw Exception("😡 cacheDir is null");

    final path = "${cacheDir.path}/$qDebugShorterMicroseconds.wav";
    final file = File(path);

    List<int> wavHeader = _createWavHeader(dataSize: _audioData.expand((x) => x).length, sampleRate: 16000, numChannels: 1, bitsPerSample: 16);

    await file.writeAsBytes(wavHeader);

    for (var chunk in _audioData) {
      await file.writeAsBytes(chunk, mode: FileMode.append);
    }

    audioFileStreamController.add((file, audioLengthInMilliseconds));

    _audioData.clear();
  }

  FV play({required String path}) async {
    if (path.isEmpty) return;
    await stopPlaying();
    ap.Source source = ap.DeviceFileSource(path);
    playing.u(true);
    Gaimon.light();
    await _audioPlayer.play(source);
  }

  FV stopPlaying() async {
    playing.u(false);
    await _audioPlayer.stop();
  }
}

/// Private methods
extension _$World on _World {
  FV _init() async {
    qq;
    P.rwkv.currentWorldType.lv(_onWorldTypeChanged);
    P.app.demoType.lv(_onWorldTypeChanged);
    _audioPlayer.eventStream.listen(_onPlayerChanged);
  }

  void _onPlayerChanged(ap.AudioEvent event) {
    qqq("🔊 AudioPlayerEvent: $event");
    final eventType = event.eventType;
    switch (eventType) {
      case ap.AudioEventType.complete:
        playing.u(false);
      case ap.AudioEventType.log:
        break;
      case ap.AudioEventType.prepared:
      case ap.AudioEventType.duration:
      case ap.AudioEventType.seekComplete:
        break;
    }
  }

  void _onWorldTypeChanged() async {
    final demoType = P.app.demoType.v;
    final isWorldDemo = demoType == DemoType.world;
    final currentWorldType = P.rwkv.currentWorldType.v;
    final isAudioDemo = currentWorldType == WorldType.engAudioQA || currentWorldType == WorldType.chineseASR || currentWorldType == WorldType.engASR;

    P.chat.clearMessages();
    imagePath.u(null);
    imageHeight.uc();
    visualFloatHeight.uc();
    startTime.u(0);
    endTime.u(0);
    audioDuration.u(0);
    recording.u(false);
    playing.u(false);
    audioPath.u("");

    if (!isAudioDemo || !isWorldDemo) {
      await _recorder.pause();
      await _recorder.stop();
      await _audioPlayer.stop();
      _currentRecorderStream = null;
      streaming.u(false);
      return;
    }

    final hasPermission = await _recorder.hasPermission();

    qqq("hasPermission: $hasPermission, isAudioDemo: $isAudioDemo, isWorldDemo: $isWorldDemo");

    if (!hasPermission) {
      Alert.warning("Please grant permission to use microphone.");
      await _recorder.pause();
      await _recorder.stop();
      await _audioPlayer.stop();
      _currentRecorderStream = null;
      streaming.u(false);
      return;
    }

    final config = const ar.RecordConfig(
      encoder: ar.AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    streaming.u(true);
    try {
      _currentRecorderStream = await _recorder.startStream(config);
    } catch (e) {
      streaming.u(false);
      qqe("Failed to start recording stream");
      qqq(e);
    }

    _currentRecorderStream!.listen((data) {
      final cc = _currentStreamController;
      if (cc == null) return;
      cc.add(data);
    });
  }

  List<int> _createWavHeader({
    required int dataSize,
    required int sampleRate,
    required int numChannels,
    required int bitsPerSample,
  }) {
    final bytesPerSample = bitsPerSample ~/ 8;
    final blockAlign = numChannels * bytesPerSample;
    final byteRate = sampleRate * blockAlign;
    final chunkSize = 36 + dataSize;

    List<int> header = [];

    header.addAll('RIFF'.codeUnits);
    header.addAll(_intToBytes(chunkSize, 4));
    header.addAll('WAVE'.codeUnits);

    header.addAll('fmt '.codeUnits);
    header.addAll(_intToBytes(16, 4));
    header.addAll(_intToBytes(1, 2));
    header.addAll(_intToBytes(numChannels, 2));
    header.addAll(_intToBytes(sampleRate, 4));
    header.addAll(_intToBytes(byteRate, 4));
    header.addAll(_intToBytes(blockAlign, 2));
    header.addAll(_intToBytes(bitsPerSample, 2));

    header.addAll('data'.codeUnits);
    header.addAll(_intToBytes(dataSize, 4));

    return header;
  }

  List<int> _intToBytes(int value, int byteCount) {
    List<int> bytes = [];
    for (int i = 0; i < byteCount; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }
}
