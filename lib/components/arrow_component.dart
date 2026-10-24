import 'dart:ui';

import 'package:flame/components.dart';

import '../models/direction.dart';
import '../models/tile.dart';

/// Draws one arrow tile. The arrow is drawn pointing UP and rotated about
/// its center according to the tile's direction.
class ArrowComponent extends PositionComponent {
  ArrowComponent({
    required this.tile,
    required this.row,
    required this.col,
  }) : super(anchor: Anchor.center, angle: tile.direction.angle);

  final Tile tile;
  final int row;
  final int col;

  static final Paint _arrowPaint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  void render(Canvas canvas) {
    final s = size.x;

    // Tile background (rotates with the component; it is symmetric so fine).
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, size.y),
      Radius.circular(s * 0.18),
    );
    canvas.drawRRect(bg, Paint()..color = _tileColor(tile.direction));

    // Arrow pointing up.
    final path = Path()
      ..moveTo(s * 0.50, s * 0.14)
      ..lineTo(s * 0.78, s * 0.50)
      ..lineTo(s * 0.60, s * 0.50)
      ..lineTo(s * 0.60, s * 0.86)
      ..lineTo(s * 0.40, s * 0.86)
      ..lineTo(s * 0.40, s * 0.50)
      ..lineTo(s * 0.22, s * 0.50)
      ..close();
    canvas.drawPath(path, _arrowPaint);
  }

  static Color _tileColor(Direction d) => switch (d) {
        Direction.up => const Color(0xFF3B82F6),
        Direction.down => const Color(0xFFEF4444),
        Direction.left => const Color(0xFF10B981),
        Direction.right => const Color(0xFFF59E0B),
      };
}
