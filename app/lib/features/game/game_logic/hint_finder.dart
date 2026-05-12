import 'board.dart';
import 'gem.dart';

/// Znajduje pojedynczy ruch dający match. Używane do podpowiedzi
/// (rewarded ad placement = "hint"). Skanuje wszystkie potencjalne swapy.
class HintFinder {
  /// Zwraca parę (a, b) lub null jeśli brak dostępnych ruchów (shuffle wymagany).
  ({Pos a, Pos b})? findHint(Board board) {
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final p = Pos(r, c);
        if (c + 1 < board.cols) {
          final q = Pos(r, c + 1);
          if (_wouldMatch(board, p, q)) return (a: p, b: q);
        }
        if (r + 1 < board.rows) {
          final q = Pos(r + 1, c);
          if (_wouldMatch(board, p, q)) return (a: p, b: q);
        }
      }
    }
    return null;
  }

  bool _wouldMatch(Board board, Pos a, Pos b) {
    final ca = board.cellAt(a);
    final cb = board.cellAt(b);
    if (!ca.isPlayable || !cb.isPlayable) return false;
    final ga = ca.gem;
    final gb = cb.gem;
    if (ga == null || gb == null) return false;
    if (ga.isColorBomb || gb.isColorBomb) return true; // color bomb zawsze działa
    // Wymień, sprawdź, cofnij.
    ca.gem = gb;
    cb.gem = ga;
    final match = _hasMatchAt(board, a) || _hasMatchAt(board, b);
    ca.gem = ga;
    cb.gem = gb;
    return match;
  }

  bool _hasMatchAt(Board board, Pos p) {
    final gem = board.gemAt(p);
    if (gem == null || gem.isColorBomb) return false;
    final color = gem.color;
    var horiz = 1;
    for (var c = p.col - 1;
        c >= 0 && board.gemAt(Pos(p.row, c))?.color == color;
        c--) {
      horiz += 1;
    }
    for (var c = p.col + 1;
        c < board.cols && board.gemAt(Pos(p.row, c))?.color == color;
        c++) {
      horiz += 1;
    }
    if (horiz >= 3) return true;
    var vert = 1;
    for (var r = p.row - 1;
        r >= 0 && board.gemAt(Pos(r, p.col))?.color == color;
        r--) {
      vert += 1;
    }
    for (var r = p.row + 1;
        r < board.rows && board.gemAt(Pos(r, p.col))?.color == color;
        r++) {
      vert += 1;
    }
    return vert >= 3;
  }
}
