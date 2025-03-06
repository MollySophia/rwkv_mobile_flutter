import 'dart:io';
import 'package:crypto/crypto.dart';

/// 通过流式读取文件，计算其 SHA256 值
Future<String> calculateFileSha256(String filePath) async {
  final file = File(filePath);
  // 打开文件流，并通过 sha256 的 bind 方法进行处理
  final digest = await md5.bind(file.openRead()).first;
  return digest.toString();
}
