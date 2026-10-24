import 'package:arrow_puzzle/logic/path_checker.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PathResult check(List<String> layout, int r, int c) =>
      PathChecker.check(Board.fromLayout(layout), r, c);

  group('clear paths', () {
    test('arrow on the edge facing outward is clear', () {
      expect(check(['<'], 0, 0), PathResult.clearPath);
      expect(check(['>'], 0, 0), PathResult.clearPath);
      expect(check(['^'], 0, 0), PathResult.clearPath);
      expect(check(['v'], 0, 0), PathResult.clearPath);
    });

    test('empty cells between arrow and edge do not block', () {
      expect(check(['>...'], 0, 0), PathResult.clearPath);
      expect(check(['...<'], 0, 3), PathResult.clearPath);
    });

    test('arrows behind or beside the tapped one do not block', () {
      expect(check(['<>>'], 0, 2), PathResult.clearPath);
      expect(check(['.^.', '...', '.v.'], 0, 1), PathResult.clearPath);
    });
  });

  group('collisions', () {
    test('adjacent blocker', () {
      expect(check(['>>'], 0, 0), PathResult.collisionDetected);
    });

    test('distant blocker with gap', () {
      expect(check(['>.<'], 0, 0), PathResult.collisionDetected);
    });

    test('works in all four directions', () {
      const layout = ['.v.', '...', '.^.'];
      expect(check(layout, 0, 1), PathResult.collisionDetected); // down
      expect(check(layout, 2, 1), PathResult.collisionDetected); // up
      expect(check(['<.>'], 0, 2), PathResult.clearPath);
      expect(check(['>.<'], 0, 2), PathResult.collisionDetected); // left
    });

    test('removed (unoccupied) tiles stop blocking', () {
      final board = Board.fromLayout(['>.<']);
      expect(PathChecker.check(board, 0, 0), PathResult.collisionDetected);
      board.tileAt(0, 2)!.isOccupied = false;
      expect(PathChecker.check(board, 0, 0), PathResult.clearPath);
    });
  });

  test('throws when the cell has no arrow', () {
    expect(() => check(['.>'], 0, 0), throwsArgumentError);
  });
}
