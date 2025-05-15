cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "rwkvmobile")
project(${PROJECT_NAME} LANGUAGES CXX)

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
# add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(rwkvmobile_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/rwkv_mobile.dll"
  PARENT_SCOPE
)