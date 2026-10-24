import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'progress_storage.dart';

/// Stores progress in a Hive box using plain values (no adapters needed):
///   unlockedLevel -> int
///   highScores    -> Map<String, int>   (level id as string)
class HiveProgressStorage implements ProgressStorage {
  HiveProgressStorage._(this._box);

  static const String boxName = 'arrow_puzzle_progress';
  static const String _unlockedKey = 'unlockedLevel';
  static const String _scoresKey = 'highScores';

  final Box<dynamic> _box;

  /// Opens the box in the app's documents directory (use this in main()).
  static Future<HiveProgressStorage> open() async {
    await Hive.initFlutter();
    return HiveProgressStorage._(await Hive.openBox<dynamic>(boxName));
  }

  /// Opens the box in a custom directory (used by unit tests).
  static Future<HiveProgressStorage> openAt(String path) async {
    Hive.init(path);
    return HiveProgressStorage._(await Hive.openBox<dynamic>(boxName));
  }

  Future<void> close() => _box.close();

  @override
  Future<StoredProgress> load() async {
    try {
      final unlocked = _box.get(_unlockedKey, defaultValue: 1);
      final rawScores = _box.get(_scoresKey, defaultValue: const {});
      final scores = <int, int>{};
      if (rawScores is Map) {
        rawScores.forEach((key, value) {
          final id = int.tryParse(key.toString());
          if (id != null && value is int) scores[id] = value;
        });
      }
      return StoredProgress(
        unlockedLevel: unlocked is int && unlocked >= 1 ? unlocked : 1,
        highScores: scores,
      );
    } catch (e) {
      // Corrupted data must never stop the game from starting.
      debugPrint('Could not read saved progress, starting fresh: $e');
      return const StoredProgress();
    }
  }

  @override
  Future<void> save(StoredProgress progress) async {
    await _box.put(_unlockedKey, progress.unlockedLevel);
    await _box.put(
      _scoresKey,
      progress.highScores.map((id, score) => MapEntry(id.toString(), score)),
    );
  }
}
