// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/state/p.dart';

const _toRight = 80.0;
PageController? _controller;
final _reverse = true;

class Pager extends ConsumerStatefulWidget {
  final Widget child;
  final Widget drawer;
  final double drawerToRight;

  const Pager({super.key, required this.child, required this.drawer, this.drawerToRight = _toRight});

  @override
  ConsumerState<Pager> createState() => _PagerState();

  static final page = qs<double>(_reverse ? 0 : 1);
  static final mainPageNotIgnoring = qs(true);
  static final childOpacity = qs(1.0);
  static final drawerOpacity = qs(0.0);

  static FV toggle() async {
    if (page.v == 1) {
      await _controller!.animateToPage(_reverse ? 0 : 1, duration: 300.ms, curve: Curves.easeOutCubic);
    } else {
      await _controller!.animateToPage(_reverse ? 1 : 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }
  }
}

class _PagerState extends ConsumerState<Pager> {
  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged() async {
    final rawString = (_controller!.page ?? 0).toStringAsFixed(2);
    final v = double.tryParse(rawString) ?? 0.0;
    Pager.page.u(v);
    Pager.mainPageNotIgnoring.u(v == 1);
    Pager.childOpacity.u(v);
    Pager.drawerOpacity.u(1 - v);
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) async {
    qqq("didPop: $didPop, result: $result");
    await _controller!.animateToPage(1, duration: 200.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final drawerToRight = widget.drawerToRight;
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    if (screenWidth == 0) return const SB();

    if (_controller == null) {
      _controller = PageController(viewportFraction: ((screenWidth - drawerToRight) / screenWidth), initialPage: 1);
      _controller!.addListener(_onPageChanged);
    }

    final ignorePointer = ref.watch(Pager.mainPageNotIgnoring);

    return PopScope(
      canPop: ignorePointer,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: SingleChildScrollView(
          controller: _controller,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
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
                    SB(
                      width: screenWidth,
                      height: screenHeight,
                      child: widget.child,
                    ),
                    const _Dim(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _onNotification(notification) {
    if (notification is ScrollStartNotification) {
      if (notification.depth == 0) {
        if (P.chat.focusNode.hasFocus) P.chat.focusNode.unfocus();
      }
    }
    return false;
  }
}

class _Dim extends ConsumerWidget {
  const _Dim();

  void _onTap() {
    qqq("tap");
    _controller!.animateToPage(1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final ignorePointer = ref.watch(Pager.mainPageNotIgnoring);
    final drawerOpacity = ref.watch(Pager.drawerOpacity);

    return IgnorePointer(
      ignoring: ignorePointer,
      child: GD(
        onTap: _onTap,
        child: Opacity(
          opacity: drawerOpacity,
          child: Material(
            color: kC,
            child: C(
              width: screenWidth,
              height: screenHeight,
              decoration: BD(color: kB.wo(0.3)),
            ),
          ),
        ),
      ),
    );
  }
}
