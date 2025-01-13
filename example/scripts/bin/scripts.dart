import 'package:scripts/scripts.dart' as scripts;

void main(List<String> arguments) {
  scripts.removeAssetLine(
    assetFileName: 'RWKV-x070-World-0.4B-v2.9-20250107-ctx4096.st',
  );
  scripts.buildApk(apkName: "RWKV-Chat-V7");
}
