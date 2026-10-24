import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/arrow_game.dart';
import '../levels/level_data.dart';
import '../logic/game_progress.dart';
import 'game_overlay_card.dart';

/// Hosts one level: the Flame game plus the pause button and the
/// Pause / Win / Lose overlays.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level});

  final LevelData level;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late LevelData _level;
  late ArrowGame _game;
  int _lastScore = 0;
  bool _newBest = false;

  @override
  void initState() {
    super.initState();
    _level = widget.level;
    _game = _createGame();
  }

  ArrowGame _createGame() {
    final levelId = _level.id;
    _lastScore = 0;
    _newBest = false;
    return ArrowGame(
      board: _level.createBoard(),
      onWin: (score) {
        _lastScore = score;
        _newBest = gameProgress.submitScore(levelId, score);
        gameProgress.completeLevel(levelId);
      },
    );
  }

  void _restart() => setState(() => _game = _createGame());

  void _goToLevel(LevelData level) => setState(() {
        _level = level;
        _game = _createGame();
      });

  void _exitToLevelSelect() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final next = Levels.nextAfter(_level.id);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1F2A),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget<ArrowGame>(
              key: ObjectKey(_game),
              game: _game,
              overlayBuilderMap: {
                ArrowGame.pauseOverlay: (context, game) => GameOverlayCard(
                      title: 'Paused',
                      message: 'Level ${_level.id}',
                      actions: [
                        OverlayButton(
                          label: 'Resume',
                          primary: true,
                          onPressed: game.resumeGame,
                        ),
                        OverlayButton(label: 'Restart', onPressed: _restart),
                        OverlayButton(
                          label: 'Level Select',
                          onPressed: _exitToLevelSelect,
                        ),
                      ],
                    ),
                ArrowGame.winOverlay: (context, game) => GameOverlayCard(
                      title: 'Level Clear!',
                      message: [
                        'Score: $_lastScore  ·  '
                            '${_newBest ? 'New best!' : 'Best: ${gameProgress.highScoreFor(_level.id)}'}',
                        '${game.lives.hearts} of ${ArrowGame.maxHearts} '
                            'hearts left',
                        if (next == null) 'You finished every available level!',
                      ].join('\n'),
                      actions: [
                        if (next != null)
                          OverlayButton(
                            label: 'Next Level',
                            primary: true,
                            onPressed: () => _goToLevel(next),
                          ),
                        OverlayButton(label: 'Replay', onPressed: _restart),
                        OverlayButton(
                          label: 'Level Select',
                          onPressed: _exitToLevelSelect,
                        ),
                      ],
                    ),
                ArrowGame.loseOverlay: (context, game) => GameOverlayCard(
                      title: 'Game Over',
                      message: 'You ran out of hearts.',
                      actions: [
                        OverlayButton(
                          label: 'Retry',
                          primary: true,
                          onPressed: _restart,
                        ),
                        OverlayButton(
                          label: 'Level Select',
                          onPressed: _exitToLevelSelect,
                        ),
                      ],
                    ),
              },
            ),
            Positioned(
              left: 8,
              top: 4,
              child: IconButton(
                tooltip: 'Pause',
                icon: const Icon(Icons.pause_rounded, color: Colors.white),
                onPressed: _game.pauseGame,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
