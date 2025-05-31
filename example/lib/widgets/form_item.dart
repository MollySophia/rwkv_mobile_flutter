import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

class FormItem extends ConsumerWidget {
  final bool isSectionStart;
  final bool isSectionEnd;
  final bool autoShowBottomBorder;
  final String title;
  final String? info;
  final VoidCallback? onTap;
  final bool showArrow;
  final TextAlign? titleTextAlign;
  final Widget? icon;
  final Color? titleColor;
  final String? subtitle;

  final Widget? trailing;

  const FormItem({
    super.key,
    required this.title,
    this.onTap,
    this.isSectionStart = false,
    this.isSectionEnd = false,
    this.info,
    this.icon,
    this.showArrow = true,
    this.autoShowBottomBorder = true,
    this.titleTextAlign,
    this.titleColor,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kB = ref.watch(P.app.qb);
    final qc = ref.watch(P.app.light) ? const Color(0xFFFFFFFF) : const Color(0xFF121212);

    return GD(
      onTap: onTap,
      child: C(
        decoration: BD(
          color: qc,
          borderRadius: BorderRadius.only(
            topLeft: isSectionStart ? 12.rr : Radius.zero,
            topRight: isSectionStart ? 12.rr : Radius.zero,
            bottomLeft: isSectionEnd ? 12.rr : Radius.zero,
            bottomRight: isSectionEnd ? 12.rr : Radius.zero,
          ),
          border: Border(
            bottom: (autoShowBottomBorder && !isSectionEnd)
                ? BorderSide(
                    color: kB.q(.1),
                    width: .5,
                  )
                : BorderSide.none,
          ),
        ),
        padding: const EI.o(t: 12, b: 12, r: 8, l: 8),
        child: Row(
          children: [
            if (icon != null) icon!,
            if (icon != null) 8.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CAA.start,
                children: [
                  T(
                    title,
                    textAlign: titleTextAlign,
                    s: TS(w: FW.w500, s: 16, c: titleColor ?? kB),
                  ),
                  if (subtitle != null)
                    T(
                      subtitle!,
                      s: TS(w: FW.w500, s: 12, c: kB.q(.6)),
                    ),
                ],
              ),
            ),
            if (info != null) 8.w,
            if (info != null)
              Expanded(
                child: T(
                  info,
                  s: TS(w: FW.w500, s: 12, c: kB.q(.6)),
                  textAlign: TextAlign.right,
                ),
              ),
            if (!showArrow && info != null) 4.w,
            ?trailing,
            if (showArrow) 8.w,
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: kB.q(.4),
              ),
          ],
        ),
      ),
    );
  }
}
