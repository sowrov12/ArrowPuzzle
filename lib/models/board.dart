import 'direction.dart';
import 'tile.dart';

/// The puzzle grid: grid[row][col]. Empty cells are `null`.
class Board {
  Board(this.grid)
      : rows = grid.length,
        cols = grid.isEmpty ? 0 : grid.first.length {
    for (final row in grid) {
      if (row.length != cols) {
        throw ArgumentError('Board must be rectangular.');
      }
    }
  }

  /// Builds a board from a text layout, one string per row:
  /// '^' up, 'v' down, '<' left, '>' right, '.' empty.
  /// Tile ids are generated as "r{row}c{col}".
  factory Board.fromLayout(List<String> layout) {
    final grid = <List<Tile?>>[];
    for (var r = 0; r < layout.length; r++) {
      final row = <Tile?>[];
      for (var c = 0; c < layout[r].length; c++) {
        final ch = layout[r][c];
        final Direction? direction;
        switch (ch) {
          case '^':
            direction = Direction.up;
          case 'v':
            direction = Direction.down;
          case '<':
            direction = Direction.left;
          case '>':
            direction = Direction.right;
          case '.':
            direction = null;
          default:
            throw ArgumentError(
                'Invalid layout character "$ch" at row $r, col $c.');
        }
        row.add(direction == null
            ? null
            : Tile(id: 'r${r}c$c', direction: direction));
      }
      grid.add(row);
    }
    return Board(grid);
  }

  final List<List<Tile?>> grid;
  final int rows;
  final int cols;

  bool inBounds(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  /// Returns the tile at (row, col), or null if empty or out of bounds.
  Tile? tileAt(int row, int col) => inBounds(row, col) ? grid[row][col] : null;

  /// Number of arrows currently on the board.
  int get tileCount => grid
      .expand((row) => row)
      .where((tile) => tile != null && tile.isOccupied)
      .length;
}
