import 'package:arrow_puzzle/levels/sample_level.dart';
import 'package:arrow_puzzle/logic/path_checker.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

/// Removes every currently-free arrow, repeatedly, until none are free.
/// Returns how many arrows were removed.
int clearGreedily(Board board) {
  var removed = 0;
  var progress = true;
  while (progress) {
    progress = false;
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final tile = board.tileAt(r, c);
        if (tile != null &&
            tile.isOccupied &&
            PathChecker.check(board, r, c) == PathResult.clearPath) {
          tile.isOccupied = false;
          removed++;
          progress = true;
        }
      }
    }
  }
  return removed;
}

void main() {
  test('sample level is solvable: removing free arrows clears the board', () {
    final board = Board.fromLayout(sampleLevelLayout);
    final total = board.tileCount;
    expect(board.isCleared, isFalse);

    final removed = clearGreedily(board);

    expect(removed, total);
    expect(board.isCleared, isTrue);
  });

  test('a deadlocked layout never reaches the win state', () {
    // Two arrows pointing at each other block one another forever.
    final board = Board.fromLayout(['><']);
    clearGreedily(board);
    expect(board.isCleared, isFalse);
    expect(board.tileCount, 2);
  });

  test('blocked arrow becomes free once its blocker is removed', () {
    final board = Board.fromLayout(['>^']);
    expect(PathChecker.check(board, 0, 0), PathResult.collisionDetected);
    board.tileAt(0, 1)!.isOccupied = false; // the "^" leaves upward
    expect(PathChecker.check(board, 0, 0), PathResult.clearPath);
  });
}
