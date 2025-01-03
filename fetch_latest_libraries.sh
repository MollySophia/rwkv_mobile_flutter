#!/bin/sh

mkdir tmp && cd tmp
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-ios-static.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-macos.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-aarch64-android-ndk-r25c.zip
mkdir ios && cd ios && unzip ../librwkv_mobile-dev-latest-ios-static.zip && cd ..
mkdir macos && cd macos && unzip ../librwkv_mobile-dev-latest-macos.zip && cd ..
mkdir android && cd android && unzip ../librwkv_mobile-dev-latest-aarch64-android-ndk-r25c.zip && cd ..
cd ..

cp -r tmp/ios/* ios/
cp -r tmp/macos/* macos/
cp -r tmp/android/*.so android/src/main/jniLibs/arm64-v8a/
rm -rf tmp