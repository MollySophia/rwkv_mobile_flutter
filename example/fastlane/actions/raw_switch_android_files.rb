require "yaml"

module Fastlane
  module Actions
    class RawSwitchAndroidFilesAction < Action
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :env,
            description: "Target environment name",
            optional: false,
            type: String,
          ),
        ]
      end

      def self.run(params)
        config_path = File.join(__dir__, "..", "environments.yml")
        UI.user_error!("Missing environments config file at #{config_path}") unless File.exist?(config_path)

        environments = YAML.load_file(config_path)
        env = params[:env]
        config = environments[env]
        UI.user_error!("Unknown environment: #{env}") unless config

        # 遍历 key 值
        config.each do |key, toFilePath|
          if key.to_s.start_with?("file_")
            puts toFilePath
            fromFilePathList = environments[key]
            fromFilePathList.each do |fromFilePath|
              puts fromFilePath
              # 如果源路径和目标路径相同，跳过当前文件
              if fromFilePath == toFilePath
                puts "⏩ 源路径和目标路径相同，跳过: #{fromFilePath}"
                next
              end

              # 获取目标目录路径
              target_dir = File.dirname(toFilePath)

              begin
                # 确保目标目录存在
                FileUtils.mkdir_p(target_dir)

                # 源文件不存在的情况
                unless File.exist?(fromFilePath)
                  puts "⚠️ 源文件不存在: #{fromFilePath}"
                  File.open(toFilePath, "w") { }
                  next
                end

                # 目标文件已存在的情况
                if File.exist?(toFilePath)
                  File.delete(toFilePath)
                end

                # 复制文件
                FileUtils.cp(fromFilePath, toFilePath)

                # 删除源文件
                File.delete(fromFilePath)
              rescue => e
                puts "❌ 错误: #{e.message}"
                puts e.backtrace
              end
            end
          end
        end

        UI.success("✅ Global replacement complete for #{env} environment")
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
