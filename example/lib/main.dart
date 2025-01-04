import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';
import 'package:path/path.dart' as path;

Future<String> getModelPath(String assetsPath) async {
  try {
    final data = await rootBundle.load(assetsPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(path.join(tempDir.path, assetsPath));
    await tempFile.create(recursive: true);
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    return tempFile.path;
  } catch (e) {
    if (kDebugMode) print("😡 $e");
    return "";
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initRWKV();
  runApp(const MyApp());
}

SendPort? sendPort;

StreamController<String> messagesController = StreamController<String>();

const firstMessage = "Hello!";

Future<void> _initRWKV() async {
  late final String modelPath;
  late final String tokenizerPath;
  late final String backendName;

  // TODO: Deal with different platform
  modelPath = await getModelPath("assets/model/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.bin");
  await getModelPath("assets/model/RWKV-x070-World-0.1B-v2.8-20241210-ctx4096-ncnn.param");
  tokenizerPath = await getModelPath("assets/model/b_rwkv_vocab_v20230424.txt");
  backendName = "ncnn";

  if (kDebugMode) print("✅ initRWKV start");
  final rootIsolateToken = RootIsolateToken.instance;
  final rwkvMobile = RWKVMobile();
  final availableBackendNames = rwkvMobile.getAvailableBackendNames();
  if (kDebugMode) print("💬 availableBackendNames: $availableBackendNames");
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
      if (message["response"] != null) {
        messagesController.add(message["response"].toString());
      }
      if (message["samplerParams"] != null) {
        if (kDebugMode) print("💬 Got samplerParams: ${message["samplerParams"]}");
      }
      if (message["currentPrompt"] != null) {
        if (kDebugMode) print("💬 Got currentPrompt: ${message["currentPrompt"]}");
      }
    }
  });
  List<String> messagesList = [firstMessage];
  while (sendPort == null) {
    if (kDebugMode) print("💬 waiting for sendPort...");
    await Future.delayed(const Duration(milliseconds: 500));
  }
  // TODO: Decide a better prompt to use
  sendPort!.send(("setPrompt", "User: hi\n\nAssistant: Hi. I am your assistant and I will provide expert full response in full details. Please feel free to ask any question and I will always answer it.\n\n"));
  sendPort!.send(("getPrompt", null));
  sendPort!.send(("setSamplerParams", {"temperature": 2.0, "top_k": 128, "top_p": 0.5, "presence_penalty": 0.5, "frequency_penalty": 0.5, "penalty_decay": 0.996}));
  sendPort!.send(("getSamplerParams", null));
  sendPort!.send(("message", messagesList));
  if (kDebugMode) print("✅ initRWKV end");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> _messages = [firstMessage];

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
