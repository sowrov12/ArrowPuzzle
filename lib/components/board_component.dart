import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../models/board.dart';
import 'arrow_component.dart';

/// Renders the grid and owns one [ArrowComponent] per tile.
/// Call [layout] whenever the available screen size changes.
class BoardComponent extends PositionComponent {
  BoardComponent(this.board) {
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final tile = board.tileAt(r, c);
        if (tile != null) {
          _arrows.add(ArrowComponent(tile: tile, row: r, col: c));
        }
      }
    }
  }

  static const double screenPadding = 16;
  static const double cellGap = 4;

  final Board board;
  final List<ArrowComponent> _arrows = [];

  double cellSize = 0;

  static final Paint _cellPaint = Paint()..color = const Color(0xFF262B3A);

  @override
  Future<void> onLoad() async {
    await addAll(_arrows);
  }

  /// Fits the board inside [available] (the full game size), centered,
  /// and positions every arrow.
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
