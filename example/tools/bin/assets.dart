import 'dart:io';

Future<void> main() async {
  // 定义要执行的命令列表
  final List<String> commands = ['dart run flutter_native_splash:create; cd fastlane', 'dart run icons_launcher:create; cd fastlane'];

  for (final String command in commands) {
    print('🚀 正在执行命令: $command');
    try {
      // 使用 Process.run 来执行 shell 命令
      // 'sh' 是 shell 命令，'-c' 选项允许您将字符串作为命令传递给 shell
      final ProcessResult result = await Process.run('sh', ['-c', command]);

      // 检查命令的退出代码
      if (result.exitCode == 0) {
        print('✅ 命令执行成功。');
        if (result.stdout.isNotEmpty) {
          print('输出:\n${result.stdout}');
        }
      } else {
        print('❌ 命令执行失败，退出代码: ${result.exitCode}');
        if (result.stderr.isNotEmpty) {
          print('错误输出:\n${result.stderr}');
        }
      }
    } catch (e) {
      print('😡 执行命令时发生异常: $e');
    }
    print(''); // 打印空行以分隔不同命令的输出
  }
}
