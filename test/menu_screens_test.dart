import 'package:arrow_puzzle/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main menu opens the level select with locked levels',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainMenuScreen()));

    expect(find.text('Arrow Puzzle'), findsOneWidget);

    await tester.tap(find.text('Select Level'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Select Level'),
      ),
      findsOneWidget,
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsWidgets);
  });
}
