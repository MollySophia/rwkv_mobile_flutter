import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> getModelPath(String assetsPath) async {
  try {
    final data = await rootBundle.load(assetsPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(path.join(tempDir.path, assetsPath));
    await tempFile.create(recursive: true);
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    return tempFile.path;
  } catch (e) {
    if (kDebugMode) print("😡 $e");
    return "";
  }
}
