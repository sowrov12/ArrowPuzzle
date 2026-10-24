import 'package:flutter/material.dart';

import 'levels/level_data.dart';
import 'logic/game_progress.dart';
import 'screens/main_menu_screen.dart';
import 'storage/hive_progress_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storage = await HiveProgressStorage.open();
    gameProgress = await GameProgress.load(
      totalLevels: Levels.all.length,
      storage: storage,
    );
  } catch (e) {
    // Storage problems must not block play; fall back to in-memory progress.
    debugPrint('Local storage unavailable, progress will not be saved: $e');
  }

  runApp(const ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  const ArrowPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arrow Puzzle',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF1B1F2A),
      ),
      home: const MainMenuScreen(),
    );
  }
}
