import 'package:arrow_puzzle/logic/lives.dart';
import 'package:arrow_puzzle/logic/path_checker.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lives', () {
    test('starts with 3 hearts', () {
      final lives = Lives();
      expect(lives.hearts, 3);
      expect(lives.isEmpty, isFalse);
    });

    test('loseHeart decrements and empties after 3 losses', () {
      final lives = Lives();
      expect(lives.loseHeart(), isTrue);
      expect(lives.hearts, 2);
      lives.loseHeart();
      expect(lives.isEmpty, isFalse);
      lives.loseHeart();
      expect(lives.hearts, 0);
      expect(lives.isEmpty, isTrue);
    });

    test('never goes below zero', () {
      final lives = Lives(maxHearts: 1);
      lives.loseHeart();
      expect(lives.loseHeart(), isFalse);
      expect(lives.hearts, 0);
    });

    test('reset restores all hearts', () {
      final lives = Lives()..loseHeart();
      lives.reset();
      expect(lives.hearts, 3);
    });
  });

  test('three blocked taps drain the hearts; clear taps do not', () {
    final board = Board.fromLayout(['>>.', '..<']);
    final lives = Lives();

    // (0,0) is blocked by (0,1); (1,2) faces left across an empty row.
    for (var i = 0; i < 3; i++) {
      if (PathChecker.check(board, 0, 0) == PathResult.collisionDetected) {
        lives.loseHeart();
      }
    }
    expect(lives.isEmpty, isTrue);

    final fresh = Lives();
    if (PathChecker.check(board, 1, 2) == PathResult.collisionDetected) {
      fresh.loseHeart();
    }
    expect(fresh.hearts, 3);
  });
}
