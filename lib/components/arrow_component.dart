import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart' show Curves;

import '../models/direction.dart';
import '../models/tile.dart';

/// Draws one arrow tile, reports taps, and can slide itself off the board.
/// The arrow is drawn pointing UP and rotated about its center.
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

  /// True from the moment the removal animation starts.
  bool isRemoving = false;

  static const double _flashDuration = 0.25;
  static const double slideDuration = 0.4;
  Color _flashColor = const Color(0x00000000);
  double _flashTimer = 0;

  static const double hintDuration = 4;
  double _hintTimer = 0;
  double _hintElapsed = 0;

  static final Paint _arrowPaint = Paint()..color = const Color(0xFFFFFFFF);

  /// Brief colored overlay, used for blocked taps.
  void flash(Color color) {
    _flashColor = color;
    _flashTimer = _flashDuration;
  }

  bool get isHinted => _hintTimer > 0;

  /// Pulsing highlight telling the player this arrow can be tapped safely.
  void showHint() {
    _hintTimer = hintDuration;
    _hintElapsed = 0;
  }

  void clearHint() => _hintTimer = 0;

  /// Slides the arrow by [delta] (in board coordinates), then removes it from
  /// the tree and calls [onDone].
  void slideOff(Vector2 delta, {required void Function() onDone}) {
    isRemoving = true;
    clearHint();
    priority = 10; // draw above neighbours while leaving
    add(
      MoveEffect.by(
        delta,
        EffectController(duration: slideDuration, curve: Curves.easeIn),
        onComplete: () {
          removeFromParent();
          onDone();
        },
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    clearHint();
    onTap?.call(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer < 0) _flashTimer = 0;
    }
    if (_hintTimer > 0) {
      _hintTimer -= dt;
      _hintElapsed += dt;
      if (_hintTimer < 0) _hintTimer = 0;
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

    if (_hintTimer > 0) {
      final pulse = 0.5 + 0.5 * math.sin(_hintElapsed * 8);
      final ring = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, size.y).deflate(s * 0.04),
        Radius.circular(s * 0.16),
      );
      canvas.drawRRect(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.09
          ..color = Color(0xFFFFE066).withAlpha((120 + 135 * pulse).round()),
      );
    }
  }

  static Color _tileColor(Direction d) => switch (d) {
        Direction.up => const Color(0xFF3B82F6),
        Direction.down => const Color(0xFFEF4444),
        Direction.left => const Color(0xFF10B981),
        Direction.right => const Color(0xFFF59E0B),
      };
}
