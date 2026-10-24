import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../logic/path_checker.dart';
import '../models/board.dart';
import 'arrow_component.dart';

typedef ArrowTapCallback = void Function(
    ArrowComponent arrow, PathResult result);

/// Renders the grid, owns one [ArrowComponent] per tile, applies tap results
/// (remove on clear path, flash on collision) and detects the win condition.
/// Call [layout] whenever the available screen size changes.
class BoardComponent extends PositionComponent {
  BoardComponent(this.board, {this.onArrowTapped, this.onBoardCleared}) {
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final tile = board.tileAt(r, c);
        if (tile != null) {
          _arrows.add(
            ArrowComponent(tile: tile, row: r, col: c, onTap: _handleTap),
          );
        }
      }
    }
  }

  static const double screenPadding = 16;
  static const double cellGap = 4;
  static const Color _collisionFlash = Color(0xFFFF2D2D);

  final Board board;

  /// Notified after every tap with the path-check result.
  final ArrowTapCallback? onArrowTapped;

  /// Called once, after the last arrow has finished leaving the board.
  final void Function()? onBoardCleared;

  final List<ArrowComponent> _arrows = [];
  double cellSize = 0;
  double _exitDistance = 0;
  int _removing = 0; // arrows currently animating off
  bool _isCleared = false;

  bool get isCleared => _isCleared;

  /// When true, taps are ignored (set by the game on game over).
  bool inputLocked = false;

  static final Paint _cellPaint = Paint()..color = const Color(0xFF262B3A);

  void _handleTap(ArrowComponent arrow) {
    if (inputLocked || _isCleared || arrow.isRemoving) return;

    final result = PathChecker.check(board, arrow.row, arrow.col);
    if (result == PathResult.clearPath) {
      // Free the cell right away so other arrows can use the space.
      arrow.tile.isOccupied = false;
      _removing++;
      final dir = arrow.tile.direction;
      arrow.slideOff(
        Vector2(dir.dCol.toDouble(), dir.dRow.toDouble()) * _exitDistance,
        onDone: _onArrowGone,
      );
    } else {
      arrow.flash(_collisionFlash);
    }
    onArrowTapped?.call(arrow, result);
  }

  void _onArrowGone() {
    _removing--;
    if (_removing == 0 && board.isCleared && !_isCleared) {
      _isCleared = true;
      onBoardCleared?.call();
    }
  }

  @override
  Future<void> onLoad() async {
    await addAll(_arrows);
  }

  /// [topInset] reserves space at the top of the screen (e.g. for the hearts).
  void layout(Vector2 available, {double topInset = 0}) {
    final usableW = available.x - screenPadding * 2;
    final usableH = available.y - topInset - screenPadding * 2;
    if (usableW <= 0 || usableH <= 0 || board.rows == 0 || board.cols == 0) {
      return;
    }

    cellSize = math.min(usableW / board.cols, usableH / board.rows);
    size = Vector2(cellSize * board.cols, cellSize * board.rows);
    position = Vector2(
      (available.x - size.x) / 2,
      topInset + (available.y - topInset - size.y) / 2,
    );
    // Far enough to leave the screen from anywhere on the board.
    _exitDistance = math.max(available.x, available.y) + cellSize;

    for (final arrow in _arrows) {
      if (arrow.isRemoving) continue; // don't disturb running animations
      arrow.size = Vector2.all(cellSize - cellGap);
      arrow.position = Vector2(
        (arrow.col + 0.5) * cellSize,
        (arrow.row + 0.5) * cellSize,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (cellSize <= 0) return;
    final radius = Radius.circular(cellSize * 0.18);
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize + cellGap / 2,
          r * cellSize + cellGap / 2,
          cellSize - cellGap,
          cellSize - cellGap,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), _cellPaint);
      }
    }
  }
}
