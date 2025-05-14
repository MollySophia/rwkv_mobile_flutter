// ignore_for_file: constant_identifier_names

part of 'p.dart';

class _FileManager {
  late final locals = qsff<FileInfo, LocalFile>((ref, key) {
    return LocalFile(fileInfo: key, targetPath: ref.watch(paths(key)));
  });

  late final paths = qsff<FileInfo, String>((ref, key) {
    final dir = ref.watch(P.app.documentsDir);
    final fileName = key.fileName;
    final dirPath = dir!.path;
    return "$dirPath/$fileName";
  });

  late final _all = qs<Set<FileInfo>>({});

  late final availableModels = qs<Set<FileInfo>>({});

  late final downloadSource = qs(FileDownloadSource.hfmirror);

  late final hasDownloadedModels = qs(false);

  late final modelSelectorShown = qs(false);

  late final ttsCores = qs<Set<FileInfo>>({});
}

/// Public methods
extension $FileManager on _FileManager {
  FV syncAvailableModels() async {
    switch (P.app.demoType.q) {
      case DemoType.othello:
        qqw("othello game does not need to sync available models");
        return;
      case DemoType.chat:
      case DemoType.fifthteenPuzzle:
      case DemoType.sudoku:
      case DemoType.tts:
      case DemoType.world:
    }

    qq;
    late final List<JSON> json;

    if (P.app.modelConfig.q.isEmpty) {
      final demoType = P.app.demoType.q;
      final jsonPath = "demo-config.json";
      qqq("jsonPath: $jsonPath");
      final jsonString = await rootBundle.loadString(jsonPath);
      final rawJSON = jsonDecode(jsonString);
      final data = rawJSON[demoType.name]["model_config"];
      json = HF.listJSON(data);
    } else {
      json = P.app.modelConfig.q;
    }

    try {
      final weights = json.map((e) => FileInfo.fromJSON(e)).toSet();
      _all.q = weights;
      availableModels.q = weights.where((e) => e.available).toSet();
      if (P.app.demoType.q == DemoType.tts) {
        ttsCores.q = availableModels.q.where((e) => e.tags.contains("core")).toSet();
      }
    } catch (e) {
      qqe(e);
    }
  }

  FV checkLocal() async {
    qq;
    await HF.wait(17);
    final all = _all.q;
    final _fileInfos = all.where((e) => e.available).toList();

    for (final fileInfo in _fileInfos) {
      final path = paths(fileInfo).q;
      final pathExists = await File(path).exists();
      bool fileSizeVerified = false;
      if (pathExists) {
        final expectFileSize = fileInfo.fileSize;
        final fileSize = await File(path).length();
        fileSizeVerified = expectFileSize == fileSize;
        if (!kDebugMode) {
          if (!fileSizeVerified) File(path).delete();
        }
      }
      final state = locals(fileInfo);
      state.q = state.q.copyWith(hasFile: fileSizeVerified);
    }
  }

  FV getFile({required FileInfo fileInfo}) async {
    final fileName = fileInfo.fileName;
    final url = downloadSource.q.prefix + fileInfo.raw + downloadSource.q.suffix;
    final state = locals(fileInfo);
    qqq("fileKey: $fileInfo\nfileName: $fileName\nurl: $url");

    // TODO: Handle resume after relaunch app

    try {
      state.q = state.q.copyWith(downloading: true);

      final task = bd.DownloadTask(
        url: url,
        baseDirectory: bd.BaseDirectory.applicationDocuments,
        filename: fileName,
        updates: bd.Updates.statusAndProgress, // request status and progress updates
        requiresWiFi: false,
        retries: 5,
        allowPause: false,
        httpRequestMethod: "GET",
      );

      state.q = state.q.copyWith(downloadTaskId: task.taskId);

      final success = await bd.FileDownloader().enqueue(task);

      if (!success) {
        throw Exception("Enqueue failed");
      }
    } catch (e) {
      qqe("getFile error: $e");
      state.q = state.q.copyWith(downloading: false);
    }
  }

  FV cancelDownload({required FileInfo fileInfo}) async {
    final state = locals(fileInfo);
    final value = state.q;

    if (!value.downloading) throw Exception("😡 Download not in progress");

    final taskId = value.downloadTaskId;

    if (taskId == null) throw Exception("😡 Task ID not found");

    await bd.FileDownloader().cancelTaskWithId(taskId);
    state.q = value.copyWith(downloading: false, downloadTaskId: null);
  }

  FV deleteFile({required FileInfo fileInfo}) async {
    final state = locals(fileInfo);
    final value = state.q;

    try {
      await cancelDownload(fileInfo: fileInfo);
    } catch (e) {
      qe;
      qqe(e);
      if (!kDebugMode) Sentry.captureException(e, stackTrace: StackTrace.current);
    }
    final path = paths(fileInfo).q;
    await File(path).delete();
    state.q = value.copyWith(hasFile: false);
  }
}

/// Private methods
extension _$FileManager on _FileManager {
  FV _init() async {
    // 1. check file
    // 2. check zip file
    await bd.FileDownloader().ready;
    bd.FileDownloader().updates.listen(_onTaskUpdate);
    await syncAvailableModels();
    await checkLocal();
  }

  void _onTaskUpdate(bd.TaskUpdate _taskUpdate) {
    final task = _taskUpdate.task;
    final taskId = task.taskId;

    final pairs = _all.q.where((e) => locals(e).q.downloading).map((e) => (e, locals(e).q));
    final pair = pairs.firstWhereOrNull((e) => e.$2.downloadTaskId == taskId);

    if (pair == null) {
      qqe("_onTaskUpdate:");
      qqe("taskId: $taskId not found");
      bd.FileDownloader().cancelTaskWithId(taskId);
      return;
    }

    final state = locals(pair.$1);

    switch (_taskUpdate) {
      case bd.TaskProgressUpdate progressUpdate:
        final progress = progressUpdate.progress;
        final networkSpeed = progressUpdate.networkSpeed;
        final timeRemaining = progressUpdate.timeRemaining;
        final expectedFileSize = progressUpdate.expectedFileSize;
        qqq("$progress $networkSpeed $timeRemaining $expectedFileSize");
        final done = progress >= 1.0;
        state.q = state.q.copyWith(
          progress: progress,
          networkSpeed: done ? state.q.networkSpeed : networkSpeed,
          timeRemaining: done ? state.q.timeRemaining : timeRemaining,
        );
        return;
      case bd.TaskStatusUpdate statusUpdate:
        _onStatusUpdate(statusUpdate);
        return;
    }
  }

  void _onStatusUpdate(bd.TaskStatusUpdate statusUpdate) {
    final task = statusUpdate.task;
    final taskId = task.taskId;

    final pairs = _all.q.where((e) => locals(e).q.downloading).map((e) => (e, locals(e).q));
    final pair = pairs.firstWhereOrNull((e) => e.$2.downloadTaskId == taskId);

    if (pair == null) {
      qqe("_onTaskUpdate:");
      qqe("taskId: $taskId not found");
      return;
    }

    final state = locals(pair.$1);

    qqr("_onStatusUpdate:");
    final status = statusUpdate.status;
    final exception = statusUpdate.exception;
    final responseBody = statusUpdate.responseBody;
    final responseHeaders = statusUpdate.responseHeaders;
    final responseStatusCode = statusUpdate.responseStatusCode;

    qqq("$status $exception $responseBody $responseHeaders $responseStatusCode");

    bool downloading = false;
    qqq("🔥 $status");
    switch (status) {
      case bd.TaskStatus.enqueued:
        downloading = true;
      case bd.TaskStatus.running:
        downloading = true;
      case bd.TaskStatus.complete:
        downloading = false;
      case bd.TaskStatus.notFound:
        downloading = false;
      case bd.TaskStatus.failed:
        downloading = false;
      case bd.TaskStatus.canceled:
        downloading = false;
      case bd.TaskStatus.waitingToRetry:
        downloading = true;
      case bd.TaskStatus.paused:
        downloading = false;
    }

    state.q = state.q.copyWith(downloading: downloading);
    checkLocal();
  }
}

enum FileDownloadSource {
  aifasthub,
  hfmirror,
  huggingface,
  github,
  googleapis,
  ;

  String get prefix => switch (this) {
        aifasthub => 'https://aifasthub.com/',
        hfmirror => 'https://hf-mirror.com/',
        huggingface => 'https://huggingface.co/',
        github => 'https://github.com/',
        googleapis => 'https://googleapis.com/',
      };

  String get suffix => switch (this) {
        aifasthub => '?download=true',
        hfmirror => '?download=true',
        huggingface => '',
        github => '',
        googleapis => '',
      };

  bool get isDebug {
    switch (this) {
      case huggingface:
        return false;
      case hfmirror:
        return false;
      case aifasthub:
        return false;
      case github:
        return true;
      case googleapis:
        return true;
    }
  }
}
