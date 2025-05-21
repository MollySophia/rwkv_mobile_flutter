import 'dart:io'; // 🎯 用于文件系统操作，如文件读取、写入、目录创建等。
import 'package:yaml/yaml.dart'; // 📦 用于解析 YAML 配置文件。
import 'package:path/path.dart' as p; // 📂 用于处理文件路径。

/// 📝 模拟 Fastlane 的 UI 模块，用于打印日志和错误信息。
class UI {
  /// ❌ 打印一个错误信息并退出程序。
  static void userError(String message) {
    print('❌ 错误: $message');
    exit(1); // 退出程序，并返回非零状态码表示错误。
  }

  /// ✅ 打印一个成功信息。
  static void success(String message) {
    print('✅ 成功: $message');
  }

  /// 💬 打印一条普通信息。
  static void message(String message) {
    print(message);
  }
}

/// 🚀 脚本的入口点。
/// [arguments] 命令行参数列表，期望第一个参数是目标环境名称。
void main(List<String> arguments) {
  // 检查是否提供了环境名称参数。
  if (arguments.isEmpty) {
    UI.userError('用法: dart run raw_switch_android_files_action.dart <环境名称>');
  }

  final String env = arguments[0]; // 获取目标环境名称。

  // ⚙️ 确定 environments.yml 配置文件的路径。
  // 假设此 Dart 脚本位于 'fastlane/actions/' 目录下，
  // 那么 'environments.yml' 应该在 'fastlane/' 目录下，即相对于脚本目录的上一级。
  final String scriptDir = p.dirname(Platform.script.toFilePath());
  final String configPath = p.join(scriptDir, '../../fastlane', 'environments.yml');

  // 检查配置文件是否存在。
  if (!File(configPath).existsSync()) {
    UI.userError('缺少环境配置文件: $configPath');
  }

  YamlMap environments; // 存储解析后的 environments.yml 内容。
  try {
    final String yamlString = File(configPath).readAsStringSync();
    environments = loadYaml(yamlString) as YamlMap; // 加载并解析 YAML 文件。
  } catch (e) {
    UI.userError('加载或解析 environments.yml 失败: $e');
    return;
  }

  // 🎯 获取指定环境的配置。
  final YamlMap? config = environments[env] as YamlMap?;
  if (config == null) {
    UI.userError('未知环境: $env');
    return;
  }

  // 🔄 遍历选定环境配置中的每个键值对。
  config.forEach((key, toFilePath) {
    // 筛选出以 "file_" 开头的键，表示文件操作配置。
    if (key.toString().startsWith("file_")) {
      final String targetFilePath = toFilePath.toString(); // 目标文件路径。
      UI.message('目标文件: $targetFilePath');

      // 获取与当前键对应的源文件路径列表。
      final dynamic fromFilePathListDynamic = environments[key];
      List<String> fromFilePathList;

      if (fromFilePathListDynamic is YamlList) {
        fromFilePathList = fromFilePathListDynamic.nodes.map((node) => node.value.toString()).toList();
      } else if (fromFilePathListDynamic != null) {
        fromFilePathList = [fromFilePathListDynamic.toString()];
      } else {
        UI.message('⚠️ 警告: environments.yml 顶级中没有为键 "$key" 定义源文件路径。跳过此文件的操作。');
        return;
      }

      // 遍历所有可能的源文件路径。
      for (final String sourceFilePath in fromFilePathList) {
        UI.message('源文件: $sourceFilePath');

        // 如果源路径和目标路径相同，则跳过。
        if (sourceFilePath == targetFilePath) {
          UI.message("👍 源路径和目标路径相同，跳过: $sourceFilePath");
          continue;
        }

        // 获取目标目录路径。
        final String targetDir = p.dirname(targetFilePath);

        try {
          // 确保目标目录存在，如果不存在则创建。
          Directory(targetDir).createSync(recursive: true);

          final File sourceFile = File(sourceFilePath);
          final File targetFile = File(targetFilePath);

          // 检查源文件是否存在。
          if (!sourceFile.existsSync()) {
            UI.message("🚧 源文件不存在: $sourceFilePath");
            continue;
          }

          // 如果目标文件已存在，则跳过（与 Ruby 脚本逻辑一致）。
          if (targetFile.existsSync()) {
            UI.message("➡️ 目标文件已存在，跳过复制: $targetFilePath");
            continue;
          }

          // 复制文件。
          sourceFile.copySync(targetFilePath);
          UI.message("📦 已复制文件从 $sourceFilePath 到 $targetFilePath");

          // 删除源文件。
          sourceFile.deleteSync();
          UI.message("🗑️ 已删除源文件: $sourceFilePath");
        } catch (e, s) {
          UI.message("😡 处理文件时出错: $e");
          UI.message("堆栈追踪:\n$s"); // 打印堆栈追踪以便调试
        }
      }
    }
  });

  UI.success("✅ 环境 ${env} 的文件操作完成");
}

/// 平台支持性检查（模拟 Fastlane 的 is_supported? 方法）。
/// ℹ️ 此函数在此独立 Dart 脚本中未直接使用，但保留以供参考。
bool isSupportedPlatform(String platform) {
  return ['ios', 'android'].contains(platform.toLowerCase());
}
