import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../levels/level_data.dart';
import '../storage/progress_storage.dart';

/// Unlocked levels and high scores. Optionally backed by a [ProgressStorage]
/// (Hive in the app); changes are saved automatically.
class GameProgress extends ChangeNotifier {
  GameProgress({
    required this.totalLevels,
    this.storage,
    int unlockedLevel = 1,
    Map<int, int>? highScores,
  })  : assert(totalLevels > 0),
        _unlockedLevel = unlockedLevel,
        _highScores = {...?highScores};

  /// Loads saved progress from [storage].
  static Future<GameProgress> load({
    required int totalLevels,
    required ProgressStorage storage,
  }) async {
    final saved = await storage.load();
    return GameProgress(
      totalLevels: totalLevels,
      storage: storage,
      // Clamp in case levels were removed since the data was saved.
      unlockedLevel: math.max(1, math.min(totalLevels, saved.unlockedLevel)),
      highScores: saved.highScores,
    );
  }

  final int totalLevels;
  final ProgressStorage? storage;
  int _unlockedLevel;
  final Map<int, int> _highScores;

  /// Highest level the player may play (1-based).
  int get unlockedLevel => _unlockedLevel;

  bool isUnlocked(int levelId) => levelId >= 1 && levelId <= _unlockedLevel;

  /// Best score for [levelId], or 0 if never completed.
  int highScoreFor(int levelId) => _highScores[levelId] ?? 0;

  /// Call when a level is won. Unlocks the next level if this was the
  /// furthest one reached.
  void completeLevel(int levelId) {
    if (levelId == _unlockedLevel && _unlockedLevel < totalLevels) {
      _unlockedLevel++;
      _persist();
      notifyListeners();
    }
  }

  /// Records [score] if it beats the saved best. Returns true on a new best.
  bool submitScore(int levelId, int score) {
    if (score <= highScoreFor(levelId)) return false;
    _highScores[levelId] = score;
    _persist();
    notifyListeners();
    return true;
  }

  void _persist() {
    final s = storage;
    if (s == null) return;
    unawaited(
      s
          .save(StoredProgress(
            unlockedLevel: _unlockedLevel,
            highScores: Map.of(_highScores),
          ))
          .catchError((Object e) {
        debugPrint('Could not save progress: $e');
      }),
    );
  }
}

/// App-wide progress. Starts in-memory; main() swaps in the loaded,
/// Hive-backed instance before the UI is built.
GameProgress gameProgress = GameProgress(totalLevels: Levels.all.length);
