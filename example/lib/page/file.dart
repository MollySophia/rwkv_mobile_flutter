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
        title: const Text("File"),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final fileKey = list[index];
          return _Cell(fileKey: fileKey);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          P.remoteFile.checkLocalFile();
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
      margin: const EI.a(8),
      padding: const EI.a(8),
      child: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: MaterialTextSelectionControls(),
        child: Co(
          c: CAA.start,
          children: [
            T(file.key.name),
            T(file.key.url),
            T("${"path".codeToName}: " + file.key.path.replaceAll("/Users/wangce/Library/Containers/", "")),
            T("${"fileSize".codeToName} (bytes): " + file.fileSize.toString()),
            T("${"progress".codeToName}: " + file.progress.toString()),
            T("${"networkSpeed".codeToName} (mb/s): " + file.networkSpeed.toString()),
            T("${"timeRemaining".codeToName}: " + file.timeRemaining.toString()),
            Ro(
              children: [
                if (!file.downloading)
                  IconButton(
                    onPressed: () {
                      P.remoteFile.getFile(fileKey: file.key);
                    },
                    icon: const Icon(Icons.download),
                  ),
                if (file.downloading)
                  C(
                    padding: const EI.a(12),
                    child: const SB(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (file.hasFile)
                  C(
                    decoration: BD(color: kCG.wo(0.2)),
                    padding: const EI.a(8),
                    child: const T("file found"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
