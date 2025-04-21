import 'dart:io';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:halo/halo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> fromAssetsToTemp(String assetsPath, {String? targetPath}) async {
  try {
    final startTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final data = await rootBundle.load(assetsPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(path.join(tempDir.path, targetPath ?? assetsPath));
    await tempFile.create(recursive: true);
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    final endTimeStamp = DateTime.now().millisecondsSinceEpoch;
    qqw("从assets到temp的时间: ${endTimeStamp - startTimeStamp}ms");
    return tempFile.path;
  } catch (e) {
    qqe("$e");
    return "";
  }
}
