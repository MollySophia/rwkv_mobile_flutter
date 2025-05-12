# RWKV Demos

## 技术架构

- [DeepWiki](https://deepwiki.com/MollySophia/rwkv_mobile_flutter)
- 前端: [flutter](https://github.com/MollySophia/rwkv_mobile_flutter/tree/master/example)
- adapter (dart ffi): [本项目](https://github.com/MollySophia/rwkv_mobile_flutter)
- 后端 (C++): [rwkv-mobile](https://github.com/MollySophia/rwkv-mobile)
- 权重: [mollysama/rwkv-mobile-models](https://huggingface.co/mollysama/rwkv-mobile-models/tree/main)

## 功能矩阵

| 功能              | Android | Android-QNN | iOS | macOS | Windows | Linux |
| ----------------- | :-----: | :---------: | :-: | :---: | :-----: | :---: |
| Chat              |   ✅    |     ✅      | ✅  |  ✅   |         |  ✅   |
| Othello           |   ✅    |             | ✅  |  ✅   |         |       |
| English Vision QA |   ✅    |             |     |       |         |       |
| English Audio QA  |   ✅    |             |     |       |         |       |
| English ASR       |   ✅    |             |     |       |         |       |
| Chinese ASR       |   🚧    |             |     |       |         |       |
| Sudoku            |   🚧    |             |     |       |         |       |
| 15Puzzle          |   🚧    |             |     |       |         |       |

## 下载链接

### Android APK

- [Pgyer](https://www.pgyer.com/rwkvchat)

### iOS

- [TestFlight](https://testflight.apple.com/join/DaMqCNKh)

## 前后端通讯方式

### Frontend to RWKV

```ToRWKV
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

```FromRWKV
/// 可以使用 switch case 来处理各个 response
///
/// 每个 response 可以携带自己需要的响应参数
///
/// 可以在该文件中使用 cursor tab 来快速生成各个 request
///
/// 建议同时打开 lib/rwkv_mobile_flutter.dart 文件以获得快速智能提示
sealed class FromRWKV {}
```
