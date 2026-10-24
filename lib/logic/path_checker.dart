import '../models/board.dart';

/// Outcome of a trajectory check (names mirror the spec's
/// COLLISION_DETECTED / CLEAR_PATH).
enum PathResult { clearPath, collisionDetected }

class PathChecker {
  const PathChecker._();

  /// Raycasts from the tile at ([row], [col]) one cell at a time along its
  /// facing direction until the grid boundary. Any occupied cell on the way
  /// blocks the arrow.
  static PathResult check(Board board, int row, int col) {
    final tile = board.tileAt(row, col);
    if (tile == null || !tile.isOccupied) {
      throw ArgumentError('No arrow at row $row, col $col.');
    }

    final dRow = tile.direction.dRow;
    final dCol = tile.direction.dCol;
    var r = row + dRow;
    var c = col + dCol;

    while (board.inBounds(r, c)) {
      final blocker = board.grid[r][c];
      if (blocker != null && blocker.isOccupied) {
        return PathResult.collisionDetected;
      }
      r += dRow;
      c += dCol;
    }
    return PathResult.clearPath;
  }
}
