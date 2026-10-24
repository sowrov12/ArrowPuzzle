import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../components/board_component.dart';
import '../levels/sample_level.dart';
import '../logic/path_checker.dart';
import '../models/board.dart';

class ArrowGame extends FlameGame {
  ArrowGame({Board? board, this.onTapResult})
      : _board = board ?? Board.fromLayout(sampleLevelLayout);

  final Board _board;
  BoardComponent? _boardComponent;

  /// Optional hook for later tasks (hearts in 2.1, removal in 1.3).
  final void Function(int row, int col, PathResult result)? onTapResult;

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
    );
    _boardComponent = component;
    await add(component);
    component.layout(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _boardComponent?.layout(size);
  }
}
