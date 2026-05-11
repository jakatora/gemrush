import 'board.dart';
import 'gem.dart';
import 'goal_checker.dart';
import 'gravity_engine.dart';
import 'match_finder.dart';
import 'score_engine.dart';
import 'special_gem_effects.dart';
import 'special_gem_factory.dart';

/// Wynik pojedynczego kroku kaskady — do animacji UI.
class CascadeStep {
  final Set<Pos> removed;
  final Map<Pos, Gem> spawnedSpecials;
  final Map<int, GemMove> gravityMoves;
  final Map<int, GemMove> refillMoves;
  final int pointsGained;
  final int cascadeIndex;

  const CascadeStep({
    required this.removed,
    required this.spawnedSpecials,
    required this.gravityMoves,
    required this.refillMoves,
    required this.pointsGained,
    required this.cascadeIndex,
  });
}

/// Stateless silnik kaskad. Operuje na podanym board / score / goalChecker.
class CascadeEngine {
  final MatchFinder finder = MatchFinder();
  final SpecialGemFactory factory = SpecialGemFactory();
  final SpecialGemEffects effects = SpecialGemEffects();
  final GravityEngine gravity = GravityEngine();

  /// Pojedyncza pełna kaskada po ruchu — pętla aż brak matchy.
  /// `swapTarget` to pozycja, na którą gracz przeciągnął gem (dla L-wraps i match4 specials).
  List<CascadeStep> processFullCascade(
    Board board, {
    required ScoreEngine score,
    required GoalChecker goals,
    Pos? swapTarget,
    Set<Pos>? initialTriggers,
  }) {
    final steps = <CascadeStep>[];
    score.resetCascade();
    var iteration = 0;

    Set<Pos> pending = initialTriggers ?? {};
    while (true) {
      // 1. Resolve triggered specials (jeśli są)
      Set<Pos> removed = {};
      if (pending.isNotEmpty) {
        removed = effects.resolve(board, pending);
      }

      // 2. Znajdź matche
      final matches = finder.findMatches(board);

      // 3. Spawn specials z matchy
      final spawnedSpecials = factory.createSpecials(
        board,
        matches,
        swapTarget: iteration == 0 ? swapTarget : null,
      );

      // Dodaj pozycje matchy do removed (ale wyłącz pozycje, gdzie powstają specials)
      for (final m in matches) {
        for (final p in m.positions) {
          if (!spawnedSpecials.containsKey(p)) {
            removed.add(p);
          }
        }
      }

      if (removed.isEmpty && spawnedSpecials.isEmpty) {
        break;
      }

      // 4. Aktualizuj score
      score.awardMatches(matches);
      var pts = 0;
      for (final m in matches) {
        pts += score.pointsForMatch(m);
      }
      for (final p in removed) {
        final g = board.gemAt(p);
        if (g != null) {
          pts += score.pointsForRemoval(kind: g.kind);
        }
      }

      // 5. Aktualizuj cele
      goals.addScore(pts);
      for (final p in removed) {
        final cell = board.cellAt(p);
        if (cell.jellyLayers > 0) {
          cell.jellyLayers -= 1;
          if (cell.jellyLayers == 0) {
            goals.recordJellyCleared();
          }
        }
        if (cell.chocolate) {
          cell.chocolate = false;
          goals.recordObstacleCleared();
        }
        if (cell.iceLayers > 0) {
          cell.iceLayers -= 1;
          if (cell.iceLayers == 0) {
            goals.recordObstacleCleared();
          }
        }
      }

      // 6. Wyzeruj usunięte komórki
      for (final p in removed) {
        board.setGem(p, null);
      }

      // 7. Wstaw spawned specials (zachowane gemy ulepszone)
      for (final e in spawnedSpecials.entries) {
        board.setGem(e.key, e.value);
      }

      // 8. Gravity + refill
      final gMoves = gravity.applyGravity(board);
      final rMoves = gravity.refillTop(board);

      steps.add(CascadeStep(
        removed: removed,
        spawnedSpecials: spawnedSpecials,
        gravityMoves: gMoves,
        refillMoves: rMoves,
        pointsGained: pts,
        cascadeIndex: iteration,
      ));

      score.onCascadeStep();
      iteration += 1;
      pending = {}; // dalsze iteracje już nie mają explicit triggers
      if (iteration > 50) break; // safety guard
    }

    return steps;
  }
}
