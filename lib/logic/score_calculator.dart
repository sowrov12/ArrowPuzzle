import 'dart:math' as math;

/// Placeholder scoring rule (the specs don't define one yet):
/// reward clearing more arrows and keeping hearts, penalise hints.
/// Task 4.1 will validate scores server-side before they hit the leaderboard.
class ScoreCalculator {
  const ScoreCalculator._();

  static const int pointsPerArrow = 100;
  static const int pointsPerHeart = 250;
  static const int hintPenalty = 50;

  static int calculate({
    required int arrowCount,
    required int heartsLeft,
    required int hintsUsed,
  }) {
    final raw = arrowCount * pointsPerArrow +
        heartsLeft * pointsPerHeart -
        hintsUsed * hintPenalty;
    return math.max(0, raw);
  }
}
