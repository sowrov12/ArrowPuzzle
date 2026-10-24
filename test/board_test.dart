import 'package:arrow_puzzle/levels/sample_level.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board.fromLayout', () {
    test('builds correct dimensions and tile count', () {
      final board = Board.fromLayout(['>.v', '^<.']);
      expect(board.rows, 2);
      expect(board.cols, 3);
      expect(board.tileCount, 4);
    });

    test('maps characters to directions and empty cells to null', () {
      final board = Board.fromLayout(['>.v', '^<.']);
      expect(board.tileAt(0, 0)!.direction, Direction.right);
      expect(board.tileAt(0, 1), isNull);
      expect(board.tileAt(0, 2)!.direction, Direction.down);
      expect(board.tileAt(1, 0)!.direction, Direction.up);
      expect(board.tileAt(1, 1)!.direction, Direction.left);
    });

    test('tiles start occupied with deterministic ids', () {
      final board = Board.fromLayout(['>']);
      final tile = board.tileAt(0, 0)!;
      expect(tile.id, 'r0c0');
      expect(tile.isOccupied, isTrue);
    });

    test('tileAt returns null out of bounds', () {
      final board = Board.fromLayout(['>']);
      expect(board.tileAt(-1, 0), isNull);
      expect(board.tileAt(0, 1), isNull);
      expect(board.tileAt(1, 0), isNull);
    });

    test('throws on ragged layouts and invalid characters', () {
      expect(() => Board.fromLayout(['>>', '>']), throwsArgumentError);
      expect(() => Board.fromLayout(['>x']), throwsArgumentError);
    });

    test('sample level is a 5x5 board', () {
      final board = Board.fromLayout(sampleLevelLayout);
      expect(board.rows, 5);
      expect(board.cols, 5);
    });
  });

  group('Direction', () {
    test('JSON round trip matches spec strings', () {
      expect(Direction.up.toJson(), 'UP');
      expect(Direction.fromJson('LEFT'), Direction.left);
      expect(() => Direction.fromJson('DIAGONAL'), throwsArgumentError);
    });

    test('row/col deltas point the right way', () {
      expect((Direction.up.dRow, Direction.up.dCol), (-1, 0));
      expect((Direction.down.dRow, Direction.down.dCol), (1, 0));
      expect((Direction.left.dRow, Direction.left.dCol), (0, -1));
      expect((Direction.right.dRow, Direction.right.dCol), (0, 1));
    });
  });
}
