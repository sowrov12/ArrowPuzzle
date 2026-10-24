import 'package:flutter/material.dart';

import '../levels/level_data.dart';
import '../logic/game_progress.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.arrow_upward_rounded,
                    size: 72, color: Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                const Text(
                  'Arrow Puzzle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ListenableBuilder(
                  listenable: gameProgress,
                  builder: (context, _) {
                    final level = Levels.byId(gameProgress.unlockedLevel)!;
                    return FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GameScreen(level: level),
                        ),
                      ),
                      child: Text('Play  (Level ${level.id})'),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LevelSelectScreen(),
                    ),
                  ),
                  child: const Text('Select Level'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
