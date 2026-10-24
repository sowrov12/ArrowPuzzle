import '../models/board.dart';
import 'sample_level.dart';

/// One puzzle level. Layout characters: ^ v < > = arrows, . = empty.
class LevelData {
  const LevelData({required this.id, required this.layout});

  final int id;
  final List<String> layout;

  int get rows => layout.length;
  int get cols => layout.first.length;

  /// Always builds a fresh board (tiles are mutable during play).
  Board createBoard() => Board.fromLayout(layout);
}

/// Built-in starter levels (all solvable, growing grid sizes).
/// Task 3.2 replaces this with 50 levels loaded from JSON.
class Levels {
  const Levels._();

  static const List<LevelData> all = [
    LevelData(id: 1, layout: sampleLevelLayout),
    LevelData(id: 2, layout: ['v<<<', '.^<<', '>..>', '<v..']),
    LevelData(id: 3, layout: ['<.<^^', '.v^..', 'v<v..', 'v>>.>']),
    LevelData(id: 4, layout: ['<^<<.', '>..^^', '>.^v.', '..>v^', '>..>.']),
    LevelData(
      id: 5,
      layout: ['<^^v^.', '^.v>>>', '.^>.>^', 'v^v.^^', 'vvv>^^'],
    ),
    LevelData(
      id: 6,
      layout: ['^.<<^<', '<<...<', '<..v^^', 'v^.<<<', '..v..>', 'v.v<.v'],
    ),
    LevelData(
      id: 7,
      layout: ['v^v>^v', 'v.<>>v', '>.>.>.', '.v.>.v', 'v.<...', '<v..v<'],
    ),
    LevelData(
      id: 8,
      layout: [
        '<^v>^>^',
        'vvv<<.<',
        '.<v<>.^',
        '<>>..vv',
        'v<>..>v',
        '<..^>..',
      ],
    ),
    LevelData(
      id: 9,
      layout: [
        '.^vv>.>',
        '^v..<>.',
        'vv.vv.>',
        '..vv.<^',
        '<.v>.v.',
        '<...<>v',
        '>.>>.>v',
      ],
    ),
  ];

  static LevelData? byId(int id) {
    for (final level in all) {
      if (level.id == id) return level;
    }
    return null;
  }

  /// The level after [id], or null if [id] is the last one.
  static LevelData? nextAfter(int id) => byId(id + 1);
}
