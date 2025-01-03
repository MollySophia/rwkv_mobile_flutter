library rwkv_mobile_flutter;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_ffi.dart';

class RWKVMobile {
  Isolate? _isolate;

  Future runIsolate(String modelPath, String tokenizerPath, String backendName, SendPort sendPort, RootIsolateToken rootIsolateToken) async {
    if (_isolate != null) {
      throw Exception('Isolate already running');
    }

    _isolate = await Isolate.spawn(isolateMain, (sendPort, rootIsolateToken, modelPath, backendName, tokenizerPath));
  }

  bool get isRunning => _isolate != null;

  ffi.DynamicLibrary getDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('librwkv_mobile.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dylib');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('librwkv_mobile.dll');
    } else {
      throw Exception('Unsupported platform');
    }
  }

  // TODO: rwkv_mobile has this function, but it's not exported yet
  String getAvailableBackendNames() {
    // final _dylib = getDynamicLibrary();
    // final rwkvMobile = rwkv_mobile(_dylib);
    return "";
  }

  static callbackFunction(ffi.Pointer<ffi.Char> responseBuffer) {
    final response = responseBuffer.cast<Utf8>().toDartString();
    if (kDebugMode) print("💬 streamResponse: $response");
  }

  void isolateMain(options) async {
    final sendPort = options.$1 as SendPort;
    final rootIsolateToken = options.$2 as RootIsolateToken;
    final modelPath = options.$3 as String;
    final modelBackend = options.$4 as String;
    final tokenizerPath = options.$5 as String;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final rwkvMobile = rwkv_mobile(getDynamicLibrary());
    final modelPathPointer = modelPath.toNativeUtf8();

    final runtime = rwkvMobile.rwkvmobile_runtime_init_with_name(modelBackend.toNativeUtf8().cast<ffi.Char>());
    if (runtime == ffi.nullptr) {
      throw Exception('Failed to initialize runtime');
    }

    int retVal = rwkvMobile.rwkvmobile_runtime_load_tokenizer(runtime, tokenizerPath.toNativeUtf8().cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load tokenizer');
    }

    retVal = rwkvMobile.rwkvmobile_runtime_load_model(runtime, modelPathPointer.cast<ffi.Char>());
    if (retVal != 0) {
      throw Exception('Failed to load model');
    }
    // initializations done

    int maxLength = 2000;
    int maxMessages = 1000;
    ffi.Pointer<ffi.Char> responseBuffer = calloc.allocate<ffi.Char>(maxLength);
    final inputsPtr = calloc.allocate<ffi.Pointer<ffi.Char>>(maxMessages);

    // bool isGenerating = false;
    await for (final (String, dynamic) message in receivePort) {
      // print("💬 message: ${message.runtimeType}");
      // message: (String command, Dynamic args)
      final command = message.$1;
      if (command == 'setMaxLength') {
        final arg = message.$2 as int;
        if (maxLength > 0) {
          maxLength = arg;
          calloc.free(responseBuffer);
          responseBuffer = calloc.allocate<ffi.Char>(maxLength);
        }
      } else if (command == 'message') {
        final messages = message.$2 as List<String>;
        for (var i = 0; i < messages.length; i++) {
          inputsPtr[i] = messages[i].toNativeUtf8().cast<ffi.Char>();
        }
        final numInputs = messages.length;
        // TODO: callback function to send response back dynamically
        ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>> callbackPointer = ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>(
          RWKVMobile.callbackFunction,
        );

        if (kDebugMode) print("💬 Start to call LLM");
        retVal = rwkvMobile.rwkvmobile_runtime_eval_chat_with_history(runtime, inputsPtr, numInputs, responseBuffer, maxLength, callbackPointer);
        if (kDebugMode) print("💬 Call LLM done");
        if (retVal != 0) {
          throw Exception('Failed to evaluate chat');
        }
        final response = responseBuffer.cast<Utf8>().toDartString();
        sendPort.send({'response': response});
      } else {
        if (kDebugMode) print("😡 unknown command: $command");
      }
    }
  }
}
