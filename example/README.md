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

- 使用 `fastlane switch_env env:chat` 切换至 chat app
- 使用 `fastlane switch_env env:tts` 切换至 tts app
- 使用 `fastlane switch_env env:world` 切换至 world app

### 运行

- 在 vscode / cursor 中运行 "Debug: Start Debugging" (`workbench.action.debug.start`)
