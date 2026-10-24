import 'package:flutter/material.dart';

import '../levels/level_data.dart';
import '../logic/game_progress.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: ListenableBuilder(
        listenable: gameProgress,
        builder: (context, _) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 96,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: Levels.all.length,
            itemBuilder: (context, index) {
              final level = Levels.all[index];
              return _LevelTile(
                level: level,
                unlocked: gameProgress.isUnlocked(level.id),
                best: gameProgress.highScoreFor(level.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.unlocked,
    required this.best,
  });

  final LevelData level;
  final bool unlocked;
  final int best;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unlocked ? const Color(0xFF3B82F6) : const Color(0xFF262B3A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: unlocked
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GameScreen(level: level),
                  ),
                )
            : null,
        child: Center(
          child: unlocked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${level.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${level.cols}×${level.rows}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (best > 0)
                      Text(
                        '★ $best',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                  ],
                )
              : const Icon(Icons.lock, color: Colors.white38),
        ),
      ),
    );
  }
}
