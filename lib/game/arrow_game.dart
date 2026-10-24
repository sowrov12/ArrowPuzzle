import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../components/board_component.dart';
import '../components/hearts_component.dart';
import '../components/hint_button_component.dart';
import '../levels/sample_level.dart';
import '../logic/lives.dart';
import '../logic/path_checker.dart';
import '../logic/score_calculator.dart';
import '../models/board.dart';

class ArrowGame extends FlameGame {
  ArrowGame({
    Board? board,
    this.hintsPerLevel = 3,
    this.onTapResult,
    this.onWin,
    this.onGameOver,
  })  : hintsLeft = hintsPerLevel,
        _board = board ?? Board.fromLayout(sampleLevelLayout) {
    totalArrows = _board.tileCount;
  }

  /// Hearts per level (product spec).
  static const int maxHearts = 3;

  /// Overlay names, registered by the GameScreen's overlayBuilderMap.
  static const String pauseOverlay = 'pause';
  static const String winOverlay = 'win';
  static const String loseOverlay = 'lose';

  final Board _board;

  /// Arrows on the board when the level started (used for scoring).
  late final int totalArrows;
  final Lives lives = Lives(maxHearts: maxHearts);

  /// Hints available per level. Placeholder value: extra hints become
  /// purchasable / ad-rewarded in Task 4.2.
  final int hintsPerLevel;
  int hintsLeft;

  BoardComponent? _boardComponent;
  HintButtonComponent? _hintButton;
  HeartsComponent? _heartsComponent;

  /// Optional hook for later tasks.
  final void Function(int row, int col, PathResult result)? onTapResult;

  /// Called once when the board is cleared, with the final score.
  final void Function(int score)? onWin;

  /// Called once when the last heart is lost (lose condition).
  final void Function()? onGameOver;

  bool hasWon = false;
  bool hasLost = false;

  bool get isFinished => hasWon || hasLost;

  int get hintsUsed => hintsPerLevel - hintsLeft;

  /// Score if the level were finished right now.
  int get score => ScoreCalculator.calculate(
        arrowCount: totalArrows,
        heartsLeft: lives.hearts,
        hintsUsed: hintsUsed,
      );

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
    if (board == null || isFinished) return false;

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

  void pauseGame() {
    if (isFinished || overlays.isActive(pauseOverlay)) return;
    pauseEngine();
    overlays.add(pauseOverlay);
  }

  void resumeGame() {
    overlays.remove(pauseOverlay);
    resumeEngine();
  }

  void _handleCollision() {
    if (isFinished) return;
    lives.loseHeart();
    _heartsComponent?.hearts = lives.hearts;
    debugPrint('Hearts left: ${lives.hearts}');
    if (lives.isEmpty) _handleGameOver();
  }

  void _handleGameOver() {
    hasLost = true;
    _boardComponent?.inputLocked = true;
    debugPrint('Game over - no hearts left.');
    overlays.add(loseOverlay);
    onGameOver?.call();
  }

  void _handleWin() {
    if (hasLost) return; // an arrow that was already leaving can't undo a loss
    hasWon = true;
    debugPrint('Board cleared - level complete!');
    onWin?.call(score); // save progress before the overlay reads it
    overlays.add(winOverlay);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _heartsComponent?.layout(size);
    _hintButton?.layout(size, HeartsComponent.hudHeight);
    _boardComponent?.layout(size, topInset: HeartsComponent.hudHeight);
  }
}
