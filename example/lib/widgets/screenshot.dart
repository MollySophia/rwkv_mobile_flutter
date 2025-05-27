import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:zone/page/chat.dart' show keyChatList;
import 'package:zone/state/p.dart' show P;

void startScrollShot(GlobalKey key) async {
  final state = key.currentState as _ScrollShotAreaState;
  state.shot();
}

class ScrollShotArea extends ConsumerStatefulWidget {
  final Widget child;
  final ScrollController controller;

  const ScrollShotArea({super.key, required this.child, required this.controller});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScrollShotAreaState();
}

final _keyScreenshot = GlobalKey<_ScreenshotState>();

class _ScrollShotAreaState extends ConsumerState<ScrollShotArea> {
  void shot() async {
    _keyScreenshot.currentState!.startScreenshot(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      ),
    );
  }
}

class Screenshot extends ConsumerStatefulWidget {
  final Widget child;

  Screenshot({required this.child}) : super(key: _keyScreenshot);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenshotState();
}

class _ScreenshotState extends ConsumerState<Screenshot> {
  double pixelRatio = 3.0;

  double scrollOffsetStep = 300.0;
  bool isShowShotOverlay = false;
  bool scrolling = false;
  double maxScrollPosition = 0;
  ScrollController? scrollController;
  double lastScrollOffset = 0;
  Size scrollAreaSize = Size.zero;

  ui.Image? imagePreview;
  List<ui.Image> imageSegments = [];

  ui.Image? imageFooter;

  double headerHeight = 0;
  double footerHeight = 0;

  final _keyAppBoundary = GlobalKey();

  void startScreenshot(ScrollController controller) async {
    scrolling = false;
    scrollAreaSize = keyChatList.currentContext!.size!;

    scrollOffsetStep = scrollAreaSize.height / 3;
    pixelRatio = MediaQuery.of(context).devicePixelRatio;

    headerHeight = (P.app.paddingTop.q + kToolbarHeight) * pixelRatio;
    footerHeight = P.chat.inputHeight.q * pixelRatio;

    scrollController = controller;
    maxScrollPosition = controller.position.maxScrollExtent;
    setState(() {
      isShowShotOverlay = true;
    });

    lastScrollOffset = scrollAreaSize.height;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _shotHeaderAndFooter();
      _shot();
    });
  }

  Future _shotHeaderAndFooter() async {
    final boundary = _keyAppBoundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    final toolbar = await _cropImage(
      image,
      Rect.fromLTWH(0, 0, scrollAreaSize.width * pixelRatio, headerHeight),
    );
    imageSegments.add(toolbar);
    imageFooter = await _cropImage(
      image,
      Rect.fromLTWH(
        0,
        scrollAreaSize.height * pixelRatio - footerHeight,
        scrollAreaSize.width * pixelRatio,
        footerHeight,
      ),
    );
  }

  void _onScrollTap() async {
    if (scrollController == null || scrolling) return;
    final current = scrollController!.position.pixels;
    if (current <= 0) {
      return;
    }

    qqq('current: $current, max: $maxScrollPosition');
    scrolling = true;
    final offset = max(current - scrollOffsetStep, 0.0);
    await scrollController!.animateTo(
      offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
    await Future.delayed(const Duration(milliseconds: 50));
    lastScrollOffset = min(scrollOffsetStep, current);
    await _shot();
    scrolling = false;
  }

  Future _shot() async {
    RenderRepaintBoundary boundary = keyChatList.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    double top = scrollAreaSize.height - lastScrollOffset;
    final cropRect = Rect.fromLTWH(
      0,
      top * pixelRatio,
      scrollAreaSize.width * pixelRatio,
      lastScrollOffset * pixelRatio,
    );

    image = await _cropImage(image, cropRect);
    imageSegments.add(image);

    await _generatePreview();
  }

  Future<ui.Image> _cropImage(ui.Image img, Rect crop) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      img,
      crop,
      Rect.fromLTRB(0, 0, crop.width, crop.height),
      Paint()..filterQuality = FilterQuality.high,
    );
    final picture = recorder.endRecording();
    return await picture.toImage(
      crop.width.toInt(),
      crop.height.toInt(),
    );
  }

  Future _saveImage(ui.Image img, String name) async {
    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final file = File("/storage/emulated/0/Download/$name");
    if (await file.exists()) await file.delete();
    await file.create();
    await file.writeAsBytes(bytes);
    qqq('file saved: $name');
  }

  Future _generatePreview() async {
    if (imageSegments.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    double offsetY = 0;
    final paint = Paint()..filterQuality = FilterQuality.high;
    for (final img in imageSegments) {
      canvas.drawImage(img, Offset(0, offsetY), paint);
      offsetY += img.height;
    }

    if (imageFooter != null) {
      canvas.drawImage(imageFooter!, Offset(0, offsetY), paint);
      offsetY += imageFooter!.height;
    }

    imagePreview = await recorder.endRecording().toImage(
      imageSegments[0].width,
      offsetY.toInt(),
    );

    setState(() {});
  }

  void _onSaveTap() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _saveImage(imagePreview!, '$timestamp-preview.png');
    _reset();
  }

  void _onShareTap() async {
    _reset();
  }

  void _reset() {
    for (final img in imageSegments) {
      img.dispose();
    }
    imageFooter?.dispose();
    imagePreview?.dispose();
    imageSegments.clear();
    setState(() {
      imageFooter = null;
      imagePreview = null;
      lastScrollOffset = 0;
      isShowShotOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isShowShotOverlay) {
      return widget.child;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: _keyAppBoundary,
          child: widget.child,
        ),
        _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Material(
      color: Colors.black12,
      child: Stack(
        children: [
          _buildPreview(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (imagePreview == null) return const SizedBox();
    final r = imagePreview!.width / 80;
    final height = imagePreview!.height / r;
    return Positioned(
      bottom: 140,
      left: 16,
      width: 80,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(2, 4),
              blurRadius: 6,
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: _PreviewPaint(imagePreview!),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 140,
      right: 16,
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              mini: true,
              onPressed: _onScrollTap,
              child: const Icon(Icons.keyboard_double_arrow_down),
            ),
            6.h,
            FloatingActionButton(
              mini: true,
              onPressed: _onSaveTap,
              child: const Icon(Icons.save_alt_outlined),
            ),
            6.h,
            FloatingActionButton(
              mini: true,
              onPressed: _onShareTap,
              child: const Icon(Icons.share_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPaint extends CustomPainter {
  final ui.Image image;
  final Paint _paint = Paint();

  _PreviewPaint(this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final src = Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final dst = Offset.zero & size;
    canvas.drawImageRect(image, src, dst, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
