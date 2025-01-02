import 'dart:isolate';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final rootIsolateToken = RootIsolateToken.instance;
  final rwkvMobile = RWKVMobile();
  final receivePort = ReceivePort();
  SendPort? sendPort;
  rwkvMobile.runIsolate(
    "/data/local/tmp/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin",
    "/data/local/tmp/b_rwkv_vocab_v20230424.txt",
    "ncnn",
    receivePort.sendPort, rootIsolateToken!
  );
  receivePort.listen((message) {
    if (message is SendPort) {
      sendPort = message;
    } else {
      print("Received message: $message");
    }
  });
  List<String> messagesList = ["Hello!"];
  sendPort?.send(("message", messagesList));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Hello world!\n'),
        ),
      ),
    );
  }
}
