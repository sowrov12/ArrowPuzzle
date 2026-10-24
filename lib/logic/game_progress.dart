import 'package:flutter/foundation.dart';

import '../levels/level_data.dart';

/// Which levels the player has unlocked. In-memory for now; Task 3.1 will
/// persist this with Hive/SQLite.
class GameProgress extends ChangeNotifier {
  GameProgress({required this.totalLevels}) : assert(totalLevels > 0);

  final int totalLevels;
  int _unlockedLevel = 1;

  /// Highest level the player may play (1-based).
  int get unlockedLevel => _unlockedLevel;

  bool isUnlocked(int levelId) => levelId >= 1 && levelId <= _unlockedLevel;

  /// Call when a level is won. Unlocks the next level if this was the
  /// furthest one reached.
  void completeLevel(int levelId) {
    if (levelId == _unlockedLevel && _unlockedLevel < totalLevels) {
      _unlockedLevel++;
      notifyListeners();
    }
  }
}

/// App-wide progress instance.
final GameProgress gameProgress = GameProgress(totalLevels: Levels.all.length);
