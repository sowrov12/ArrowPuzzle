/// Snapshot of everything we persist locally.
class StoredProgress {
  const StoredProgress({
    this.unlockedLevel = 1,
    this.highScores = const {},
  });

  /// Highest unlocked level (1-based).
  final int unlockedLevel;

  /// Best score per level id.
  final Map<int, int> highScores;
}

/// Storage backend interface, so the game logic doesn't depend on Hive and a
/// SQLite backend (or the Supabase sync in Task 4.1) can be added later.
abstract class ProgressStorage {
  Future<StoredProgress> load();
  Future<void> save(StoredProgress progress);
}

/// Non-persistent storage, handy for tests and as a fallback.
class MemoryProgressStorage implements ProgressStorage {
  StoredProgress _data = const StoredProgress();

  @override
  Future<StoredProgress> load() async => _data;

  @override
  Future<void> save(StoredProgress progress) async => _data = progress;
}
