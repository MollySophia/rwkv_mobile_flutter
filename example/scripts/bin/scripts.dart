import 'package:scripts/scripts.dart' as scripts;

void main(List<String> arguments) {
  scripts.removeAssetLine(
    assetFileName: 'RWKV-x070-World-0.1B-v2.8-20241210-ctx4096.st',
  );
  scripts.buildApk(apkName: "RWKV-Chat-V7");
}
