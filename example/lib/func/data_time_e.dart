import 'package:flutter/foundation.dart';

int get qDebugShorterMicroseconds {
  return kDebugMode ? DateTime.now().microsecondsSinceEpoch - 1744263000000000 : DateTime.now().millisecondsSinceEpoch;
}

int get qDebugShorterMilliseconds {
  return kDebugMode ? DateTime.now().millisecondsSinceEpoch - 1744263000000 : DateTime.now().microsecondsSinceEpoch;
}
