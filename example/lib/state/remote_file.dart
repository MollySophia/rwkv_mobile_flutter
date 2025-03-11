// ignore_for_file: constant_identifier_names

part of 'p.dart';

enum RemoteFileSource {
  aifasthub,
  huggingface,
  github,
  googleapis,
  ;

  bool get isDebug {
    switch (this) {
      case huggingface:
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

class _RemoteFile {
  late final files = StateProvider.family<FileInfo, FileKey>((ref, key) {
    return FileInfo(key: key);
  });

  /// downloading files
  late final downloadingFiles = _gs<Map<String, FileKey>>({});

  late final weights = _gs<List<Weights>>([]);

  late final source = _gs(RemoteFileSource.aifasthub);
}

/// Public methods
extension $RemoteFile on _RemoteFile {
  FV getFile({required FileKey fileKey}) async {
    // 1. check file
    // 2. check zip file
    // 3. if zip file, unzip it, return the path
    // 4. download zip file
    // 5. unzip it, return the path
    final fileName = fileKey.url.split('/').last.split('?')[0];
    final task = bd.DownloadTask(
      url: fileKey.url,
      headers: {
        'x-api-key': '4s5aWqs2f4PzKfgLjuRZgXKvvmal5Z5iq0OzkTPwaA2axgNgSbayfQEX5FgOpTxyyeUM4gsFHHDZroaFDIE3NtSJD6evdz3lAVctyN026keeXMoJ7tmUy5zriMJHJ9aM',
      },
      baseDirectory: bd.BaseDirectory.applicationDocuments,
      filename: fileName,
      updates: bd.Updates.statusAndProgress, // request status and progress updates
      requiresWiFi: false,
      retries: 5,
      allowPause: false,
      httpRequestMethod: "GET",
    );

    logTrace("💬 fileKey: $fileKey\nfileName: $fileName\nurl: ${fileKey.url}");

    downloadingFiles.uv({task.taskId: fileKey});

    final success = await bd.FileDownloader().enqueue(task);

    if (!success) {
      if (kDebugMode) print("😡 enqueue failed");
      return;
    }

    final modelFile = files(fileKey).v;
    files(fileKey).u(modelFile.copyWith(downloading: true));
  }

  FV cancelDownload({required FileKey fileKey}) async {
    final downloadingFiles = this.downloadingFiles.v;
    final taskId = downloadingFiles.entries.firstWhereOrNull((e) => e.value == fileKey)?.key;
    if (taskId == null) {
      if (kDebugMode) print("😡 cancelDownload: taskId not found");
      return;
    }
    await bd.FileDownloader().cancelTaskWithId(taskId);
    this.downloadingFiles.ur(taskId);
    files(fileKey).u(files(fileKey).v.copyWith(downloading: false));
  }

  FV deleteFile({required FileKey fileKey}) async {
    try {
      await cancelDownload(fileKey: fileKey);
    } catch (e) {
      logTrace("😡 $e");
      if (kDebugMode) print("😡 $e");
    }
    final path = fileKey.path;
    await File(path).delete();
    files(fileKey).u(files(fileKey).v.copyWith(hasFile: false));
  }

  FV checkLocalFile() async {
    await HF.wait(17);
    final fileKeys = FileKey.values.where((e) => e.available).toList();
    for (final key in fileKeys) {
      final path = key.path;
      final pathExists = await File(path).exists();
      logTrace("💬 key: $key pathExists: $pathExists");
      bool fileSizeVerified = false;
      if (pathExists) {
        final expectFileSize = key.weights?.fileSize;
        final fileSize = await File(path).length();
        fileSizeVerified = expectFileSize == fileSize;
        // if (kDebugMode) print("💬 file: $key expectFileSize: $expectFileSize actualFileSize: $fileSize");
        logTrace("💬 file: $key expectFileSize: $expectFileSize fileSize: $fileSize");
        if (expectFileSize != fileSize) await File(path).delete();
      }
      files(key).u(files(key).v.copyWith(hasFile: fileSizeVerified));
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
    await bd.FileDownloader().ready;
    bd.FileDownloader().updates.listen(_onTaskUpdate);
    checkLocalFile();
  }

  void _onTaskUpdate(bd.TaskUpdate _taskUpdate) {
    final task = _taskUpdate.task;
    final taskId = task.taskId;

    final downloadingFiles = this.downloadingFiles.v;
    final fileKey = downloadingFiles[taskId];

    if (fileKey == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
      bd.FileDownloader().cancelTaskWithId(taskId);
      return;
    }

    final modelFile = files(fileKey).v;

    switch (_taskUpdate) {
      case bd.TaskProgressUpdate progressUpdate:
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
      case bd.TaskStatusUpdate statusUpdate:
        _onStatusUpdate(statusUpdate);
        return;
    }
  }

  void _onStatusUpdate(bd.TaskStatusUpdate statusUpdate) {
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

    files(fileKey).u(modelFile.copyWith(downloading: downloading));
    checkLocalFile();
  }
}
