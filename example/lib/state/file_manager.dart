// ignore_for_file: constant_identifier_names

part of 'p.dart';

class _FileManager {
  late final locals = qsff<LocalFile, FileInfo>((ref, key) {
    return LocalFile(fileInfo: key, targetPath: ref.watch(paths(key)));
  });

  late final paths = qsff<String, FileInfo>((ref, key) {
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
}

/// Public methods
extension $FileManager on _FileManager {
  FV loadAll() async {
    // TODO: networking
    // TODO: networking fallback

    final demoType = P.app.demoType.v;
    final jsonPath = "assets/config/${demoType.name}/weights.json";
    qqq("jsonPath: $jsonPath");
    final jsonString = await rootBundle.loadString(jsonPath);
    final json = HF.listJSON(jsonDecode(jsonString));
    try {
      final weights = json.map((e) => FileInfo.fromJSON(e)).toSet();
      _all.u(weights);
      availableModels.u(weights.where((e) => e.available).toSet());
    } catch (e) {
      qqe(e);
    }
  }

  FV checkLocal() async {
    qq;
    await HF.wait(17);
    final _fileInfos = _all.v.where((e) => e.available).toList();
    for (final fileInfo in _fileInfos) {
      // debugger();
      final path = paths(fileInfo).v;
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
      state.u(state.v.copyWith(hasFile: fileSizeVerified));
    }
  }

  FV getFile({required FileInfo fileInfo}) async {
    final fileName = fileInfo.fileName;
    final url = downloadSource.v.prefix + fileInfo.raw + downloadSource.v.suffix;
    final state = locals(fileInfo);
    qqq("fileKey: $fileInfo\nfileName: $fileName\nurl: $url");

    // TODO: Handle resume after relaunch app

    try {
      state.u(state.v.copyWith(downloading: true));

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

      state.u(state.v.copyWith(downloadTaskId: task.taskId));

      final success = await bd.FileDownloader().enqueue(task);

      if (!success) {
        throw Exception("Enqueue failed");
      }
    } catch (e) {
      if (kDebugMode) print("😡 getFile error: $e");
      state.u(state.v.copyWith(downloading: false));
    }
  }

  FV cancelDownload({required FileInfo fileInfo}) async {
    final state = locals(fileInfo);
    final value = state.v;

    if (!value.downloading) throw Exception("😡 Download not in progress");

    final taskId = value.downloadTaskId;

    if (taskId == null) throw Exception("😡 Task ID not found");

    await bd.FileDownloader().cancelTaskWithId(taskId);
    state.u(value.copyWith(downloading: false, downloadTaskId: null));
  }

  FV deleteFile({required FileInfo fileInfo}) async {
    final state = locals(fileInfo);
    final value = state.v;

    try {
      await cancelDownload(fileInfo: fileInfo);
    } catch (e) {
      qe;
      qqe(e);
    }
    final path = paths(fileInfo).v;
    await File(path).delete();
    state.u(value.copyWith(hasFile: false));
  }
}

/// Private methods
extension _$FileManager on _FileManager {
  FV _init() async {
    // 1. check file
    // 2. check zip file
    await bd.FileDownloader().ready;
    bd.FileDownloader().updates.listen(_onTaskUpdate);
    await loadAll();
    await checkLocal();
  }

  void _onTaskUpdate(bd.TaskUpdate _taskUpdate) {
    final task = _taskUpdate.task;
    final taskId = task.taskId;

    final pairs = _all.v.where((e) => locals(e).v.downloading).map((e) => (e, locals(e).v));
    final pair = pairs.firstWhereOrNull((e) => e.$2.downloadTaskId == taskId);

    if (pair == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
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
        state.u(state.v.copyWith(
          progress: progress,
          networkSpeed: done ? state.v.networkSpeed : networkSpeed,
          timeRemaining: done ? state.v.timeRemaining : timeRemaining,
        ));
        return;
      case bd.TaskStatusUpdate statusUpdate:
        _onStatusUpdate(statusUpdate);
        return;
    }
  }

  void _onStatusUpdate(bd.TaskStatusUpdate statusUpdate) {
    final task = statusUpdate.task;
    final taskId = task.taskId;

    final pairs = _all.v.where((e) => locals(e).v.downloading).map((e) => (e, locals(e).v));
    final pair = pairs.firstWhereOrNull((e) => e.$2.downloadTaskId == taskId);

    if (pair == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
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
    if (kDebugMode) print("🔥 $status");
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

    state.u(state.v.copyWith(downloading: downloading));
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
