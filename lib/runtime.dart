// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'dart:developer';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkv_mobile_flutter/types.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

// TODO: Finish this class
abstract final class RWKV {
  static late Isolate? _isolate;
  static late rwkv_mobile _lib;
  static final _receivePort = ReceivePort();
  static SendPort? _sendPort;

  static String get availableBackendNames {
    const backendNamesLength = 64; // should be enough
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(backendNamesLength);
    _lib.rwkvmobile_runtime_get_available_backend_names(responseBuffer, backendNamesLength);
    final response = responseBuffer.cast<Utf8>().toDartString();
    return response;
  }

  static String get platformName {
    final platformName = _lib.rwkvmobile_get_platform_name();
    return platformName.cast<Utf8>().toDartString();
  }

  static String get socName {
    final socName = _lib.rwkvmobile_get_soc_name();
    return socName.cast<Utf8>().toDartString();
  }

  static String get socPartname {
    final socPartname = _lib.rwkvmobile_get_soc_partname();
    return socPartname.cast<Utf8>().toDartString();
  }

  static Future<void> init() async {
    final rootIsolateToken = RootIsolateToken.instance;
    _receivePort.listen(_onMessageFromRWKVIsolate);
    _isolate = await Isolate.spawn(_main, [
      _receivePort.sendPort,
      rootIsolateToken,
    ]);
  }

  static void _main(List<Object?> args) {
    final sendPort = args[0] as SendPort;
    final rootIsolateToken = args[1] as RootIsolateToken;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    _lib = rwkv_mobile(_getDynamicLibrary());
  }

  static ffi.DynamicLibrary _getDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('librwkv_mobile.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    } else if (Platform.isLinux) {
      final abi = ffi.Abi.current();
      if (abi == ffi.Abi.linuxX64) {
        return ffi.DynamicLibrary.open('librwkv_mobile-linux-x86_64.so');
      } else if (abi == ffi.Abi.linuxArm64) {
        return ffi.DynamicLibrary.open('librwkv_mobile-linux-aarch64.so');
      } else {
        throw Exception('😡 Unsupported ABI: ${abi.toString()}');
      }
    } else {
      throw Exception('😡 Unsupported platform');
    }
  }

  static Future<void> send(ToRWKV command, [Object? arg]) async {
    _receivePort.sendPort.send((command, arg));
  }

  static void _send(FromRWKV command, [Object? arg]) {
    _sendPort?.send((command, arg));
  }

  static void _onMessageFromRWKVIsolate(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      return;
    }
  }
}
