// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/file_info.dart';
import 'package:zone/state/p.dart';

class PageFile extends ConsumerWidget {
  const PageFile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = FileKey.values;
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
      child: Co(
        c: CAA.start,
        children: [
          SB(width: 160, child: T(file.key.name)),
          SB(width: 560, child: T(file.key.url)),
          T(file.key.zipPath),
          T(file.key.path),
          T(file.zipSize.toString()),
          T(file.downloadedZipSize.toString()),
          T(file.fileSize.toString()),
        ],
      ),
    );
  }
}
