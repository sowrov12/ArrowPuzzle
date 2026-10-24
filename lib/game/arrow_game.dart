import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;

import '../components/board_component.dart';
import '../levels/sample_level.dart';
import '../logic/path_checker.dart';
import '../models/board.dart';

class ArrowGame extends FlameGame {
  ArrowGame({Board? board, this.onTapResult, this.onWin})
      : _board = board ?? Board.fromLayout(sampleLevelLayout);

  final Board _board;
  BoardComponent? _boardComponent;
  TextComponent? _winText;

  /// Optional hook for later tasks (e.g. hearts in Task 2.1).
  final void Function(int row, int col, PathResult result)? onTapResult;

  /// Called once when the board is cleared (win condition).
  final void Function()? onWin;

  bool hasWon = false;

  @override
  Color backgroundColor() => const Color(0xFF1B1F2A);

  @override
  Future<void> onLoad() async {
    final component = BoardComponent(
      _board,
      onArrowTapped: (arrow, result) {
        debugPrint('Tapped ${arrow.tile.id} (${arrow.tile.direction.toJson()})'
            ' -> ${result.name}');
        onTapResult?.call(arrow.row, arrow.col, result);
      },
      onBoardCleared: _handleWin,
    );
    _boardComponent = component;
    await add(component);
    component.layout(size);
  }

  void _handleWin() {
    hasWon = true;
    debugPrint('Board cleared - level complete!');
    // Placeholder banner; the real Win overlay is built in Task 2.3.
    final text = TextComponent(
      text: 'LEVEL CLEAR!',
      anchor: Anchor.center,
      position: size / 2,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _winText = text;
    add(text);
    onWin?.call();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _boardComponent?.layout(size);
    _winText?.position = size / 2;
  }
}
