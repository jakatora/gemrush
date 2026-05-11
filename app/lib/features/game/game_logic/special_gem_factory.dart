import 'board.dart';
import 'gem.dart';
import 'match_finder.dart';

/// Decyduje gdzie i jakiego rodzaju gem specjalny powstaje z matcha.
class SpecialGemFactory {
  /// Zwraca mapę pozycja → nowy gem specjalny, który zostanie wstawiony
  /// PO usunięciu matcha. Pozycja musi pozostać "ocalona" (nie usunięta).
  Map<Pos, Gem> createSpecials(Board board, List<Match> matches, {Pos? swapTarget}) {
    final result = <Pos, Gem>{};
    for (final m in matches) {
      switch (m.shape) {
        case MatchShape.lineOf3:
          break;
        case MatchShape.lineOf4:
          // Striped — zgodnie z orientacją runa.
          final pos = swapTarget != null && m.positions.contains(swapTarget)
              ? swapTarget
              : m.pivot;
          final kind = m.isHorizontal
              ? GemKind.stripedVertical
              : GemKind.stripedHorizontal;
          // Wskazówka: striped poziome (czyści rząd) powstaje z matcha PIONOWEGO 4 —
          // to konwencja Royal Match/Candy Crush. Striped wycina prostopadle.
          result[pos] = Gem(id: board.nextId(), color: m.color, kind: kind);
          break;
        case MatchShape.lShape:
          result[m.pivot] = Gem(
            id: board.nextId(),
            color: m.color,
            kind: GemKind.wrapped,
          );
          break;
        case MatchShape.lineOf5plus:
          final pos = swapTarget != null && m.positions.contains(swapTarget)
              ? swapTarget
              : m.pivot;
          result[pos] = Gem(
            id: board.nextId(),
            color: m.color,
            kind: GemKind.colorBomb,
          );
          break;
      }
    }
    return result;
  }
}
