import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/goal_checker.dart';
import 'package:gemrush/features/game/models/level_goal.dart';
import 'package:gemrush/features/game/widgets/hud.dart';

void main() {
  testWidgets('HUD pokazuje score, moves i goals', (tester) async {
    final goals = GoalChecker(const [
      LevelGoal(type: GoalType.score, target: 1000),
      LevelGoal(type: GoalType.clearJelly, target: 5),
    ]);
    var paused = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHud(
            levelId: 7,
            score: 1234,
            movesLeft: 12,
            goals: goals,
            onPause: () => paused = true,
          ),
        ),
      ),
    );
    expect(find.text('Poziom 7'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('0/1000'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause));
    expect(paused, true);
  });

  testWidgets('HUD aktualizuje postęp celów', (tester) async {
    final goals = GoalChecker(const [
      LevelGoal(type: GoalType.score, target: 1000),
    ]);
    goals.addScore(500);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHud(
            levelId: 1,
            score: 500,
            movesLeft: 20,
            goals: goals,
            onPause: () {},
          ),
        ),
      ),
    );
    expect(find.text('500/1000'), findsOneWidget);
  });
}
