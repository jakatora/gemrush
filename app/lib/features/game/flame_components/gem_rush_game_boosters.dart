import '../game_logic/gem.dart';
import '../game_logic/hint_finder.dart';
import 'gem_rush_game.dart';

/// Booster API gry — dostępne publicznie dla UI (BoosterBar, rewarded hint).
/// Wydzielone jako extension żeby `gem_rush_game.dart` skupiał się na
/// lifecycle + gestures + win/lose flow.
extension GemRushGameBoosters on GemRushGame {
  /// Znajduje możliwy ruch i pokazuje highlight.
  /// Zwraca true jeśli znaleziono, false jeśli trzeba shuffle.
  bool useHint() {
    final hint = HintFinder().findHint(board);
    if (hint == null) return false;
    renderer.flashHint(hint.a, hint.b);
    return true;
  }

  /// Tasuje planszę aż znajdzie konfigurację z dostępnym ruchem.
  Future<void> useShuffle() async {
    busy = true;
    board.shuffleUntilPlayable();
    renderer.syncFromBoard(animate: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    busy = false;
  }

  /// Rozbija pojedynczy klejnot na danej pozycji (booster Hammer).
  Future<void> useHammerAt(Pos p) async {
    if (busy) return;
    if (!board.inBounds(p)) return;
    final gem = board.gemAt(p);
    if (gem == null) return;
    busy = true;
    board.setGem(p, null);
    cascadeEngine.gravity.applyGravity(board);
    cascadeEngine.gravity.refillTop(board);
    renderer.syncFromBoard(animate: true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final steps = cascadeEngine.processFullCascade(
      board,
      score: score,
      goals: goals,
    );
    for (final s in steps) {
      await renderer.animateCascadeStep(s);
    }
    busy = false;
    emitUpdate();
    checkWinLose();
  }
}
