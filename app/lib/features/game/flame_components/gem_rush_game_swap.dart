import '../game_logic/gem.dart';
import '../game_logic/match_finder.dart';
import '../game_logic/special_gem_effects.dart';
import 'gem_rush_game.dart';

/// Swap logic — wydzielona z gem_rush_game.dart bo to najdłuższa metoda
/// (~80 linii) i logicznie odrębna od lifecycle/render.
///
/// Wywoływana z onDragUpdate w głównej klasie (po wykryciu kierunku swipu).
extension GemRushGameSwap on GemRushGame {
  /// Próbuje wykonać swap a → b. Cofa jeśli brak matcha. Po sukcesie
  /// uruchamia pełen pipeline cascade'u + sprawdza warunki win/lose.
  Future<void> attemptSwap(Pos a, Pos b) async {
    if (busy) return;
    if (!board.inBounds(a) || !board.inBounds(b)) return;
    if (!a.isAdjacentTo(b)) return;
    final ga = board.gemAt(a);
    final gb = board.gemAt(b);
    if (ga == null || gb == null) return;
    onHapticEvent?.call('swap');
    busy = true;
    movesLeft -= 1;

    // 1. Wstępna animacja swap
    if (!board.swap(a, b)) {
      busy = false;
      return;
    }
    await renderer.animateSwap(a, b, duration: 0.15);

    // 2. Sprawdź combo specjali / matche
    Set<Pos> triggers = {};
    final swappedA = board.gemAt(a);
    final swappedB = board.gemAt(b);

    final combo = SpecialGemEffects().resolveCombo(board, a, b);
    if (!combo.isEmpty) {
      for (final e in combo.transforms.entries) {
        board.setGem(e.key, e.value);
      }
      triggers = {...combo.remove, ...combo.triggerAfterTransform};
    } else {
      // Jeśli któryś gem jest color bomb po swapie — od razu aktywuj
      if (swappedA?.isColorBomb == true || swappedB?.isColorBomb == true) {
        triggers = {a, b};
      }
    }

    final matches = MatchFinder().findMatches(board);
    if (matches.isEmpty && triggers.isEmpty) {
      // Cofnij — niedopuszczalny ruch.
      board.swap(a, b);
      await renderer.animateSwap(a, b, duration: 0.2);
      movesLeft += 1; // zwroć ruch
      busy = false;
      emitUpdate();
      return;
    }

    final steps = cascadeEngine.processFullCascade(
      board,
      score: score,
      goals: goals,
      swapTarget: b,
      initialTriggers: triggers,
    );

    for (final step in steps) {
      if (step.cascadeIndex > maxCascadeReached) {
        maxCascadeReached = step.cascadeIndex;
      }
      // Haptics: match3 → cascade combo dla wyższych iteracji.
      if (step.cascadeIndex == 0) {
        onHapticEvent?.call('match3');
      } else if (step.cascadeIndex == 1) {
        onHapticEvent?.call('match4');
      } else {
        onHapticEvent?.call('cascade');
      }
      if (step.spawnedSpecials.isNotEmpty) {
        onHapticEvent?.call('special');
      }
      await renderer.animateCascadeStep(step);
    }

    busy = false;
    emitUpdate();
    checkWinLose();
    if (!goals.allGoalsMet && movesLeft > 0 && !board.hasAnyValidMove()) {
      board.shuffleUntilPlayable();
      renderer.syncFromBoard(animate: true);
    }
  }
}
