import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/goal_checker.dart';
import 'package:gemrush/features/game/models/level_goal.dart';

void main() {
  test('score goal completes when target reached', () {
    final gc = GoalChecker(const [LevelGoal(type: GoalType.score, target: 1000)]);
    expect(gc.allGoalsMet, false);
    gc.addScore(999);
    expect(gc.allGoalsMet, false);
    gc.addScore(1);
    expect(gc.allGoalsMet, true);
  });

  test('multiple goals — wszystkie wymagane', () {
    final gc = GoalChecker(const [
      LevelGoal(type: GoalType.score, target: 100),
      LevelGoal(type: GoalType.clearJelly, target: 3),
    ]);
    gc.addScore(150);
    expect(gc.allGoalsMet, false);
    gc.recordJellyCleared();
    gc.recordJellyCleared();
    gc.recordJellyCleared();
    expect(gc.allGoalsMet, true);
  });

  test('starsFromScore liczy progi', () {
    final gc = GoalChecker(const [LevelGoal(type: GoalType.score, target: 1000)]);
    expect(gc.starsFromScore(500, [1000, 1500, 2500]), 0);
    expect(gc.starsFromScore(1000, [1000, 1500, 2500]), 1);
    expect(gc.starsFromScore(1500, [1000, 1500, 2500]), 2);
    expect(gc.starsFromScore(2500, [1000, 1500, 2500]), 3);
  });
}
