#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint onnxruntime.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
    s.name             = 'rwkv_mobile'
    s.version          = '0.0.1'
    s.summary          = 'rwkv_mobile plugin for Flutter apps.'
    s.description      = <<-DESC
  rwkv_mobile plugin for Flutter apps.
                         DESC
    s.homepage         = 'https://github.com/MollySophia/rwkv-mobile/'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'email@example.com' }
  
    # This will ensure the source files in Classes/ are included in the native
    # builds of apps using this FFI plugin. Podspec does not support relative
    # paths, so Classes contains a forwarder C file that relatively imports
    # `../src/*` so that the C sources can be shared among all target platforms.
    s.source           = { :path => '.' }
    # s.source_files = 'Classes/**/*'
    s.dependency 'FlutterMacOS'
    s.vendored_libraries = '*.dylib'
    s.platform = :osx, '10.14'
    s.static_framework = true
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    s.swift_version = '5.0'
  end