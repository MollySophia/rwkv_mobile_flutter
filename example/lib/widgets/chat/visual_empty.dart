// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zone/func/log_trace.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';

class VisualEmpty extends ConsumerWidget {
  const VisualEmpty({super.key});

  void _onTapImageSelector() async {
    logTrace();
    if (P.chat.focusNode.hasFocus) {
      P.chat.focusNode.unfocus();
      return;
    }
    final result = await showModalActionSheet(
      context: getContext()!,
      title: "Select image",
      message: "Please select an image from the following options",
      cancelLabel: "Cancel",
      actions: [
        SheetAction(
          label: "Take photo",
          icon: Icons.camera,
          key: "take_photo",
        ),
        SheetAction(
          label: "Select from library",
          icon: Icons.photo,
          key: "select_from_library",
        ),
      ],
    );
    if (kDebugMode) print("💬 result: $result");
    if (result == null) return;
    final ImagePicker picker = ImagePicker();
    late final XFile? image;
    if (result == "take_photo") {
      image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imagePath = image.path;
      if (kDebugMode) print("💬 imagePath: $imagePath");
    } else if (result == "select_from_library") {
      image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imagePath = image.path;
      if (kDebugMode) print("💬 imagePath: $imagePath");
    } else {
      throw Exception("Invalid result: $result");
    }
    P.world.imagePath.u(image.path);
    P.rwkv.setImagePath(path: image.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = ref.watch(P.app.screenWidth);
    final screenHeight = ref.watch(P.app.screenHeight);
    final paddingTop = ref.watch(P.app.paddingTop);
    final paddingBottom = ref.watch(P.app.paddingBottom);
    final inputHeight = ref.watch(P.chat.inputHeight);
    final maxW = screenWidth;
    final maxH = screenHeight - paddingTop - kToolbarHeight - inputHeight;
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;
    final imagePath = ref.watch(P.world.imagePath);

    return AnimatedPositioned(
      duration: 350.ms,
      curve: Curves.easeInOutBack,
      bottom: inputHeight,
      left: 0,
      width: screenWidth,
      top: paddingTop + kToolbarHeight,
      child: Co(
        c: CAA.center,
        m: MAA.center,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: 12.r,
              child: GD(
                onTap: _onTapImageSelector,
                child: C(
                  decoration: BD(
                    color: primaryColor,
                    borderRadius: 12.r,
                  ),
                  width: math.min(maxW, maxH) - 16,
                  height: math.min(maxW, maxH) * 0.75,
                  child: imagePath == null
                      ? Co(
                          c: CAA.center,
                          m: MAA.center,
                          children: [
                            Icon(Icons.image),
                            T("Click to load image"),
                            T("Then you can start to chat with RWKV"),
                          ],
                        )
                      : Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
