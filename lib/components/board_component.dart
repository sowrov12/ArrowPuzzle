import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../logic/path_checker.dart';
import '../models/board.dart';
import 'arrow_component.dart';

typedef ArrowTapCallback = void Function(
    ArrowComponent arrow, PathResult result);

/// Renders the grid and owns one [ArrowComponent] per tile.
/// Call [layout] whenever the available screen size changes.
class BoardComponent extends PositionComponent {
  BoardComponent(this.board, {this.onArrowTapped}) {
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

  static const Color _clearFlash = Color(0xFF22C55E);
  static const Color _collisionFlash = Color(0xFFFF2D2D);

  final Board board;

  /// Notified after every tap with the path-check result.
  final ArrowTapCallback? onArrowTapped;

  final List<ArrowComponent> _arrows = [];
  double cellSize = 0;

  static final Paint _cellPaint = Paint()..color = const Color(0xFF262B3A);

  void _handleTap(ArrowComponent arrow) {
    final result = PathChecker.check(board, arrow.row, arrow.col);
    arrow.flash(
      result == PathResult.clearPath ? _clearFlash : _collisionFlash,
    );
    onArrowTapped?.call(arrow, result);
  }

  @override
  Future<void> onLoad() async {
    await addAll(_arrows);
  }

  void layout(Vector2 available) {
    final usableW = available.x - screenPadding * 2;
    final usableH = available.y - screenPadding * 2;
    if (usableW <= 0 || usableH <= 0 || board.rows == 0 || board.cols == 0) {
      return;
    }

    cellSize = math.min(usableW / board.cols, usableH / board.rows);
    size = Vector2(cellSize * board.cols, cellSize * board.rows);
    position = Vector2(
      (available.x - size.x) / 2,
      (available.y - size.y) / 2,
    );

    for (final arrow in _arrows) {
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
