// ignore_for_file: constant_identifier_names

part of 'p.dart';

enum FileKey {
  v7_world_0_1b_st,
  v7_world_0_1ncnn,

  v7_world_0_4b_st,
  v7_world_0_4b_ncnn,
  v7_world_0_4gguf,

  v7_world_1_5b_st,
  v7_world_1_5b_ncnn,
  v7_world_1_5b_gguf,

  v7_world_3b_st,
  v7_world_3b_ncnn,
  v7_world_3b_gguf,

  world_vocab,
  othello_vocab,

  test,
  ;

  String get url {
    const baseUrl = 'https://api-model.rwkvos.com/download';
    switch (this) {
      case FileKey.v7_world_0_1b_st:
        return '$baseUrl/v7_world_0_1b_st';
      case FileKey.v7_world_0_1ncnn:
        return '$baseUrl/v7_world_0_1ncnn';
      case FileKey.v7_world_0_4b_st:
        return '$baseUrl/v7_world_0_4b_st';
      case FileKey.v7_world_0_4b_ncnn:
        return '$baseUrl/v7_world_0_4b_ncnn';
      case FileKey.v7_world_0_4gguf:
        return '$baseUrl/rwkv7-world-0.4B-Q8_0.gguf.zip';
      case FileKey.v7_world_1_5b_st:
        return '$baseUrl/v7_world_1_5b_st';
      case FileKey.v7_world_1_5b_ncnn:
        return '$baseUrl/v7_world_1_5b_ncnn';
      case FileKey.v7_world_3b_st:
        return '$baseUrl/v7_world_3b_st';
      case FileKey.v7_world_3b_ncnn:
        return '$baseUrl/v7_world_3b_ncnn';
      case FileKey.v7_world_3b_gguf:
        return '$baseUrl/v7_world_3b_gguf';
      case FileKey.test:
        return '$baseUrl/test.jpeg.zip';
      case FileKey.v7_world_1_5b_gguf:
        return '$baseUrl/rwkv7-world-1.5B-Q8_0.gguf.zip';
      case FileKey.world_vocab:
        return '$baseUrl/rwkv7-world-vocab.bin';
      case FileKey.othello_vocab:
        return '$baseUrl/rwkv7-othello-vocab.bin';
    }
  }
}

class FileInfo {
  final FileKey key;
  final String url;
  final String? localPath;
  final String? zipPath;
  final String? unzipPath;
  final int size;
  final int downloadSize;
  final String? taskId;

  const FileInfo({
    required this.key,
    required this.url,
    this.localPath,
    this.zipPath,
    this.unzipPath,
    this.size = 1,
    this.downloadSize = 0,
    this.taskId,
  });
}

class _RemoteFile {
  late final files = StateProvider.family<FileInfo, FileKey>((ref, key) {
    return FileInfo(key: key, url: key.url);
  });

  late final runningTaskIds = _gs<Set<String>>({});
}

/// Public methods
extension $RemoteFile on _RemoteFile {
  FV getFile({
    required FileKey fileKey,
  }) async {
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

    final success = await FileDownloader().enqueue(task);

    if (!success) {
      if (kDebugMode) print("😡 enqueue failed");
      return;
    }

    runningTaskIds.ua(task.taskId);

    final modelFile = FileInfo(key: fileKey, url: fileKey.url, taskId: task.taskId);
    files(fileKey).u(modelFile);
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
    // debugger();
    // print(_taskUpdate);
    final task = _taskUpdate.task;
    final taskId = task.taskId;
    switch (_taskUpdate) {
      case TaskProgressUpdate progressUpdate:
        final progress = progressUpdate.progress;
        final networkSpeed = progressUpdate.networkSpeed;
        final timeRemaining = progressUpdate.timeRemaining;
        final expectedFileSize = progressUpdate.expectedFileSize;
        return;
      case TaskStatusUpdate statusUpdate:
        final status = statusUpdate.status;
        final exception = statusUpdate.exception;
        final responseBody = statusUpdate.responseBody;
        final responseHeaders = statusUpdate.responseHeaders;
        final responseStatusCode = statusUpdate.responseStatusCode;
        final mimeType = statusUpdate.mimeType;
        final charSet = statusUpdate.charSet;
        return;
    }
  }
}
