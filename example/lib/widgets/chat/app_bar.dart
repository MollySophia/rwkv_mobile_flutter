// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:zone/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/arguments_panel.dart';

class ChatAppBar extends ConsumerWidget {
  const ChatAppBar({super.key});

  void _onTunePressed() async {
    final demoType = P.app.demoType.v;
    final loaded = P.rwkv.loaded.v;

    if (!loaded) {
      P.chat.showingModelSelector.u(false);
      P.chat.showingModelSelector.u(true);
      return;
    }
    await ArgumentsPanel.show(getContext()!);
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(P.rwkv.loaded);

    final demoType = ref.watch(P.app.demoType);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AppBar(
            backgroundColor: kW.wo(0.6),
            elevation: 0,
            centerTitle: true,
            title: AutoSizeText(
              "World RWKV",
              style: const TextStyle(fontSize: 20),
              minFontSize: 0,
              maxLines: 2,
            ),
            leading: Ro(
              children: [
                4.w,
                if (demoType == DemoType.chat)
                  IconButton(
                    onPressed: loaded
                        ? () {
                            P.chat.showingCharacterSelector.u(false);
                            P.chat.showingCharacterSelector.u(true);
                          }
                        : null,
                    icon: (Platform.isIOS || Platform.isMacOS) ? const Icon(CupertinoIcons.bubble_left_bubble_right) : const Icon(Icons.message_outlined),
                  ),
                if (demoType == DemoType.world)
                  IconButton(
                    onPressed: () {
                      P.chat.showingModelSelector.u(false);
                      P.chat.showingModelSelector.u(true);
                    },
                    icon: const Icon(CupertinoIcons.cube_box),
                  ),
              ],
            ),
            actions: [
              if (demoType == DemoType.chat)
                IconButton(
                  onPressed: () {
                    P.chat.showingModelSelector.u(false);
                    P.chat.showingModelSelector.u(true);
                  },
                  icon: const Icon(CupertinoIcons.cube_box),
                ),
              IconButton(
                onPressed: _onTunePressed,
                icon: const Icon(Icons.tune),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
