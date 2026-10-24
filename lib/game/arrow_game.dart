import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;

import '../components/board_component.dart';
import '../components/hearts_component.dart';
import '../components/hint_button_component.dart';
import '../levels/sample_level.dart';
import '../logic/lives.dart';
import '../logic/path_checker.dart';
import '../models/board.dart';

class ArrowGame extends FlameGame {
  ArrowGame({
    Board? board,
    this.hintsPerLevel = 3,
    this.onTapResult,
    this.onWin,
    this.onGameOver,
  })  : hintsLeft = hintsPerLevel,
        _board = board ?? Board.fromLayout(sampleLevelLayout);

  /// Hearts per level (product spec).
  static const int maxHearts = 3;

  final Board _board;
  final Lives lives = Lives(maxHearts: maxHearts);

  /// Hints available per level. Placeholder value: extra hints become
  /// purchasable / ad-rewarded in Task 4.2.
  final int hintsPerLevel;
  int hintsLeft;

  BoardComponent? _boardComponent;
  HintButtonComponent? _hintButton;
  HeartsComponent? _heartsComponent;
  TextComponent? _banner;

  /// Optional hook for later tasks.
  final void Function(int row, int col, PathResult result)? onTapResult;

  /// Called once when the board is cleared (win condition).
  final void Function()? onWin;

  /// Called once when the last heart is lost (lose condition).
  final void Function()? onGameOver;

  bool hasWon = false;
  bool hasLost = false;

  @override
  Color backgroundColor() => const Color(0xFF1B1F2A);

  @override
  Future<void> onLoad() async {
    final hearts = HeartsComponent(maxHearts: maxHearts, hearts: lives.hearts);
    _heartsComponent = hearts;
    await add(hearts);

    final board = BoardComponent(
      _board,
      onArrowTapped: (arrow, result) {
        debugPrint('Tapped ${arrow.tile.id} (${arrow.tile.direction.toJson()})'
            ' -> ${result.name}');
        if (result == PathResult.collisionDetected) _handleCollision();
        onTapResult?.call(arrow.row, arrow.col, result);
      },
      onBoardCleared: _handleWin,
    );
    _boardComponent = board;
    await add(board);

    final hintButton = HintButtonComponent(
      onPressed: requestHint,
      hintsLeft: hintsLeft,
    );
    _hintButton = hintButton;
    await add(hintButton);

    hearts.layout(size);
    hintButton.layout(size, HeartsComponent.hudHeight);
    board.layout(size, topInset: HeartsComponent.hudHeight);
  }

  /// Highlights a playable arrow. Returns true if a hint is being shown.
  /// A new hint is only spent when none is currently visible.
  bool requestHint() {
    final board = _boardComponent;
    if (board == null || hasWon || hasLost) return false;

    if (board.hasActiveHint) {
      board.showHint(); // restart the pulse, no extra cost
      return true;
    }
    if (hintsLeft <= 0) return false;
    if (board.showHint() == null) return false; // nothing free: don't charge

    hintsLeft--;
    _hintButton?.hintsLeft = hintsLeft;
    debugPrint('Hint used. Hints left: $hintsLeft');
    return true;
  }

  void _handleCollision() {
    if (hasWon || hasLost) return;
    lives.loseHeart();
    _heartsComponent?.hearts = lives.hearts;
    debugPrint('Hearts left: ${lives.hearts}');
    if (lives.isEmpty) _handleGameOver();
  }

  void _handleGameOver() {
    hasLost = true;
    _boardComponent?.inputLocked = true;
    debugPrint('Game over - no hearts left.');
    _showBanner('GAME OVER'); // placeholder; real Lose overlay is Task 2.3
    onGameOver?.call();
  }

  void _handleWin() {
    if (hasLost) return; // an arrow that was already leaving can't undo a loss
    hasWon = true;
    debugPrint('Board cleared - level complete!');
    _showBanner('LEVEL CLEAR!'); // placeholder; real Win overlay is Task 2.3
    onWin?.call();
  }

  void _showBanner(String message) {
    final banner = TextComponent(
      text: message,
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
    _banner = banner;
    add(banner);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _heartsComponent?.layout(size);
    _hintButton?.layout(size, HeartsComponent.hudHeight);
    _boardComponent?.layout(size, topInset: HeartsComponent.hudHeight);
    _banner?.position = size / 2;
  }
}
