import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show FontWeight, TextStyle;

/// Simple HUD button that requests a hint and shows how many are left.
class HintButtonComponent extends PositionComponent with TapCallbacks {
  HintButtonComponent({required this.onPressed, required this.hintsLeft})
      : super(size: Vector2(76, 36));

  final void Function() onPressed;
  int hintsLeft;

  static const double margin = 16;

  static final Paint _enabled = Paint()..color = const Color(0xFFF59E0B);
  static final Paint _disabled = Paint()..color = const Color(0xFF3A4054);
  static final TextPaint _text = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
  );

  /// Places the button in the top-right corner of the HUD strip.
  void layout(Vector2 available, double hudHeight) {
    position = Vector2(
      available.x - size.x - margin,
      (hudHeight - size.y) / 2,
    );
  }

  @override
  void onTapDown(TapDownEvent event) => onPressed();

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      hintsLeft > 0 ? _enabled : _disabled,
    );
    _text.render(
      canvas,
      'Hint $hintsLeft',
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
