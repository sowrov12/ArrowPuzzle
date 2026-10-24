import 'dart:ui';

import 'package:flame/components.dart';

/// HUD row of hearts: filled = remaining, dim = lost.
class HeartsComponent extends PositionComponent {
  HeartsComponent({required this.maxHearts, int? hearts})
      : hearts = hearts ?? maxHearts;

  /// Vertical space the HUD occupies at the top of the screen.
  static const double hudHeight = 56;
  static const double heartSize = 32;
  static const double gap = 8;

  final int maxHearts;

  /// Number of filled hearts to draw.
  int hearts;

  static final Paint _full = Paint()..color = const Color(0xFFEF4444);
  static final Paint _empty = Paint()..color = const Color(0xFF3A4054);

  /// Centers the row at the top of the screen.
  void layout(Vector2 available) {
    size = Vector2(maxHearts * heartSize + (maxHearts - 1) * gap, heartSize);
    position = Vector2(
      (available.x - size.x) / 2,
      (hudHeight - heartSize) / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < maxHearts; i++) {
      canvas.drawPath(
        _heartPath(i * (heartSize + gap), 0, heartSize),
        i < hearts ? _full : _empty,
      );
    }
  }

  static Path _heartPath(double x, double y, double s) {
    Offset p(double px, double py) => Offset(x + px * s, y + py * s);
    return Path()
      ..moveTo(p(0.5, 0.92).dx, p(0.5, 0.92).dy)
      ..cubicTo(p(0.05, 0.62).dx, p(0.05, 0.62).dy, p(0.0, 0.30).dx,
          p(0.0, 0.30).dy, p(0.22, 0.14).dx, p(0.22, 0.14).dy)
      ..cubicTo(p(0.36, 0.04).dx, p(0.36, 0.04).dy, p(0.50, 0.14).dx,
          p(0.50, 0.14).dy, p(0.50, 0.30).dx, p(0.50, 0.30).dy)
      ..cubicTo(p(0.50, 0.14).dx, p(0.50, 0.14).dy, p(0.64, 0.04).dx,
          p(0.64, 0.04).dy, p(0.78, 0.14).dx, p(0.78, 0.14).dy)
      ..cubicTo(p(1.0, 0.30).dx, p(1.0, 0.30).dy, p(0.95, 0.62).dx,
          p(0.95, 0.62).dy, p(0.5, 0.92).dx, p(0.5, 0.92).dy)
      ..close();
  }
}
