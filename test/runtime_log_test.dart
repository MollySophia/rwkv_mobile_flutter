import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwkv_mobile_flutter/func.dart';

void main() {
  test('reads Chinese and emoji logs truncated inside a character', () {
    final cases = <(List<int>, String)>[
      ([], ''),
      ([0xe4], '\ufffd'),
      ([0xe4, 0xb8], '\ufffd'),
      ([0xe4, 0xb8, 0xad], '中'),
      ([0xe4, 0xb8, 0xad, 0xf0, 0x9f, 0x98], '中\ufffd'),
      ([0xf0, 0x9f, 0x99, 0x82], '🙂'),
      ([0x4f, 0x4b], 'OK'),
    ];
    for (final (bytes, expected) in cases) {
      final pointer = calloc<Uint8>(bytes.length + 1);
      try {
        pointer.asTypedList(bytes.length).setAll(0, bytes);
        expect(readRuntimeLog(pointer.cast<Char>()), expected);
      } finally {
        calloc.free(pointer);
      }
    }
  });
}
