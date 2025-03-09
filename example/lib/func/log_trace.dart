// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

void logTrace([dynamic message]) {
  if (!kDebugMode) return;
  final member = Trace.current().frames[1].member;
  if (message == null) {
    print("💬 $member");
    return;
  }
  print("💬 $member $message");
}

@Deprecated("建议直接 throw 错误")
void errorTrace([dynamic message]) {
  if (!kDebugMode) return;
  final member = Trace.current().frames[1].member;
  if (message == null) {
    print("😡 $member");
    return;
  }
  print("😡 $member $message");
}
