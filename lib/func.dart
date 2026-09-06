import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

extension CharPointer on String {
  /// Get the pointer to the native UTF-8 encoded string
  ///
  /// So we can send it to the native code
  ///
  /// Converts a [String] to a [Pointer<Char>]
  Pointer<Char> get ptr => toNativeUtf8().cast<Char>();
}

/// Native diagnostic entries may end partway through a UTF-8 character.
/// A truncated log must not terminate the inference isolate.
String readRuntimeLog(Pointer<Char> log) => utf8.decode(
  log.cast<Uint8>().asTypedList(log.cast<Utf8>().length),
  allowMalformed: true,
);
