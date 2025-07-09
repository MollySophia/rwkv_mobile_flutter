# RWKV Demos

## 技术架构

- [DeepWiki](https://deepwiki.com/MollySophia/rwkv_mobile_flutter)
- 前端: [flutter](https://github.com/MollySophia/rwkv_mobile_flutter/tree/master/example)
- adapter (dart ffi): [本项目](https://github.com/MollySophia/rwkv_mobile_flutter)
- 后端 (C++): [rwkv-mobile](https://github.com/MollySophia/rwkv-mobile)
- 权重: [mollysama/rwkv-mobile-models](https://huggingface.co/mollysama/rwkv-mobile-models/tree/main)

## 更新后端二进制库文件
当遇到`Invalid argument(s): Failed to lookup symbol 'xxx': undefined symbol: xxx`错误时，可以尝试更新本地repo的后端二进制library：
- Windows:
使用PowerShell执行脚本
```powershell
& ./fetch_latest_libraries.ps1
```

- Linux / macOS:
终端执行脚本
```sh
./fetch_latest_libraries.sh
```

## Demos （源码：[github.com/RWKV-APP/RWKV_APP](https://github.com/RWKV-APP/RWKV_APP)）

### RWKV Chat

[Android](https://www.pgyer.com/rwkvchat) | [iOS TestFlight](https://testflight.apple.com/join/DaMqCNKh) | [Python](https://github.com/BlinkDL/RWKV-LM)

### RWKV Talk 语音

[Android](https://www.pgyer.com/rwkv-talk) | [iOS TestFlight](https://testflight.apple.com/join/mfsdWS4b) | [Python](https://github.com/yynil/RWKVTTS)

### RWKV See 视觉理解

[Android](https://www.pgyer.com/rwkv-see) | [iOS TestFlight](https://testflight.apple.com/join/vAjawMJc) | [Python](https://github.com/JL-er/WorldRWKV)

### RWKV Othello 黑白棋

[Android](https://www.pgyer.com/rwkv-othello) | [iOS TestFlight](https://testflight.apple.com/join/f5SVf76c) | [Python](https://github.com/Jellyfish042/RWKV_Othello)

### RWKV Sudoku 数独

[Android](https://www.pgyer.com/rwkv-sudoku) | _🚧 审核中_ iOS TestFlight | [Python](https://github.com/Jellyfish042/Sudoku-RWKV)

## 前后端通讯方式

### Frontend to RWKV

Frontend isolate 和 RWKV isolate 通过 sendPort 进行通讯, sendPort 发送两种类型的消息

```dart
/// Send request from frontend isolate to rwkv isolate
///
/// 可以使用 switch case 来处理各个 response
///
/// 每个 request 可以携带自己需要的响应参数
///
/// 可以在该文件中使用 cursor tab 来快速生成各个 request
///
/// 建议同时打开 lib/rwkv_mobile_flutter.dart 文件以获得快速智能提示
sealed class ToRWKV {}
```

### RWKV to frontend

```dart
/// Send response from rwkv isolate to frontend isolate
///
/// 可以使用 switch case 来处理各个 response
///
/// 每个 response 可以携带自己需要的响应参数
///
/// 可以在该文件中使用 cursor tab 来快速生成各个 request
///
/// 建议同时打开 lib/rwkv_mobile_flutter.dart 文件以获得快速智能提示
sealed class FromRWKV {}
```

- [Dart lang: class modifiers > sealed](https://dart.dev/language/class-modifiers-for-apis#the-sealed-modifier) How to use the class modifiers added in Dart 3.0 to make your package's API more robust and maintainable.
