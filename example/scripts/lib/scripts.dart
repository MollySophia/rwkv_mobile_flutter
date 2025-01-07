import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

int calculate() {
  return 6 * 7;
}

void buildApk({
  required String apkName,
  bool flutterClean = true,
  bool flutterPubGet = true,
}) async {
  print("💬 buildApk");

  if (flutterClean) {
    // Clean the build directory
    final cleanProcess = await Process.start("flutter", ["clean"], workingDirectory: "../");
    cleanProcess.stdout.listen((data) {
      print(utf8.decode(data));
    });
    cleanProcess.stderr.listen((data) {
      print(utf8.decode(data));
    });
    await cleanProcess.exitCode;
  }

  if (flutterPubGet) {
    // flutter pub get
    final pubGetProcess = await Process.start("flutter", ["pub", "get"], workingDirectory: "../");
    pubGetProcess.stdout.listen((data) {
      print(utf8.decode(data));
    });
    pubGetProcess.stderr.listen((data) {
      print(utf8.decode(data));
    });
    await pubGetProcess.exitCode;
  }

  // build the apk
  final process = await Process.start("flutter", ["build", "apk"], workingDirectory: "../");

  process.stdout.listen((data) {
    print(utf8.decode(data));
  });

  process.stderr.listen((data) {
    print(utf8.decode(data));
  });

  // Wait for the process to finish
  final exitCode = await process.exitCode;
  print("💬 buildApk exitCode: $exitCode");

  // Read the apk file

  // get versionName from pubspec.yaml
  // version: 0.1.4+131
  final yamlFileContent = File("../pubspec.yaml").readAsStringSync();
  final versionStringMatch = RegExp(r'version: (\d+\.\d+\.\d+)\+(\d+)').firstMatch(yamlFileContent);
  final versionName = versionStringMatch?.group(1);
  final buildNumber = versionStringMatch?.group(2);

  // rename the apk file
  File apkFile = File("../build/app/outputs/flutter-apk/app-release.apk");
  apkFile.renameSync("../build/app/outputs/flutter-apk/$apkName-$versionName-$buildNumber.apk");
  apkFile = File("../build/app/outputs/flutter-apk/$apkName-$versionName-$buildNumber.apk");

  // compress the apk file to a zip file
  final zipFile = File("../build/app/outputs/flutter-apk/$apkName-$versionName-$buildNumber.zip");
  final archive = Archive();
  final bytes = await apkFile.readAsBytes();
  final fileName = apkFile.uri.pathSegments.last;
  archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
  final zipBytes = ZipEncoder().encode(archive);
  zipFile.writeAsBytesSync(zipBytes!);

  // open the folder containing the apk file
  //
  Process.runSync("open", ["../build/app/outputs/flutter-apk/"]);
}

Future<int> format() async {
  final current = Directory.current;

  final projectPath = current.path.replaceAll("/scripts", "");
  final analysisOptionsPath = "$projectPath/analysis_options.yaml";
  final file = File(analysisOptionsPath);
  String content = await file.readAsString();
  content = content.replaceAll("t_constructors: false", "t_constructors: true");
  content = content.replaceAll("t_constructors_in_immutables: false", "t_constructors_in_immutables: true");
  content = content.replaceAll("t_literals_to_create_immutables: false", "t_literals_to_create_immutables: true");
  await file.writeAsString(content);

  final r = await Process.run(Platform.resolvedExecutable, [
    'fix',
    projectPath,
    "--apply",
  ]);
  print(r.stdout);

  content = content.replaceAll("t_constructors: true", "t_constructors: false");
  content = content.replaceAll("t_constructors_in_immutables: true", "t_constructors_in_immutables: false");
  content = content.replaceAll("t_literals_to_create_immutables: true", "t_literals_to_create_immutables: false");
  await file.writeAsString(content);

  return 0;
}
