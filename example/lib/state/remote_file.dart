// ignore_for_file: constant_identifier_names

part of 'p.dart';

class _RemoteFile {
  late final files = StateProvider.family<FileInfo, FileKey>((ref, key) {
    return FileInfo(key: key);
  });

  late final downloadingFiles = _gs<Map<String, FileKey>>({});

  late final weights = _gs<List<Weights>>([]);
}

/// Public methods
extension $RemoteFile on _RemoteFile {
  FV test() async {
    await getFile(fileKey: FileKey.download_test);
  }

  FV getFile({required FileKey fileKey}) async {
    // 1. check file
    // 2. check zip file
    // 3. if zip file, unzip it, return the path
    // 4. download zip file
    // 5. unzip it, return the path
    final task = DownloadTask(
      url: fileKey.url,
      headers: {
        'x-api-key': '4s5aWqs2f4PzKfgLjuRZgXKvvmal5Z5iq0OzkTPwaA2axgNgSbayfQEX5FgOpTxyyeUM4gsFHHDZroaFDIE3NtSJD6evdz3lAVctyN026keeXMoJ7tmUy5zriMJHJ9aM',
      },
      baseDirectory: BaseDirectory.applicationDocuments,
      filename: fileKey.url.split('/').last.split('?')[0],
      updates: Updates.statusAndProgress, // request status and progress updates
      requiresWiFi: false,
      retries: 5,
      allowPause: false,
      httpRequestMethod: "GET",
    );

    downloadingFiles.uv({task.taskId: fileKey});

    final success = await FileDownloader().enqueue(task);

    if (!success) {
      if (kDebugMode) print("😡 enqueue failed");
      return;
    }

    final modelFile = files(fileKey).v;
    files(fileKey).u(modelFile.copyWith(downloading: true));
  }

  FV checkLocalFile() async {
    await HF.wait(17);
    final fileKeys = FileKey.values.where((e) => e.available).toList();
    for (final key in fileKeys) {
      final path = key.path;
      final pathExists = await File(path).exists();
      final modelFile = files(key).v;
      files(key).u(modelFile.copyWith(hasFile: pathExists));
    }
  }

  FV loadWeights() async {
    if (this.weights.v.isNotEmpty) return;
    final jsonString = await rootBundle.loadString(Assets.config.chat.weights);
    final json = HF.listJSON(jsonDecode(jsonString));
    final weights = json.map((e) => Weights.fromJson(e)).toList();
    this.weights.u(weights);
  }
}

/// Private methods
extension _$RemoteFile on _RemoteFile {
  FV _init() async {
    // 1. check file
    // 2. check zip file
    await FileDownloader().ready;
    FileDownloader().updates.listen(_onTaskUpdate);
    checkLocalFile();
  }

  void _onTaskUpdate(TaskUpdate _taskUpdate) {
    final task = _taskUpdate.task;
    final taskId = task.taskId;

    final downloadingFiles = this.downloadingFiles.v;
    final fileKey = downloadingFiles[taskId];

    if (fileKey == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
      FileDownloader().cancelTaskWithId(taskId);
      return;
    }

    final modelFile = files(fileKey).v;

    switch (_taskUpdate) {
      case TaskProgressUpdate progressUpdate:
        final progress = progressUpdate.progress;
        final networkSpeed = progressUpdate.networkSpeed;
        final timeRemaining = progressUpdate.timeRemaining;
        final expectedFileSize = progressUpdate.expectedFileSize;
        if (kDebugMode) print("💬 $progress $networkSpeed $timeRemaining $expectedFileSize");
        final done = progress >= 1.0;
        files(fileKey).u(modelFile.copyWith(
          progress: progress,
          networkSpeed: done ? modelFile.networkSpeed : networkSpeed,
          timeRemaining: done ? modelFile.timeRemaining : timeRemaining,
        ));
        return;
      case TaskStatusUpdate statusUpdate:
        _onStatusUpdate(statusUpdate);
        return;
    }
  }

  void _onStatusUpdate(TaskStatusUpdate statusUpdate) {
    final task = statusUpdate.task;
    final taskId = task.taskId;

    final downloadingFiles = this.downloadingFiles.v;
    final fileKey = downloadingFiles[taskId];

    if (fileKey == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
      return;
    }

    final modelFile = files(fileKey).v;

    if (kDebugMode) print("✅ _onStatusUpdate:");
    final status = statusUpdate.status;
    final exception = statusUpdate.exception;
    final responseBody = statusUpdate.responseBody;
    final responseHeaders = statusUpdate.responseHeaders;
    final responseStatusCode = statusUpdate.responseStatusCode;

    if (kDebugMode) print("💬 $status $exception $responseBody $responseHeaders $responseStatusCode");

    bool downloading = false;
    if (kDebugMode) print("🔥 $status");
    switch (status) {
      case TaskStatus.enqueued:
        downloading = true;
      case TaskStatus.running:
        downloading = true;
      case TaskStatus.complete:
        downloading = false;
      case TaskStatus.notFound:
        downloading = false;
      case TaskStatus.failed:
        downloading = false;
      case TaskStatus.canceled:
        downloading = false;
      case TaskStatus.waitingToRetry:
        downloading = true;
      case TaskStatus.paused:
        downloading = false;
    }

    files(fileKey).u(modelFile.copyWith(downloading: downloading));
    checkLocalFile();
  }
}
