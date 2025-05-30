// ignore: unused_import

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/func/show_image_selector.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/thinking_mode.dart' as thinking_mode;
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/reasoning_option_button.dart';
import 'package:zone/widgets/performance_info.dart';
import 'package:halo_state/halo_state.dart';

class BottomInteractions extends ConsumerWidget {
  const BottomInteractions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.primary;
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final demoType = ref.watch(P.app.demoType);
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final reasoning = ref.watch(P.rwkv.reasoning);
    final s = S.of(context);
    final kB = ref.watch(P.app.qb);

    return Padding(
      padding: const EI.o(t: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          qqr(width);
          return Ro(
            m: MAA.spaceBetween,
            children: [
              Expanded(child: const _Interactions()),
              const _MessageButton(),
            ],
          );
        },
      ),
    );
  }
}

class _Interactions extends ConsumerWidget {
  const _Interactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorldType = ref.watch(P.rwkv.currentWorldType);
    final thinkingMode = ref.watch(P.rwkv.thinkingMode);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (currentWorldType?.isVisualDemo == true) const IntrinsicWidth(child: _SelectImageButton()),
        const _ThinkingModeButton(),
        const _SecondaryOptionsButton(),
        const IntrinsicWidth(child: PerformanceInfo()),
      ],
    );
  }
}

class _ThinkingModeButton extends ConsumerWidget {
  const _ThinkingModeButton();

  void _onTap() {
    // TODO: finish this
    P.rwkv.setModelConfig();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final preferChinese = ref.watch(P.rwkv.preferChinese);
    final preferPseudo = ref.watch(P.rwkv.preferPseudo);
    final loading = ref.watch(P.rwkv.loading);
    final qw = ref.watch(P.app.qw);
    final kB = ref.watch(P.app.qb);

    final thinkingMode = ref.watch(P.rwkv.thinkingMode);

    final color = switch (thinkingMode) {
      thinking_mode.Lighting() => kC,
      thinking_mode.Free() => primary,
      thinking_mode.PreferChinese() => primary,
      thinking_mode.None() => kC,
    };

    final borderColor = switch (thinkingMode) {
      thinking_mode.Lighting() => primary.q(.33),
      thinking_mode.Free() => primary.q(.5),
      thinking_mode.PreferChinese() => primary.q(.5),
      thinking_mode.None() => primary.q(.5),
    };

    final textColor = switch (thinkingMode) {
      thinking_mode.Lighting() => primary.q(.5),
      thinking_mode.Free() => primary,
      thinking_mode.PreferChinese() => primary,
      thinking_mode.None() => kC,
    };

    return IntrinsicWidth(
      child: AnimatedOpacity(
        opacity: loading ? .33 : 1,
        duration: 250.ms,
        child: GD(
          onTap: _onTap,
          child: C(
            decoration: BD(
              color: color,
              border: Border.all(color: borderColor),
              borderRadius: 10.r,
            ),
            padding: const EI.o(l: 8, r: 8, t: 9, b: 9),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: textColor, size: 14),
                2.w,
                T(
                  s.reason,
                  s: TS(c: textColor, s: 14, height: 1, w: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryOptionsButton extends ConsumerWidget {
  const _SecondaryOptionsButton();

  void _onTap() {
    // TODO: finish this
    P.rwkv.setModelConfig();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final loading = ref.watch(P.rwkv.loading);

    final thinkingMode = ref.watch(P.rwkv.thinkingMode);

    final color = switch (thinkingMode) {
      thinking_mode.Lighting() => kC,
      thinking_mode.Free() => primary,
      thinking_mode.PreferChinese() => primary,
      thinking_mode.None() => kC,
    };

    final borderColor = switch (thinkingMode) {
      thinking_mode.Lighting() => primary.q(.33),
      thinking_mode.Free() => primary.q(.5),
      thinking_mode.PreferChinese() => primary.q(.5),
      thinking_mode.None() => primary.q(.5),
    };

    final textColor = switch (thinkingMode) {
      thinking_mode.Lighting() => primary.q(.5),
      thinking_mode.Free() => primary,
      thinking_mode.PreferChinese() => primary,
      thinking_mode.None() => kC,
    };

    final Widget iconWidget = switch (thinkingMode) {
      // thinking_mode.Lighting() => Icon(Icons.lightbulb_outline, color: textColor, size: 14),
      // thinking_mode.Free() => Icon(Icons.lightbulb_outline, color: textColor, size: 14),
      // thinking_mode.PreferChinese() => Icon(Icons.translate, color: textColor, size: 14),
      thinking_mode.None() => ZZZIcon(color: textColor),
      _ => ZZZIcon(color: textColor),
    };

    return IntrinsicWidth(
      child: AnimatedOpacity(
        opacity: loading ? .33 : 1,
        duration: 250.ms,
        child: GD(
          onTap: _onTap,
          child: C(
            decoration: BD(
              color: color,
              border: Border.all(color: borderColor),
              borderRadius: 10.r,
            ),
            padding: const EI.o(l: 8, r: 8, t: 7, b: 7),
            child: Row(
              children: [
                iconWidget,
                2.w,
                T(
                  s.reason,
                  s: TS(c: textColor, s: 14, height: 1, w: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectImageButton extends ConsumerWidget {
  const _SelectImageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final s = S.of(context);
    return GD(
      onTap: () async {
        await showImageSelector();
      },
      child: C(
        decoration: BD(
          color: primaryContainer,
          border: Border.all(
            color: color.q(.5),
          ),
          borderRadius: 12.r,
        ),
        padding: const EI.o(l: 8, r: 8, t: 8, b: 8),
        child: T(
          s.select_new_image,
          s: TS(c: color),
        ),
      ),
    );
  }
}

class _MessageButton extends ConsumerWidget {
  const _MessageButton();

  void _onRightButtonPressed() async {
    qq;

    final currentWorldType = P.rwkv.currentWorldType.q;
    final imagePath = P.world.imagePath.q;

    if (currentWorldType != null && imagePath == null) {
      await showImageSelector();
      Alert.info(S.current.please_load_model_first);
      return;
    }

    await P.chat.onInputRightButtonPressed();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiving = ref.watch(P.chat.receivingTokens);
    final canSend = ref.watch(P.chat.canSend);
    final editingBotMessage = ref.watch(P.chat.editingBotMessage);
    final color = Theme.of(context).colorScheme.primary;

    if (!receiving) {
      return AnimatedOpacity(
        opacity: canSend ? 1 : .333,
        duration: 250.ms,
        child: GD(
          onTap: _onRightButtonPressed,
          child: C(
            padding: const EI.s(h: 10, v: 5),
            child: Icon(
              (Platform.isIOS || Platform.isMacOS)
                  ? editingBotMessage
                        ? CupertinoIcons.pencil_circle_fill
                        : CupertinoIcons.arrow_up_circle_fill
                  : editingBotMessage
                  ? Icons.edit
                  : Icons.send,
              color: color,
            ),
          ),
        ),
      );
    }

    return GD(
      onTap: P.chat.onStopButtonPressed,
      child: C(
        decoration: const BD(color: kC),
        child: Stack(
          children: [
            SizedBox(
              width: 46,
              height: 34,
              child: Center(
                child: C(
                  decoration: BD(color: color, borderRadius: 2.r),
                  width: 12,
                  height: 12,
                ),
              ),
            ),
            SB(
              width: 46,
              height: 34,
              child: Center(
                child: SB(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: color.q(.5),
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZZZIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ZZZIcon({
    super.key,
    required this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ZZZPainter(color: color),
      ),
    );
  }
}

class ZZZPainter extends CustomPainter {
  final Color color;

  ZZZPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 绘制三个 Z，顶部最大，底部最小，纵向间距加大
    final z1 = Path()
      ..moveTo(1, 2)
      ..lineTo(7, 2)
      ..lineTo(1, 6)
      ..lineTo(7, 6);

    final z2 = Path()
      ..moveTo(5, 8)
      ..lineTo(11, 8)
      ..lineTo(5, 12)
      ..lineTo(11, 12);

    final z3 = Path()
      ..moveTo(9, 14)
      ..lineTo(13, 14)
      ..lineTo(9, 17)
      ..lineTo(13, 17);

    canvas.drawPath(z1, paint);
    canvas.drawPath(z2, paint);
    canvas.drawPath(z3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
