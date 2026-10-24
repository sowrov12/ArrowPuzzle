import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/arrow_game.dart';

void main() {
  runApp(const ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  const ArrowPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arrow Puzzle',
      home: Scaffold(
        backgroundColor: const Color(0xFF1B1F2A),
        body: SafeArea(child: GameWidget(game: ArrowGame())),
      ),
    );
  }
}
