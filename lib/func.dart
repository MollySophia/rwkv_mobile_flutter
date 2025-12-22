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
