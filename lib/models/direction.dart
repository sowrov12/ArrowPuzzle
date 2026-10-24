import 'dart:math' as math;

/// The four directions an arrow tile can face.
enum Direction {
  up,
  down,
  left,
  right;

  /// Row delta when moving one cell in this direction (used by Task 1.2).
  int get dRow => switch (this) {
        Direction.up => -1,
        Direction.down => 1,
        Direction.left => 0,
        Direction.right => 0,
      };

  /// Column delta when moving one cell in this direction (used by Task 1.2).
  int get dCol => switch (this) {
        Direction.up => 0,
        Direction.down => 0,
        Direction.left => -1,
        Direction.right => 1,
      };

  /// Rotation (radians) relative to an arrow drawn pointing UP.
  double get angle => switch (this) {
        Direction.up => 0,
        Direction.right => math.pi / 2,
        Direction.down => math.pi,
        Direction.left => -math.pi / 2,
      };

  /// Matches the spec's schema: 'UP' | 'DOWN' | 'LEFT' | 'RIGHT'.
  String toJson() => name.toUpperCase();

  static Direction fromJson(String value) => Direction.values.firstWhere(
        (d) => d.name.toUpperCase() == value.toUpperCase(),
        orElse: () => throw ArgumentError('Unknown direction: $value'),
      );
}
