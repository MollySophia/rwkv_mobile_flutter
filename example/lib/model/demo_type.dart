import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DemoType {
  /// RWKV Chat
  chat,

  /// RWKV_Fiffthteen_Puzzle
  fifthteenPuzzle,

  /// RWKV_Othello
  othello,

  /// RWKV_Sudoku
  sudoku,

  /// RWKV_Talk
  tts,

  /// RWKV_See
  world;

  ColorScheme? get colorScheme => switch (this) {
    DemoType.chat => ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    DemoType.tts => ColorScheme.fromSeed(seedColor: Colors.green),
    DemoType.world => ColorScheme.fromSeed(seedColor: Colors.blue),
    DemoType.fifthteenPuzzle => ColorScheme.fromSeed(seedColor: Colors.blue),
    DemoType.othello => ColorScheme.fromSeed(seedColor: Colors.green),
    DemoType.sudoku => ColorScheme.fromSeed(seedColor: Colors.teal),
  };

  List<DeviceOrientation>? get mobileOrientations => switch (this) {
    _ => [DeviceOrientation.portraitUp],
  };

  List<DeviceOrientation>? get desktopOrientations => switch (this) {
    _ => null,
  };
}
