// ignore: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/branch_switcher.dart';

class UserMessageBottom extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const UserMessageBottom(this.msg, this.index, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!msg.isMine) return const SizedBox.shrink();
    final isUserImage = msg.type == model.MessageType.userImage;
    final isUserAudio = msg.type == model.MessageType.userAudio;

    if (isUserImage || isUserAudio) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final worldType = ref.watch(P.rwkv.currentWorldType);

    bool showUserEditButton = false;
    bool showUserCopyButton = false;

    switch (worldType) {
      case null:
        switch (msg.type) {
          case model.MessageType.text:
          case model.MessageType.userImage:
          case model.MessageType.userAudio:
            showUserEditButton = true;
            showUserCopyButton = true;
          case model.MessageType.userTTS:
          case model.MessageType.ttsGeneration:
            showUserEditButton = false;
            showUserCopyButton = true;
        }

      default:
        showUserEditButton = false;
        showUserCopyButton = false;
    }

    return Ro(
      m: MAA.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showUserEditButton)
          GD(
            onTap: _onUserEditPressed,
            child: Padding(
              padding: const EI.o(v: 12, l: 4, r: 4),
              child: Icon(
                Icons.edit,
                color: primaryColor.wo(0.8),
                size: 20,
              ),
            ),
          ),
        if (showUserCopyButton)
          GD(
            onTap: _onCopyPressed,
            child: Padding(
              padding: const EI.o(v: 12, l: 4, r: 4),
              child: Icon(
                Icons.copy,
                color: primaryColor.wo(0.8),
                size: 20,
              ),
            ),
          ),
        BranchSwitcher(msg, index),
      ],
    );
  }

  void _onUserEditPressed() async {
    await P.chat.onTapEditInUserMessageBubble(index: index);
  }

  void _onCopyPressed() {
    Alert.success(S.current.chat_copied_to_clipboard);
    Clipboard.setData(ClipboardData(text: msg.content));
  }
}
