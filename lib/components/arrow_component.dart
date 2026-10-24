import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../models/direction.dart';
import '../models/tile.dart';

/// Draws one arrow tile and reports taps. The arrow is drawn pointing UP and
/// rotated about its center according to the tile's direction.
class ArrowComponent extends PositionComponent with TapCallbacks {
  ArrowComponent({
    required this.tile,
    required this.row,
    required this.col,
    this.onTap,
  }) : super(anchor: Anchor.center, angle: tile.direction.angle);

  final Tile tile;
  final int row;
  final int col;

  /// Called when the player taps this arrow.
  final void Function(ArrowComponent arrow)? onTap;

  static const double _flashDuration = 0.25;
  Color _flashColor = const Color(0x00000000);
  double _flashTimer = 0;

  static final Paint _arrowPaint = Paint()..color = const Color(0xFFFFFFFF);

  /// Brief colored overlay so taps are visible before Task 1.3 (removal
  /// animation) and Task 2.1 (hearts) add real feedback.
  void flash(Color color) {
    _flashColor = color;
    _flashTimer = _flashDuration;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap?.call(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer = (_flashTimer - dt).clamp(0, _flashDuration);
    }
  }

  @override
  void render(Canvas canvas) {
    final s = size.x;
    final bg = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, size.y),
      Radius.circular(s * 0.18),
    );
    canvas.drawRRect(bg, Paint()..color = _tileColor(tile.direction));

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

    if (_flashTimer > 0) {
      final alpha = (160 * (_flashTimer / _flashDuration)).round();
      canvas.drawRRect(bg, Paint()..color = _flashColor.withAlpha(alpha));
    }
  }

  static Color _tileColor(Direction d) => switch (d) {
        Direction.up => const Color(0xFF3B82F6),
        Direction.down => const Color(0xFFEF4444),
        Direction.left => const Color(0xFF10B981),
        Direction.right => const Color(0xFFF59E0B),
      };
}
