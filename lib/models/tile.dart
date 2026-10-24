import 'direction.dart';

/// A single arrow tile. Mirrors the spec schema:
/// { id: string, direction: 'UP'|'DOWN'|'LEFT'|'RIGHT', isOccupied: boolean }
class Tile {
  Tile({
    required this.id,
    required this.direction,
    this.isOccupied = true,
  });

  final String id;
  final Direction direction;

  /// True while the arrow is on the board. Task 1.3 flips this when removed.
  bool isOccupied;

  @override
  String toString() => 'Tile($id, ${direction.toJson()}, occupied: $isOccupied)';
}
