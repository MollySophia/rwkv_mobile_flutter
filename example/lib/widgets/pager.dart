// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:zone/state/p.dart';

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
    if (screenWidth == 0) return const SB();

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
                const _Dim(),
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
    return const SB();
  }
}
