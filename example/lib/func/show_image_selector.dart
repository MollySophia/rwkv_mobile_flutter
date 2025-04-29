import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:halo/halo.dart';
import 'package:halo_state/halo_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zone/model/message.dart';
import 'package:zone/route/router.dart';
import 'package:zone/state/p.dart';

Future<void> showImageSelector() async {
  qq;
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
      const SheetAction(
        label: "Take photo",
        icon: Icons.camera,
        key: "take_photo",
      ),
      const SheetAction(
        label: "Select from library",
        icon: Icons.photo,
        key: "select_from_library",
      ),
    ],
  );
  qqq("result: $result");
  if (result == null) return;
  final ImagePicker picker = ImagePicker();
  late final XFile? image;
  if (result == "take_photo") {
    image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imagePath = image.path;
    qqq("imagePath: $imagePath");
  } else if (result == "select_from_library") {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imagePath = image.path;
    qqq("imagePath: $imagePath");
  } else {
    throw Exception("Invalid result: $result");
  }
  P.world.imagePath.q = image.path;
  P.chat.clearMessages();
  P.rwkv.clearStates();
  P.rwkv.setImagePath(path: image.path);
  P.chat.send("", type: MessageType.userImage, imageUrl: image.path);
}
