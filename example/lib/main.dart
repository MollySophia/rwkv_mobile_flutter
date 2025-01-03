import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initRWKV();
  runApp(const MyApp());
}

SendPort? sendPort;

StreamController<String> messagesController = StreamController<String>();

Future<void> _initRWKV() async {
  late final String modelPath;
  late final String tokenizerPath;
  late final String backendName;

  // copy tokenizer file from assets to cache
  final cacheDir = await getTemporaryDirectory();
  final rawAssetFile = await rootBundle.load("assets/b_rwkv_vocab_v20230424.txt");
  final rawAssetBytes = rawAssetFile.buffer.asUint8List();
  tokenizerPath = "${cacheDir.path}/b_rwkv_vocab_v20230424.txt";
  final tokenizerFile = File(tokenizerPath);
  await tokenizerFile.writeAsBytes(rawAssetBytes);

  if (Platform.isAndroid) {
    // adb push ./* /data/local/tmp
    modelPath = "/data/local/tmp/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin";
    backendName = "ncnn";
  } else if (Platform.isIOS) {
    // TODO: Waiting for arm64 librwkv_mobile.a
    // TODO: Add to assets
    modelPath = "/Users/wangce/Documents/flutter/packages/rwkv_mobile_flutter/example/assets/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin";
    backendName = "ncnn";
  } else if (Platform.isMacOS) {
    // TODO: Waiting for arm64 librwkv_mobile.dylib
    // TODO: Add to assets
    modelPath = "/Users/wangce/Downloads/x/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin";
    backendName = "ncnn";
  } else {
    throw Exception("Unsupported platform");
  }

  if (kDebugMode) print("✅ initRWKV start");
  final rootIsolateToken = RootIsolateToken.instance;
  final rwkvMobile = RWKVMobile();
  final receivePort = ReceivePort();
  rwkvMobile.runIsolate(
    modelPath,
    tokenizerPath,
    backendName,
    receivePort.sendPort,
    rootIsolateToken!,
  );
  receivePort.listen((message) {
    if (message is SendPort) {
      sendPort = message;
    } else {
      messagesController.add(message["response"].toString());
    }
  });
  List<String> messagesList = ["Hello!"];
  while (sendPort == null) {
    if (kDebugMode) print("💬 waiting for sendPort...");
    await Future.delayed(const Duration(milliseconds: 500));
  }
  sendPort!.send(("message", messagesList));
  if (kDebugMode) print("✅ initRWKV end");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    messagesController.stream.listen((message) {
      _messages.add(message);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_messages[index]),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              ),
            ),
            TextButton(
                onPressed: () {
                  _messages.add("Tell me about the Eiffel Tower.");
                  sendPort!.send(("message", _messages));
                  setState(() {});
                },
                child: Text("Tell me about the Eiffel Tower.")),
            TextButton(
                onPressed: () {
                  _messages.add("It's designed by who?");
                  sendPort!.send(("message", _messages));
                  setState(() {});
                },
                child: Text("It's designed by who?")),
            SizedBox(
              height: padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}
