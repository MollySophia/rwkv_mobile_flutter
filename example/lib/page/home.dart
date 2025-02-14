import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/file_info.dart';
import 'package:zone/route/method.dart';
import 'package:zone/route/page_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zone/state/p.dart';

class PageHome extends ConsumerWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const T("RWKV Zone"),
      ),
      body: Co(
        c: CAA.start,
        children: [
          TextButton(
            onPressed: () {
              push(PageKey.othello);
            },
            child: T(S.current.othello_title),
          ),
          TextButton(
            onPressed: () {
              push(PageKey.chat);
            },
            child: T(S.current.chat_title),
          ),
          _FileState(),
        ],
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

class _FileState extends ConsumerWidget {
  const _FileState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SB();
  }
}
