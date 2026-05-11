import 'board.dart';
import 'gem.dart';

/// Typ matcha — używany do decyzji o spawnowaniu specjalnego gemu.
enum MatchShape { lineOf3, lineOf4, lineOf5plus, lShape }

/// Pojedynczy match — zestaw pozycji + kształt + kolor.
class Match {
  final Set<Pos> positions;
  final MatchShape shape;
  final GemColor color;
  final bool isHorizontal;

  /// Pozycja "pivota" dla nagrody specjalnej (np. narożnik L, środek 5).
  final Pos pivot;

  const Match({
    required this.positions,
    required this.shape,
    required this.color,
    required this.isHorizontal,
    required this.pivot,
  });

  int get length => positions.length;
}

/// Detektor matchy ≥3, 4, 5, L/T. Działa na statycznym snapshocie planszy.
class MatchFinder {
  /// Zwraca wszystkie matche aktualne na planszy.
  /// L/T-shape wykrywany przez merging poziomego i pionowego runa wspólnego koloru.
  List<Match> findMatches(Board board) {
    final horiz = _findHorizontalRuns(board);
    final vert = _findVerticalRuns(board);

    final matches = <Match>[];
    final usedHoriz = <int>{};
    final usedVert = <int>{};

    // Merge horizontal + vertical runs jeśli mają wspólną pozycję → L/T.
    for (var hIdx = 0; hIdx < horiz.length; hIdx++) {
      for (var vIdx = 0; vIdx < vert.length; vIdx++) {
        final h = horiz[hIdx];
        final v = vert[vIdx];
        if (h.color != v.color) continue;
        final common = h.positions.intersection(v.positions);
        if (common.isEmpty) continue;
        final pivot = common.first;
        matches.add(Match(
          positions: {...h.positions, ...v.positions},
          shape: MatchShape.lShape,
          color: h.color,
          isHorizontal: false,
          pivot: pivot,
        ));
        usedHoriz.add(hIdx);
        usedVert.add(vIdx);
      }
    }

    for (var i = 0; i < horiz.length; i++) {
      if (usedHoriz.contains(i)) continue;
      matches.add(horiz[i]);
    }
    for (var i = 0; i < vert.length; i++) {
      if (usedVert.contains(i)) continue;
      matches.add(vert[i]);
    }

    return matches;
  }

  List<Match> _findHorizontalRuns(Board board) {
    final result = <Match>[];
    for (var r = 0; r < board.rows; r++) {
      var c = 0;
      while (c < board.cols) {
        final gem = board.gemAt(Pos(r, c));
        if (gem == null || gem.isColorBomb) {
          c += 1;
          continue;
        }
        final color = gem.color;
        var end = c + 1;
        while (end < board.cols) {
          final g2 = board.gemAt(Pos(r, end));
          if (g2 == null || g2.isColorBomb || g2.color != color) break;
          end += 1;
        }
        final len = end - c;
        if (len >= 3) {
          final positions = {
            for (var i = c; i < end; i++) Pos(r, i),
          };
          final shape = len == 3
              ? MatchShape.lineOf3
              : len == 4
                  ? MatchShape.lineOf4
                  : MatchShape.lineOf5plus;
          result.add(Match(
            positions: positions,
            shape: shape,
            color: color,
            isHorizontal: true,
            pivot: Pos(r, c + len ~/ 2),
          ));
        }
        c = end;
      }
    }
    return result;
  }

  List<Match> _findVerticalRuns(Board board) {
    final result = <Match>[];
    for (var c = 0; c < board.cols; c++) {
      var r = 0;
      while (r < board.rows) {
        final gem = board.gemAt(Pos(r, c));
        if (gem == null || gem.isColorBomb) {
          r += 1;
          continue;
        }
        final color = gem.color;
        var end = r + 1;
        while (end < board.rows) {
          final g2 = board.gemAt(Pos(end, c));
          if (g2 == null || g2.isColorBomb || g2.color != color) break;
          end += 1;
        }
        final len = end - r;
        if (len >= 3) {
          final positions = {
            for (var i = r; i < end; i++) Pos(i, c),
          };
          final shape = len == 3
              ? MatchShape.lineOf3
              : len == 4
                  ? MatchShape.lineOf4
                  : MatchShape.lineOf5plus;
          result.add(Match(
            positions: positions,
            shape: shape,
            color: color,
            isHorizontal: false,
            pivot: Pos(r + len ~/ 2, c),
          ));
        }
        r = end;
      }
    }
    return result;
  }
}
