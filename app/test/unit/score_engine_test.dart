import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/match_finder.dart' as mf;
import 'package:gemrush/features/game/game_logic/score_engine.dart';

void main() {
  test('points for match-3 = 3 * basePerGem with multiplier 1.0', () {
    final e = ScoreEngine();
    final m = mf.Match(
      positions: {const Pos(0, 0), const Pos(0, 1), const Pos(0, 2)},
      shape: mf.MatchShape.lineOf3,
      color: GemColor.red,
      isHorizontal: true,
      pivot: const Pos(0, 1),
    );
    expect(e.pointsForMatch(m), 3 * ScoreEngine.basePerGem);
  });

  test('cascade multiplier rośnie max do 5x', () {
    final e = ScoreEngine();
    for (var i = 0; i < 20; i++) {
      e.onCascadeStep();
    }
    expect(e.multiplier, ScoreEngine.maxMultiplier);
  });

  test('finalMoveBonus = movesLeft * 1000', () {
    final e = ScoreEngine();
    expect(e.finalMoveBonus(0), 0);
    expect(e.finalMoveBonus(5), 5000);
  });
}
