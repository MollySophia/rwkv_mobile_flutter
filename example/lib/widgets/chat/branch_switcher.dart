// ignore: unused_import

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/state/p.dart';

class BranchSwitcher extends ConsumerWidget {
  final model.Message msg;
  final int index;

  const BranchSwitcher(this.msg, this.index, {super.key});

  void _onBackPressed() {
    P.chat.onTapSwitchAtIndex(index, isBack: true, msg: msg);
  }

  void _onForwardPressed() {
    P.chat.onTapSwitchAtIndex(index, isBack: false, msg: msg);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 分叉
    final branches = [];
    if (branches.length <= 1) return const SizedBox.shrink();
    final primary = Theme.of(context).colorScheme.primary;
    final indexInBranches = branches.indexOf(msg.id);
    final isFirst = indexInBranches == 0;
    final isLast = indexInBranches == branches.length - 1;

    qqq("message: $msg, index: $index");
    return C(
      decoration: BD(color: primary.wo(0.0)),
      child: Stack(
        children: [
          Ro(
            children: [
              44.h,
              Icon(CupertinoIcons.chevron_back, color: primary.wo(isFirst ? 0.4 : 0.8)),
              T(
                "${indexInBranches + 1} / ${branches.length}",
                s: TS(c: primary.wo(0.8), w: FW.w600),
              ),
              Icon(CupertinoIcons.chevron_forward, color: primary.wo(isLast ? 0.4 : 0.8)),
            ],
          ),
          Positioned.fill(
            child: Ro(
              children: [
                Exp(
                  child: GD(
                    onTap: isFirst ? null : _onBackPressed,
                    child: C(decoration: BD(color: kDebugMode ? kCR.wo(0.1) : kC)),
                  ),
                ),
                Exp(
                  child: GD(
                    onTap: isLast ? null : _onForwardPressed,
                    child: C(decoration: BD(color: kDebugMode ? kCB.wo(0.1) : kC)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
