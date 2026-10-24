import 'package:arrow_puzzle/levels/level_data.dart';
import 'package:arrow_puzzle/logic/game_progress.dart';
import 'package:arrow_puzzle/logic/hint_finder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Levels', () {
    test('ids are sequential starting at 1', () {
      for (var i = 0; i < Levels.all.length; i++) {
        expect(Levels.all[i].id, i + 1);
      }
    });

    test('every level builds a rectangular, non-empty board', () {
      for (final level in Levels.all) {
        final board = level.createBoard();
        expect(board.tileCount, greaterThan(0), reason: 'level ${level.id}');
        expect(board.rows, level.rows);
        expect(board.cols, level.cols);
      }
    });

    test('every level is solvable', () {
      for (final level in Levels.all) {
        final board = level.createBoard();
        var hint = HintFinder.find(board);
        while (hint != null) {
          board.tileAt(hint.row, hint.col)!.isOccupied = false;
          hint = HintFinder.find(board);
        }
        expect(board.isCleared, isTrue, reason: 'level ${level.id}');
      }
    });

    test('nextAfter returns the following level, null after the last', () {
      expect(Levels.nextAfter(1)!.id, 2);
      expect(Levels.nextAfter(Levels.all.length), isNull);
    });
  });

  group('GameProgress', () {
    test('only level 1 is unlocked at the start', () {
      final p = GameProgress(totalLevels: 3);
      expect(p.isUnlocked(1), isTrue);
      expect(p.isUnlocked(2), isFalse);
    });

    test('completing the furthest level unlocks the next', () {
      final p = GameProgress(totalLevels: 3);
      p.completeLevel(1);
      expect(p.unlockedLevel, 2);
      expect(p.isUnlocked(2), isTrue);
    });

    test('replaying an earlier level or skipping ahead changes nothing', () {
      final p = GameProgress(totalLevels: 5);
      p.completeLevel(1); // unlocked: 2
      p.completeLevel(1); // replay
      p.completeLevel(4); // cannot skip
      expect(p.unlockedLevel, 2);
    });

    test('never unlocks beyond the last level', () {
      final p = GameProgress(totalLevels: 2);
      p.completeLevel(1);
      p.completeLevel(2);
      expect(p.unlockedLevel, 2);
    });

    test('notifies listeners only when something unlocks', () {
      final p = GameProgress(totalLevels: 2);
      var calls = 0;
      p.addListener(() => calls++);
      p.completeLevel(1);
      p.completeLevel(1);
      expect(calls, 1);
    });
  });
}
