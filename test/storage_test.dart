import 'dart:io';

import 'package:arrow_puzzle/logic/game_progress.dart';
import 'package:arrow_puzzle/logic/score_calculator.dart';
import 'package:arrow_puzzle/storage/hive_progress_storage.dart';
import 'package:arrow_puzzle/storage/progress_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('ScoreCalculator', () {
    test('rewards arrows and hearts, penalises hints', () {
      expect(
        ScoreCalculator.calculate(arrowCount: 10, heartsLeft: 3, hintsUsed: 0),
        10 * 100 + 3 * 250,
      );
      expect(
        ScoreCalculator.calculate(arrowCount: 10, heartsLeft: 1, hintsUsed: 2),
        10 * 100 + 250 - 100,
      );
    });

    test('never negative', () {
      expect(
        ScoreCalculator.calculate(arrowCount: 0, heartsLeft: 0, hintsUsed: 5),
        0,
      );
    });
  });

  group('GameProgress with storage', () {
    test('restores saved unlocked level and high scores', () async {
      final storage = MemoryProgressStorage();
      await storage.save(const StoredProgress(
        unlockedLevel: 4,
        highScores: {1: 900, 3: 1500},
      ));

      final p = await GameProgress.load(totalLevels: 9, storage: storage);
      expect(p.unlockedLevel, 4);
      expect(p.highScoreFor(1), 900);
      expect(p.highScoreFor(2), 0);
      expect(p.highScoreFor(3), 1500);
    });

    test('clamps a saved level that no longer exists', () async {
      final storage = MemoryProgressStorage();
      await storage.save(const StoredProgress(unlockedLevel: 99));
      final p = await GameProgress.load(totalLevels: 5, storage: storage);
      expect(p.unlockedLevel, 5);
    });

    test('changes are written back to storage', () async {
      final storage = MemoryProgressStorage();
      final p = await GameProgress.load(totalLevels: 5, storage: storage);

      p.completeLevel(1);
      p.submitScore(1, 1200);
      await Future<void>.delayed(Duration.zero); // let fire-and-forget save run

      final saved = await storage.load();
      expect(saved.unlockedLevel, 2);
      expect(saved.highScores, {1: 1200});
    });

    test('submitScore only accepts improvements', () {
      final p = GameProgress(totalLevels: 3);
      expect(p.submitScore(1, 500), isTrue);
      expect(p.submitScore(1, 400), isFalse);
      expect(p.submitScore(1, 500), isFalse);
      expect(p.submitScore(1, 900), isTrue);
      expect(p.highScoreFor(1), 900);
    });
  });

  group('HiveProgressStorage', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('arrow_hive_'));

    tearDown(() async {
      await Hive.close();
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    test('starts with defaults when nothing is saved', () async {
      final storage = await HiveProgressStorage.openAt(dir.path);
      final loaded = await storage.load();
      expect(loaded.unlockedLevel, 1);
      expect(loaded.highScores, isEmpty);
    });

    test('data survives closing and reopening the box', () async {
      var storage = await HiveProgressStorage.openAt(dir.path);
      await storage.save(const StoredProgress(
        unlockedLevel: 3,
        highScores: {1: 1100, 2: 1350},
      ));
      await storage.close();

      storage = await HiveProgressStorage.openAt(dir.path);
      final loaded = await storage.load();
      expect(loaded.unlockedLevel, 3);
      expect(loaded.highScores, {1: 1100, 2: 1350});
    });
  });
}
