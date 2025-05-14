import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/state/p.dart';

class UserTtsContent extends ConsumerWidget {
  const UserTtsContent(this.msg, this.index, {super.key});

  final model.Message msg;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoType = ref.watch(P.app.demoType);
    if (demoType != DemoType.tts) return const SizedBox.shrink();
    final primary = Theme.of(context).colorScheme.primary;
    return Co(
      c: CAA.start,
      children: [
        C(
          decoration: BD(
            color: kW.q(.5),
            borderRadius: 10.r,
            border: Border.all(
              color: primary,
              width: .5,
            ),
          ),
          padding: const EI.s(h: 6, v: 4),
          child: Co(
            c: CAA.start,
            children: [
              if (msg.ttsSourceAudioPath != null) ...[
                T(S.current.according_to_the_following_audio_file),
                T(P.tts.flagChange(msg.ttsSourceAudioPath!.split("/").last).replaceAll("_", " ")),
              ],
              if (msg.ttsSpeakerName != null) ...[
                T("模仿 ${P.tts.safe(msg.ttsSpeakerName!)} 的声音"),
              ],
              if (msg.ttsSpeakerName == null && msg.ttsInstruction != null) ...[
                T(msg.ttsInstruction!),
              ],
              if (msg.ttsCFMSteps != null) ...[
                T("CFM Steps: ${msg.ttsCFMSteps!}"),
              ],
            ],
          ),
        ),
        4.h,
        T(
          msg.ttsTarget,
          s: const TS(s: 16),
        ),
      ],
    );
  }
}
