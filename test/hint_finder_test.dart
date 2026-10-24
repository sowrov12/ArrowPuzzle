import 'package:arrow_puzzle/levels/sample_level.dart';
import 'package:arrow_puzzle/logic/hint_finder.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the first free arrow in row-major order', () {
    final board = Board.fromLayout(['>>.', '...']);
    // (0,0) is blocked by (0,1); (0,1) faces the edge with a free path.
    expect(HintFinder.find(board), (row: 0, col: 1));
  });

  test('returns null when every arrow is blocked', () {
    final board = Board.fromLayout(['><']);
    expect(HintFinder.find(board), isNull);
  });

  test('returns null on a cleared board', () {
    final board = Board.fromLayout(['>']);
    board.tileAt(0, 0)!.isOccupied = false;
    expect(HintFinder.find(board), isNull);
  });

  test('ignores removed tiles that sit in the scan order', () {
    final board = Board.fromLayout(['^^']);
    board.tileAt(0, 0)!.isOccupied = false;
    expect(HintFinder.find(board), (row: 0, col: 1));
  });

  test('following hints always clears a solvable level', () {
    final board = Board.fromLayout(sampleLevelLayout);
    var steps = 0;
    var hint = HintFinder.find(board);
    while (hint != null) {
      board.tileAt(hint.row, hint.col)!.isOccupied = false;
      steps++;
      hint = HintFinder.find(board);
    }
    expect(board.isCleared, isTrue);
    expect(steps, greaterThan(0));
  });
}
