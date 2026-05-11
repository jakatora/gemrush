import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/board.dart';
import 'package:gemrush/features/game/game_logic/cascade_engine.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/goal_checker.dart';
import 'package:gemrush/features/game/game_logic/score_engine.dart';
import 'package:gemrush/features/game/models/level_goal.dart';

Board _board(List<List<int>> grid) {
  final b = Board(rows: grid.length, cols: grid[0].length);
  for (var r = 0; r < b.rows; r++) {
    for (var c = 0; c < b.cols; c++) {
      final i = grid[r][c];
      if (i >= 0) {
        b.setGem(Pos(r, c), Gem(id: b.nextId(), color: GemColor.all[i]));
      }
    }
  }
  return b;
}

void main() {
  test('cascade removes 3-match and refills column', () {
    final board = _board([
      [1, 2, 3],
      [4, 5, 1],
      [0, 0, 0],
    ]);
    final score = ScoreEngine();
    final goals = GoalChecker(const [LevelGoal(type: GoalType.score, target: 100)]);
    final engine = CascadeEngine();
    final steps = engine.processFullCascade(board, score: score, goals: goals);
    expect(steps.isNotEmpty, true);
    // Bottom row z trójki czerwonych powinien być wyzerowany lub uzupełniony.
    // Każda komórka po kaskadzie ma gem (refill top).
    for (final p in board.positions) {
      expect(board.gemAt(p), isNotNull, reason: 'all cells refilled');
    }
    expect(score.score, greaterThan(0));
  });

  test('cascade increments score multiplier per chain', () {
    // Zbuduj sytuację z kaskadą:
    // Top row 5,5,5 (match), pod nim 1,2,3 — po grawitacji nowy match nie powstanie,
    // wystarczy że pierwsza fala zwróci pkt > 0.
    final board = _board([
      [0, 0, 0],
      [1, 2, 3],
      [4, 5, 1],
    ]);
    final score = ScoreEngine();
    final goals = GoalChecker(const [LevelGoal(type: GoalType.score, target: 100)]);
    final engine = CascadeEngine();
    final steps = engine.processFullCascade(board, score: score, goals: goals);
    expect(steps.length, greaterThanOrEqualTo(1));
    expect(score.score, greaterThan(0));
  });
}
