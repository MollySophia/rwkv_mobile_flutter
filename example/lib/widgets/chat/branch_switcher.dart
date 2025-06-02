// ignore: unused_import

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
    return const SizedBox.shrink();
  }
}
