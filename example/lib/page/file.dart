// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/state/p.dart';

class PageFile extends ConsumerWidget {
  const PageFile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = FileKey.values.where((e) => e.available).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("File"),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _Cell(fileKey: list[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          P.remoteFile.getFile(fileKey: FileKey.test);
        },
        child: const Icon(Icons.download),
      ),
    );
  }
}

class _Cell extends ConsumerWidget {
  final FileKey fileKey;

  const _Cell({required this.fileKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(P.remoteFile.files(fileKey));
    return C(
      decoration: BD(
        color: kC,
        borderRadius: 8.r,
        border: Border.all(color: kB.wo(0.5)),
      ),
      margin: EI.a(8),
      padding: EI.a(8),
      child: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: MaterialTextSelectionControls(),
        child: Co(
          c: CAA.start,
          children: [
            T(file.key.name),
            T(file.key.url),
            T("${"zipPath".codeToName}: " + file.key.zipPath.replaceAll("/Users/wangce/Library/Containers/", "")),
            T("${"path".codeToName}: " + file.key.path.replaceAll("/Users/wangce/Library/Containers/", "")),
            T("${"zipSize".codeToName} (mb): " + (file.zipSize / 1024 / 1024).toStringAsFixed(2)),
            T("${"fileSize".codeToName} (bytes): " + file.fileSize.toString()),
            T("${"progress".codeToName}: " + file.progress.toString()),
            T("${"networkSpeed".codeToName} (MB/s): " + file.networkSpeed.toString()),
            T("${"timeRemaining".codeToName}: " + file.timeRemaining.toString()),
            if (!file.downloading)
              IconButton(
                onPressed: () {
                  P.remoteFile.getFile(fileKey: file.key);
                },
                icon: const Icon(Icons.download),
              ),
            if (file.downloading)
              C(
                padding: EI.a(12),
                child: SB(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
