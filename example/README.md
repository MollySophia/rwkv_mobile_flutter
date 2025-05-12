# RWKV Demo

## 准备工作

- 找开发人员索要 `example/.env` 文件
- 找开发人员索要 `example/assets/filter.txt` 文件

### flutter env

```
 flutter doctor
```

```
[✓] Flutter (Channel stable, 3.29.3, on macOS 15.4.1 24E263 darwin-arm64, locale
    en-CN)
[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 16.3)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2024.3)
[✓] VS Code (version 1.99.3)
```

## 开发

- 使用 `fastlane switch_env env:chat` 切换至 chat app
- 使用 `fastlane switch_env env:tts` 切换至 tts app
- 使用 `fastlane switch_env env:world` 切换至 world app
