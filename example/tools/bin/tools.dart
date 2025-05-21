import 'dart:io'; // 🎯 用于文件系统操作，如读取、写入文件和列出目录内容。
import 'package:yaml/yaml.dart'; // 📦 用于解析 YAML 文件。需要在 pubspec.yaml 中添加依赖：yaml: ^x.y.z
import 'package:glob/glob.dart'; // 🔍 用于文件路径的 glob 模式匹配。需要在 pubspec.yaml 中添加依赖：glob: ^x.y.z
import 'package:path/path.dart' as p; // 📂 用于处理文件路径，如获取目录名、连接路径等。需要在 pubspec.yaml 中添加依赖：path: ^x.y.z

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
  // if (arguments.isEmpty) {
  //   UI.userError('用法: dart run global_config_replace.dart <环境名称>');
  // return;
  // }

  // final String env = arguments[0]; // 获取目标环境名称。
  final String env = "tts";

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
  }

  // 📝 定义要处理的文件模式列表。
  final List<String> targetFilePatterns = [
    // 代码文件
    '**/*.dart',
    '**/*.swift',
    '**/*.kt',
    '**/*.m',
    '**/*.h',

    // 配置文件
    '**/*.yaml',
    '**/*.yml',
    '**/*.json',
    '**/*.plist',
    '**/*.xml',
    '**/*.pbxproj',
    '**/*.xcconfig',

    // 构建文件
    '**/Podfile',
    '**/*.gradle',
    '**/*.properties',

    // Fastlane文件
    'fastlane/Appfile',
    'fastlane/Fastfile',
  ];

  // 🚫 定义要排除的文件模式列表。
  final List<String> excludePatterns = [
    '**/build/**',
    '**/.git/**',
    '**/Pods/**',
    '**/Carthage/**',
    '**/vendor/**',
    '**/node_modules/**',
    'fastlane/actions/**', // 排除 action 文件自身
    'fastlane/environments.yml', // 排除配置文件自身
    '**/gen/**',
    '**/l10n/**',
    'assets/config/**',
  ];

  // 转换模式为 Glob 对象，以便进行高效的模式匹配（不区分大小写）。
  final List<Glob> targetGlobs = targetFilePatterns.map((p) => Glob(p, caseSensitive: false)).toList();
  final List<Glob> excludeGlobs = excludePatterns.map((p) => Glob(p, caseSensitive: false)).toList();

  print("FUCK");

  // 🔄 遍历选定环境配置中的每个键值对。
  config!.forEach((key, value) {
    // 'froms' 是此 'key' 可能的原始值列表。
    // 这假设 'environments' (完整的 YAML 内容) 包含与当前环境配置中的 'key' 对应的顶级键，
    // 并且这些顶级键包含一个字符串列表，这些字符串是要被替换的旧值。
    final dynamic fromsDynamic = environments[key];
    List<String> froms;

    if (fromsDynamic is YamlList) {
      // 如果是 YAML 列表，则将其转换为字符串列表。
      froms = fromsDynamic.nodes.map((node) => node.value.toString()).toList();
    } else if (fromsDynamic != null) {
      // 如果是单个值（非空），则将其包装成一个单元素列表。
      froms = [fromsDynamic.toString()];
    } else {
      // 如果没有定义 'from' 值，则跳过此键的替换。
      UI.message('⚠️ 警告: environments.yml 顶级中没有为键 "$key" 定义 "from" 值。跳过此键的替换。');
      return;
    }

    final String to = value.toString(); // 目标替换值。

    UI.message('处理键: "$key" (将 ${froms.join(', ')} 替换为 "$to")');

    // 📁 递归遍历当前目录下的所有文件。
    Directory.current.listSync(recursive: true, followLinks: false).forEach((entity) {
      if (entity is File) {
        // 获取文件的相对路径，以便与 glob 模式匹配。
        final String relativePath = p.relative(entity.path, from: Directory.current.path);

        // 首先检查是否与排除模式匹配。
        if (excludeGlobs.any((glob) => glob.matches(relativePath))) {
          return; // 跳过被排除的文件。
        }

        // 检查是否与目标文件模式匹配。
        if (targetGlobs.any((glob) => glob.matches(relativePath))) {
          replaceInFile(entity.path, froms, to); // 执行文件内容替换。
        }
      }
    });
  });

  UI.success('✅ 环境 ${env} 的全局替换完成');
}

/// 🔄 在文件中执行字符串替换。
/// [path] 文件的路径。
/// [froms] 要替换的旧字符串列表。
/// [to] 替换后的新字符串。
void replaceInFile(String path, List<String> froms, String to) {
  try {
    String content = File(path).readAsStringSync(); // 读取文件内容。
    final String originalContent = content; // 保留原始内容用于比较。

    // 遍历所有 'from' 字符串，并进行替换。
    for (final String from in froms) {
      content = content.replaceAll(from, to);
    }

    // 如果内容发生变化，则写入文件。
    if (content != originalContent) {
      File(path).writeAsStringSync(content);
      UI.message('  更新文件: $path');
    }
  } catch (e) {
    UI.message('  处理文件 $path 时出错: $e');
  }
}

/// 平台支持性检查（模拟 Fastlane 的 is_supported? 方法）。
/// ℹ️ 此函数在此独立 Dart 脚本中未直接使用，但保留以供参考。
bool isSupportedPlatform(String platform) {
  return ['ios', 'android'].contains(platform.toLowerCase());
}
