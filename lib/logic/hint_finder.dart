import '../models/board.dart';
import 'path_checker.dart';

typedef CellPosition = ({int row, int col});

class HintFinder {
  const HintFinder._();

  /// Scans the grid (row by row) and returns the first arrow whose path to
  /// the boundary is unobstructed, or null if every arrow is blocked.
  ///
  /// Removing a free arrow can never block another arrow, so any free arrow
  /// is a safe hint: following hints always leads to a cleared board on a
  /// solvable level.
  static CellPosition? find(Board board) {
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final tile = board.tileAt(r, c);
        if (tile != null &&
            tile.isOccupied &&
            PathChecker.check(board, r, c) == PathResult.clearPath) {
          return (row: r, col: c);
        }
      }
    }
    return null;
  }
}
