// ignore_for_file: constant_identifier_names

part of 'p.dart';

class _RemoteFile {
  late final files = StateProvider.family<FileInfo, FileKey>((ref, key) {
    return FileInfo(key: key);
  });

  late final downloadingFiles = _gs<Map<String, FileKey>>({});
}

/// Public methods
extension $RemoteFile on _RemoteFile {
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
      baseDirectory: BaseDirectory.temporary,
      filename: fileKey.url.split('/').last,
      updates: Updates.statusAndProgress, // request status and progress updates
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
      httpRequestMethod: "GET",
    );

    downloadingFiles.uv({task.taskId: fileKey});

    final success = await FileDownloader().enqueue(task);

    if (!success) {
      if (kDebugMode) print("😡 enqueue failed");
      return;
    }

    final modelFile = files(fileKey).v;
    files(fileKey).u(modelFile.copyWith(taskId: task.taskId, downloading: true));
  }
}

/// Private methods
extension _$RemoteFile on _RemoteFile {
  FV _init() async {
    // 1. check file
    // 2. check zip file
    await FileDownloader().ready;
    FileDownloader().updates.listen(_onTaskUpdate);
  }

  void _onTaskUpdate(TaskUpdate _taskUpdate) {
    final task = _taskUpdate.task;
    final taskId = task.taskId;

    final downloadingFiles = this.downloadingFiles.v;
    final fileKey = downloadingFiles[taskId];

    if (fileKey == null) {
      if (kDebugMode) print("😡 _onTaskUpdate:");
      if (kDebugMode) print("😡 taskId: $taskId not found");
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
          zipSize: done ? modelFile.zipSize : expectedFileSize,
          downloading: done ? false : true,
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

    bool downloading = false;
    switch (status) {
      case TaskStatus.enqueued:
        downloading = false;
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
  }
}
