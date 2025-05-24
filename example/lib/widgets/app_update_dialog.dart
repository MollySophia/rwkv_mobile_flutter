import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';

class AppUpdateDialog extends StatefulWidget {
  final String url;

  const AppUpdateDialog({super.key, required this.url});

  static Future show(BuildContext context, {required String url}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AppUpdateDialog(
          url: url,
        ),
      ),
    );
  }

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  double progress = 0;
  double fileSizeMB = 0;
  bd.DownloadTask? task;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        downloadAppUpdate(widget.url);
      } catch (e) {
        onDownloadFailed();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (task != null) {
      bd.FileDownloader().cancel(task!);
    }
  }

  void onDownloadFailed() {
    bd.FileDownloader().cancel(task!);
    task = null;

    if (!mounted) return;
    setState(() {
      progress = -1;
    });
  }

  FV downloadAppUpdate(String url) async {
    final downloadDir = bd.BaseDirectory.applicationDocuments;
    final fileName = "release.apk";
    final file = File([downloadDir, fileName].join(Platform.pathSeparator));
    if (file.existsSync()) {
      file.deleteSync();
    }
    task = bd.DownloadTask(
      url: url,
      baseDirectory: downloadDir,
      filename: fileName,
      updates: bd.Updates.statusAndProgress,
      requiresWiFi: false,
      retries: 5,
      allowPause: false,
      httpRequestMethod: "GET",
    );

    fileSizeMB = (await task!.expectedFileSize()) / 1024 / 1024;

    final dl = bd.FileDownloader();
    dl.download(
      task!,
      onStatus: (s) {
        if (s.isFinalState) {
          if (progress == 1) {
            Navigator.pop(context);
          } else {
            onDownloadFailed();
          }
        }
      },
      onProgress: (p) {
        setState(() {
          progress = p;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      widthFactor: 1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              4.h,
              Text(
                "Download App Update",
                style: theme.textTheme.headlineSmall,
              ),
              12.h,
              LinearProgressIndicator(
                value: progress <= 0 ? null : progress,
              ),
              8.h,
              if (progress != -1)
                Text(
                  '${(fileSizeMB * progress).round()}MB / ${fileSizeMB.round()}MB',
                  style: theme.textTheme.bodyMedium,
                ),
              if (progress == -1)
                Text(
                  'Download failed',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.redAccent),
                ),
              8.h,
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(S.of(context).cancel_download),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
