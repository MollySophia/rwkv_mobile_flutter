// ignore: unused_import
import 'dart:developer';

import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/model/message.dart' as model;
import 'package:zone/model/role.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';
import 'package:zone/widgets/chat/app_bar.dart';
import 'package:zone/widgets/chat/audio_empty.dart';
import 'package:zone/widgets/chat/audio_input.dart';
import 'package:zone/widgets/chat/empty.dart';
import 'package:zone/widgets/chat/input.dart';
import 'package:zone/widgets/chat/message.dart';
import 'package:zone/widgets/chat/suggestions.dart';
import 'package:zone/widgets/chat/visual_empty.dart';
import 'package:zone/widgets/model_selector.dart';

class Pager extends ConsumerStatefulWidget {
  final Widget child;
  final Widget drawer;
  final double drawerToRight;

  const Pager({super.key, required this.child, required this.drawer, this.drawerToRight = 100});

  @override
  ConsumerState<Pager> createState() => _PagerState();
}

class _PagerState extends ConsumerState<Pager> {
  PageController? _controller;

  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged() {
    print(_controller!.page);
  }

  @override
  Widget build(BuildContext context) {
    final drawerToRight = widget.drawerToRight;
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    if (screenWidth == 0) return SB();

    if (_controller == null) {
      _controller = PageController(viewportFraction: ((screenWidth - 100) / screenWidth), initialPage: 1);
      _controller!.addListener(_onPageChanged);
    }

    return SingleChildScrollView(
      controller: _controller,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SB(
        width: screenWidth * 2 - drawerToRight,
        height: screenHeight,
        child: Ro(
          children: [
            SB(
              width: screenWidth - drawerToRight,
              height: screenHeight,
              child: widget.drawer,
            ),
            Stack(
              children: [
                _Dim(),
                SB(
                  width: screenWidth,
                  height: screenHeight,
                  child: widget.child,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dim extends ConsumerWidget {
  const _Dim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SB();
  }
}
