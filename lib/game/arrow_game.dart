import 'dart:ui';

import 'package:flame/game.dart';

import '../components/board_component.dart';
import '../levels/sample_level.dart';
import '../models/board.dart';

class ArrowGame extends FlameGame {
  ArrowGame({Board? board})
      : _board = board ?? Board.fromLayout(sampleLevelLayout);

  final Board _board;
  BoardComponent? _boardComponent;

  @override
  Color backgroundColor() => const Color(0xFF1B1F2A);

  @override
  Future<void> onLoad() async {
    final component = BoardComponent(_board);
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
