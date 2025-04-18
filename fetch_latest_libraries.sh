#!/bin/sh

mkdir tmp && cd tmp
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-ios-static.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-macos.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-aarch64-android-ndk-r27c.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-linux-aarch64.zip
wget https://github.com/MollySophia/rwkv-mobile/releases/download/latest/librwkv_mobile-dev-latest-linux-x86_64.zip

mkdir ios && cd ios && unzip ../librwkv_mobile-dev-latest-ios-static.zip && cd ..
mkdir macos && cd macos && unzip ../librwkv_mobile-dev-latest-macos.zip && cd ..
mkdir android && cd android && unzip ../librwkv_mobile-dev-latest-aarch64-android-ndk-r27c.zip && cd ..
mkdir linux && cd linux && unzip ../librwkv_mobile-dev-latest-linux-aarch64.zip && unzip ../librwkv_mobile-dev-latest-linux-x86_64.zip && cd ..
cd ..

cp -r tmp/ios/* ios/
cp -r tmp/macos/* macos/
cp -r tmp/android/*.so android/src/main/jniLibs/arm64-v8a/
cp -r tmp/linux/* linux/
rm -rf tmp