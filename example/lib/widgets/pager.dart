// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/model/demo_type.dart';
import 'package:zone/state/p.dart';

const _toRight = 80.0;
PageController? _controller;

class Pager extends ConsumerStatefulWidget {
  static final page = qs<double>(1.0);
  static final atMainPage = qs(true);
  static final childOpacity = qs(1.0);
  static final drawerOpacity = qs(.0);
  static final _newToRight = qs(80.0);
  static final _newController = qs<PageController?>(null);

  static FV toggle() async {
    final currentPage = Pager.page.q;
    final targetPage = currentPage == 0 ? 1 : 0;
    qqq("currentPage: $currentPage, targetPage: $targetPage");
    _CustomPageScrollPhysics.disableGaimon = true;
    HF.wait(20).then((_) {
      if (Platform.isAndroid) P.app.hapticLight();
      if (Platform.isIOS) P.app.hapticSoft();
    });
    await _controller!.animateToPage(targetPage, duration: 300.ms, curve: Curves.easeOutCubic);
    await Future.delayed(50.ms);
    _CustomPageScrollPhysics.disableGaimon = false;
  }

  final Widget child;
  final Widget drawer;
  final double drawerToRight;

  const Pager({
    super.key,
    required this.child,
    required this.drawer,
    this.drawerToRight = _toRight,
  });

  @override
  ConsumerState<Pager> createState() => _PagerState();
}

class _PagerState extends ConsumerState<Pager> {
  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged() async {
    final rawString = (_controller!.page ?? 0).toStringAsFixed(2);
    double v = double.tryParse(rawString) ?? .0;
    if (v > 1) v = 1;
    if (v < 0) v = 0;
    Pager.page.q = v;
    Pager.atMainPage.q = v == 1;
    Pager.childOpacity.q = v;
    Pager.drawerOpacity.q = 1 - v;
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

    final demoType = ref.watch(P.app.demoType);

    if (_controller == null || demoType == DemoType.sudoku || demoType == DemoType.fifthteenPuzzle || demoType == DemoType.othello) {
      _controller = PageController(viewportFraction: ((screenWidth - drawerToRight) / screenWidth), initialPage: 1);
      _controller!.addListener(_onPageChanged);
    }

    final ignorePointer = ref.watch(Pager.atMainPage);

    final recording = ref.watch(P.world.recording);

    return PopScope(
      canPop: ignorePointer,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: SingleChildScrollView(
          controller: _controller,
          physics: recording ? const NeverScrollableScrollPhysics() : const _CustomPageScrollPhysics(parent: ClampingScrollPhysics()),
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
        if (P.tts.focusNode.hasFocus) P.tts.dismissAllShown();
      }
    }
    return false;
  }
}

class _Dim extends ConsumerWidget {
  const _Dim();

  void _onTap() async {
    await Pager.toggle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final ignorePointer = ref.watch(Pager.atMainPage);
    final drawerOpacity = ref.watch(Pager.drawerOpacity);
    final kB = ref.watch(P.app.qb);

    return IgnorePointer(
      ignoring: ignorePointer,
      child: GD(
        onTap: _onTap,
        child: Opacity(
          opacity: drawerOpacity.clamp(0, 1),
          child: Material(
            color: kC,
            child: C(
              width: screenWidth,
              height: screenHeight,
              decoration: BD(color: kB.q(.3)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomPageScrollPhysics extends PageScrollPhysics {
  static int? _latestTargetPage;
  static bool disableGaimon = false;

  const _CustomPageScrollPhysics({super.parent});

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 3, // 质量，控制惯性
    stiffness: 400, // 刚度，控制弹簧力度
    damping: 2, // 阻尼，控制减速
  );

  // 获取目标页面索引
  int getTargetPage(ScrollMetrics position, double velocity) {
    final double pageSize = position.viewportDimension;
    final double currentPage = position.pixels / pageSize;

    // 根据速度和当前位置计算目标页面
    if (velocity.abs() >= minFlingVelocity) {
      // 如果有足够的甩动速度，则根据方向确定目标页
      return velocity > .0 ? currentPage.ceil() : currentPage.floor();
    } else {
      // 如果速度较小，则看当前位置是否超过一半决定目标页
      return (currentPage - currentPage.floor() >= .5) ? currentPage.ceil() : currentPage.floor();
    }
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (Platform.isAndroid) return super.createBallisticSimulation(position, velocity);

    // 在模拟开始前，可以计算并存储目标页面
    final targetPage = getTargetPage(position, velocity);

    if (_latestTargetPage != null && _latestTargetPage != targetPage) {
      if (!disableGaimon) P.app.hapticSoft();
    }

    _latestTargetPage = targetPage;

    // 您可以通过全局状态管理或回调将目标页面暴露给外部
    // 例如：Pager.targetPage.q = targetPage;

    // 返回原始模拟
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  PageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(parent: buildParent(ancestor));
  }
}
