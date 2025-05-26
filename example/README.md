# RWKV Demo

## 准备工作

- 找开发人员索要 `example/.env` 文件, 将 zip 文件解压后的文件拷贝至目录 `example/.env`
- 找开发人员索要 `example/assets/filter.txt` 文件, 将 zip 文件解压后的文件拷贝至目录 `example/assets/filter.txt`
- 找开发人员索要 `example/assets/model` 文件夹, 将 zip 文件解压后的文件夹拷贝至目录 `example/assets/model`

### flutter env

```
 flutter doctor
```

```
[✓] Flutter (Channel stable, 3.29.3, on macOS 15.4.1 24E263 darwin-arm64, locale en-CN)
[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 16.3)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.3)
[✓] VS Code (version 1.99.3)
```

## 开发

### 设置环境

- 使用 `fastlane switch_env env:chat` 切换至 chat app (RWKV Chat)
- 使用 `fastlane switch_env env:tts` 切换至 tts app (RWKV Talk)
- 使用 `fastlane switch_env env:world` 切换至 world app (RWKV See)
- 使用 `fastlane switch_env env:othello` 切换至 world app (RWKV Othello)
- 使用 `fastlane switch_env env:sudoku` 切换至 world app (RWKV Sudoku)

### 运行

- 在 vscode / cursor 中运行 "Debug: Start Debugging" (`workbench.action.debug.start`)

## 聊天页面逻辑

页面 UI: `lib/page/chat.dart`
消息 UI: `lib/widgets/chat/message.dart`
状态: `lib/state/chat.dart`
模型: `example/lib/model/message.dart`
后端: RWKV

- 使用 ListView.separated 来渲染消息列表, `ListView.reverse = true`
- 使用 `late final messages = qs<List<Message>>([]);` 作为数据源
- 使用 `P.chat.send` 方法发送消息, 主要逻辑为先发送用户消息, 同步至状态, 再发送 bot message, 同步至状态. 而后, 向 Backend 发送消息, 最后, 周期性地从 backend 接收新生成的字符串.
- 从 backend 接收到新生成的字符串后, 更新 bot message 的状态, 触发 UI 更新
