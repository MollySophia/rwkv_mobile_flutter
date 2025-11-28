# Create temporary directory
New-Item -ItemType Directory -Force -Path "tmp"
Set-Location tmp

# Download all library files
$baseUrl = "https://github.com/MollySophia/rwkv-mobile/releases/download/latest"
$files = @(
    "librwkv_mobile-dev-latest-ios-static.zip",
    "librwkv_mobile-dev-latest-macos.zip",
    "librwkv_mobile-dev-latest-aarch64-android-ndk-r25c.zip",
    "librwkv_mobile-dev-latest-linux-aarch64.zip",
    "librwkv_mobile-dev-latest-linux-x86_64.zip",
    "librwkv_mobile-dev-latest-windows-x64.zip",
    "librwkv_mobile-dev-latest-windows-arm64.zip"
)

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    Write-Host "Downloading $file..."
    Invoke-WebRequest -Uri $url -OutFile $file
}

# Create and extract to platform-specific directories
$platforms = @{
    "ios" = @("librwkv_mobile-dev-latest-ios-static.zip")
    "macos" = @("librwkv_mobile-dev-latest-macos.zip")
    "android" = @("librwkv_mobile-dev-latest-aarch64-android-ndk-r25c.zip")
    "linux" = @("librwkv_mobile-dev-latest-linux-aarch64.zip", "librwkv_mobile-dev-latest-linux-x86_64.zip")
    "windows" = @("librwkv_mobile-dev-latest-windows-x64.zip", "librwkv_mobile-dev-latest-windows-arm64.zip")
}

foreach ($platform in $platforms.Keys) {
    New-Item -ItemType Directory -Force -Path $platform
    Set-Location $platform
    
    foreach ($zipFile in $platforms[$platform]) {
        Write-Host "Extracting $zipFile to $platform..."
        Expand-Archive -Path "../$zipFile" -DestinationPath "." -Force
    }
    
    Set-Location ..
}

# Return to the original directory
Set-Location ..

# Copy files to their final destinations
Write-Host "Copying files to final destinations..."

# Create destination directories if they don't exist
New-Item -ItemType Directory -Force -Path "ios"
New-Item -ItemType Directory -Force -Path "macos"
New-Item -ItemType Directory -Force -Path "android/src/main/jniLibs/arm64-v8a"
New-Item -ItemType Directory -Force -Path "linux"
New-Item -ItemType Directory -Force -Path "windows"

# iOS
Copy-Item -Path "tmp/ios/*" -Destination "ios/" -Recurse -Force

# macOS
Copy-Item -Path "tmp/macos/*" -Destination "macos/" -Recurse -Force

# Android
Copy-Item -Path "tmp/android/*.so" -Destination "android/src/main/jniLibs/arm64-v8a/" -Force

# Linux
Copy-Item -Path "tmp/linux/*" -Destination "linux/" -Recurse -Force

# Windows
Copy-Item -Path "tmp/windows/Release/*" -Destination "windows/" -Recurse -Force

# Cleanup
Remove-Item -Path "tmp" -Recurse -Force

Write-Host "Library update completed successfully!" 