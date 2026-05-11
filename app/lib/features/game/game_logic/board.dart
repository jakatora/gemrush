import 'dart:math';

import 'gem.dart';

/// Plansza prostokątna (zwykle 9x9). Czysty Dart, brak Flutter/Flame.
class Board {
  final int rows;
  final int cols;
  final List<List<Cell>> cells;
  final List<GemColor> allowedColors;
  final Random rng;
  int _nextId = 0;

  Board({
    required this.rows,
    required this.cols,
    List<GemColor>? allowedColors,
    Random? rng,
    List<List<Cell>>? cells,
    int idCounterStart = 0,
  })  : allowedColors = allowedColors ?? List<GemColor>.of(GemColor.all),
        rng = rng ?? Random(),
        cells = cells ??
            List.generate(
              rows,
              (_) => List.generate(cols, (_) => Cell()),
            ),
        _nextId = idCounterStart;

  bool inBounds(Pos p) =>
      p.row >= 0 && p.row < rows && p.col >= 0 && p.col < cols;

  Cell cellAt(Pos p) => cells[p.row][p.col];

  Gem? gemAt(Pos p) => inBounds(p) ? cells[p.row][p.col].gem : null;

  void setGem(Pos p, Gem? gem) {
    cells[p.row][p.col].gem = gem;
  }

  int nextId() => _nextId++;

  Gem newRandomGem({GemColor? forceColor}) {
    final color =
        forceColor ?? allowedColors[rng.nextInt(allowedColors.length)];
    return Gem(id: nextId(), color: color);
  }

  /// Wypełnia całą planszę przypadkowymi gemami w taki sposób, żeby żaden match
  /// nie istniał na starcie. Idempotentne — wywołaj raz przy starcie poziomu.
  void fillRandomNoMatches() {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cell = cells[r][c];
        if (cell.blocked || cell.gem != null) continue;
        cell.gem = _pickColorAvoidingMatch(Pos(r, c));
      }
    }
  }

  Gem _pickColorAvoidingMatch(Pos p) {
    final forbidden = <GemColor>{};
    // Sprawdź ostatnie 2 gemy w lewo
    if (p.col >= 2) {
      final a = gemAt(Pos(p.row, p.col - 1));
      final b = gemAt(Pos(p.row, p.col - 2));
      if (a != null && b != null && a.color == b.color) {
        forbidden.add(a.color);
      }
    }
    // Sprawdź ostatnie 2 gemy w górę
    if (p.row >= 2) {
      final a = gemAt(Pos(p.row - 1, p.col));
      final b = gemAt(Pos(p.row - 2, p.col));
      if (a != null && b != null && a.color == b.color) {
        forbidden.add(a.color);
      }
    }
    final viable =
        allowedColors.where((c) => !forbidden.contains(c)).toList();
    final pool = viable.isEmpty ? allowedColors : viable;
    final color = pool[rng.nextInt(pool.length)];
    return Gem(id: nextId(), color: color);
  }

  /// Zamienia gemy między dwiema sąsiednimi pozycjami.
  /// Zwraca true gdy zamiana wykonana (były sąsiednie i grywalne).
  bool swap(Pos a, Pos b) {
    if (!a.isAdjacentTo(b)) return false;
    if (!inBounds(a) || !inBounds(b)) return false;
    final ca = cellAt(a);
    final cb = cellAt(b);
    if (!ca.isPlayable || !cb.isPlayable) return false;
    final tmp = ca.gem;
    ca.gem = cb.gem;
    cb.gem = tmp;
    return true;
  }

  /// Iteruje wszystkie pozycje planszy.
  Iterable<Pos> get positions sync* {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        yield Pos(r, c);
      }
    }
  }

  /// Czy istnieje przynajmniej jeden ruch dający match? Używane do shuffle.
  bool hasAnyValidMove() {
    // Sprawdź każdy potencjalny swap (poziome i pionowe).
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final p = Pos(r, c);
        if (c + 1 < cols && _swapWouldMatch(p, Pos(r, c + 1))) return true;
        if (r + 1 < rows && _swapWouldMatch(p, Pos(r + 1, c))) return true;
      }
    }
    return false;
  }

  bool _swapWouldMatch(Pos a, Pos b) {
    final ca = cellAt(a);
    final cb = cellAt(b);
    if (!ca.isPlayable || !cb.isPlayable) return false;
    if (ca.gem == null || cb.gem == null) return false;
    // Wymień, sprawdź czy powstałby >=3 match którejkolwiek pozycji, cofnij.
    final aGem = ca.gem!;
    final bGem = cb.gem!;
    ca.gem = bGem;
    cb.gem = aGem;
    final hasMatch = _hasMatchAt(a) || _hasMatchAt(b);
    ca.gem = aGem;
    cb.gem = bGem;
    return hasMatch;
  }

  bool _hasMatchAt(Pos p) {
    final gem = gemAt(p);
    if (gem == null || gem.isColorBomb) return false;
    final color = gem.color;
    // Sprawdź poziomy ciąg
    var horiz = 1;
    for (var c = p.col - 1; c >= 0 && gemAt(Pos(p.row, c))?.color == color; c--) {
      horiz += 1;
    }
    for (var c = p.col + 1; c < cols && gemAt(Pos(p.row, c))?.color == color; c++) {
      horiz += 1;
    }
    if (horiz >= 3) return true;
    var vert = 1;
    for (var r = p.row - 1; r >= 0 && gemAt(Pos(r, p.col))?.color == color; r--) {
      vert += 1;
    }
    for (var r = p.row + 1; r < rows && gemAt(Pos(r, p.col))?.color == color; r++) {
      vert += 1;
    }
    return vert >= 3;
  }

  /// Tasuje gemy in-place dopóki nie znajdzie konfiguracji bez matchy z dostępnym ruchem.
  void shuffleUntilPlayable() {
    final maxAttempts = 50;
    for (var i = 0; i < maxAttempts; i++) {
      final gems = <Gem>[];
      for (final p in positions) {
        final c = cellAt(p);
        if (c.gem != null) gems.add(c.gem!);
      }
      gems.shuffle(rng);
      var idx = 0;
      for (final p in positions) {
        final c = cellAt(p);
        if (c.gem != null) {
          c.gem = gems[idx++];
        }
      }
      // Usuń startowe matche — przerzucaj pojedyncze gemy
      _resolveStartingMatches();
      if (hasAnyValidMove()) return;
    }
  }

  void _resolveStartingMatches() {
    // Brute-force: jeśli powstał match na start, zamień kolor lokalnie.
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final p = Pos(r, c);
        if (_hasMatchAt(p)) {
          final cell = cellAt(p);
          if (cell.gem == null) continue;
          for (final newColor in allowedColors) {
            cell.gem = cell.gem!.copyWith(color: newColor);
            if (!_hasMatchAt(p)) break;
          }
        }
      }
    }
  }
}
