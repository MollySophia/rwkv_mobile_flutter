import 'package:flutter/material.dart';

enum DemoType {
  chat,
  fifthteenPuzzle,
  othello,
  sudoku,
  tts,
  world,
  ;

  ColorScheme? get colorScheme => switch (this) {
        // DemoType.chat => ColorScheme.fromSeed(seedColor: Color.fromRGBO(2, 130, 130, 1)),
        DemoType.chat => null,
        DemoType.tts => ColorScheme.fromSeed(seedColor: Colors.green),
        DemoType.world => ColorScheme.fromSeed(seedColor: Colors.blue),
        DemoType.fifthteenPuzzle => ColorScheme.fromSeed(seedColor: Colors.blue),
        DemoType.othello => ColorScheme.fromSeed(seedColor: Colors.green),
        DemoType.sudoku => ColorScheme.fromSeed(seedColor: Colors.teal),
      };
}
