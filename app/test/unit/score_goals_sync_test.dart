// Regression test dla buga: score.score < starThreshold[0] mimo wygranej,
// powodujace stars=0 i blokade kolejnego poziomu.
//
// Po fixie w cascade_engine.dart: score.score === goals.progressOf(score).
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
  test('score.score matches goals.progressOf(score) po kaskadzie', () {
    // Plansza z prostym match-3 na dole + kolumna gemow ktora po grawitacji
    // tworzy kolejny match (cascade).
    final board = _board([
      [1, 2, 3],
      [4, 5, 0],
      [4, 5, 0],
      [4, 5, 0],
    ]);
    final score = ScoreEngine();
    final goals = GoalChecker(const [
      LevelGoal(type: GoalType.score, target: 100),
    ]);
    final engine = CascadeEngine();
    final steps = engine.processFullCascade(board,
        score: score, goals: goals);

    expect(steps.isNotEmpty, true);
    expect(score.score, greaterThan(0));
    expect(score.score, goals.progressOf(GoalType.score),
        reason: 'score.score MUSI byc zsynchronizowane z goals — inaczej '
            'gracz wygra (goals met) ale starsFromScore zwroci 0.');
  });

  test('po multiple cascades score nadal sync z goals', () {
    final board = _board([
      [0, 0, 0],
      [1, 2, 3],
      [1, 2, 3],
      [1, 2, 3],
    ]);
    final score = ScoreEngine();
    final goals = GoalChecker(const [
      LevelGoal(type: GoalType.score, target: 100),
    ]);
    final engine = CascadeEngine();
    engine.processFullCascade(board, score: score, goals: goals);
    expect(score.score, goals.progressOf(GoalType.score));
  });
}
