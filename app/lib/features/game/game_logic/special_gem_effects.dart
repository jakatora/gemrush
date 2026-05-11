import 'board.dart';
import 'gem.dart';

/// Skutki gemów specjalnych — rozwiązywane jako "fala" eksplozji.
/// Zwracają zestaw pozycji, które należy usunąć w pojedynczym kroku.
class SpecialGemEffects {
  /// Resolve: usuwa specjalne gemy "w łańcuchu" — jeśli efekt złapie kolejny
  /// special, on też się aktywuje.
  ///
  /// Wejście: zestaw `triggered` (pozycje gemów specjalnych, które właśnie
  /// powinny się aktywować — np. ze swapu lub z efektu kaskady).
  /// Wyjście: pełen zestaw pozycji do usunięcia tym łańcuchem.
  Set<Pos> resolve(Board board, Set<Pos> triggered) {
    final queue = List<Pos>.of(triggered);
    final removed = <Pos>{};
    while (queue.isNotEmpty) {
      final p = queue.removeAt(0);
      if (removed.contains(p)) continue;
      final gem = board.gemAt(p);
      if (gem == null) continue;
      removed.add(p);
      if (!gem.kind.isSpecial) continue;
      final additional = _effect(board, p, gem);
      for (final ap in additional) {
        if (!removed.contains(ap)) {
          queue.add(ap);
        }
      }
    }
    return removed;
  }

  /// Efekty pojedynczych specjali (bez chainowania — chainowanie robi `resolve`).
  Set<Pos> _effect(Board board, Pos origin, Gem gem) {
    switch (gem.kind) {
      case GemKind.stripedHorizontal:
        return {for (var c = 0; c < board.cols; c++) Pos(origin.row, c)};
      case GemKind.stripedVertical:
        return {for (var r = 0; r < board.rows; r++) Pos(r, origin.col)};
      case GemKind.wrapped:
        return _areaOf3x3(board, origin);
      case GemKind.colorBomb:
        return _allOfColor(board, gem.color);
      case GemKind.normal:
        return const {};
    }
  }

  Set<Pos> _areaOf3x3(Board board, Pos center) {
    final out = <Pos>{};
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        final p = Pos(center.row + dr, center.col + dc);
        if (board.inBounds(p)) out.add(p);
      }
    }
    return out;
  }

  Set<Pos> _allOfColor(Board board, GemColor color) {
    final out = <Pos>{};
    for (final p in board.positions) {
      final g = board.gemAt(p);
      if (g != null && !g.isColorBomb && g.color == color) {
        out.add(p);
      }
    }
    return out;
  }

  // ============================================================
  //  COMBO — swap dwóch specjali
  // ============================================================

  /// Wynik combo zwraca:
  /// - zbiór pozycji do usunięcia natychmiast
  /// - opcjonalne "transformacje" (np. color bomb + striped: zamień kolor → striped)
  ComboResult resolveCombo(Board board, Pos a, Pos b) {
    final ga = board.gemAt(a);
    final gb = board.gemAt(b);
    if (ga == null || gb == null) return ComboResult.empty;
    final kindA = ga.kind;
    final kindB = gb.kind;

    // Color bomb + Color bomb → cała plansza
    if (ga.isColorBomb && gb.isColorBomb) {
      return ComboResult(remove: board.positions.toSet());
    }

    // Color bomb + normalny / striped / wrapped
    if (ga.isColorBomb || gb.isColorBomb) {
      final bomb = ga.isColorBomb ? a : b;
      final other = ga.isColorBomb ? b : a;
      final otherGem = board.gemAt(other)!;
      final targetColor = otherGem.color;

      if (otherGem.kind == GemKind.normal) {
        final all = <Pos>{};
        for (final p in board.positions) {
          final g = board.gemAt(p);
          if (g != null && !g.isColorBomb && g.color == targetColor) {
            all.add(p);
          }
        }
        all.add(bomb);
        return ComboResult(remove: all);
      }
      // Color bomb + striped/wrapped: zamień wszystkie tego koloru na taki sam typ specjalny,
      // potem aktywuj wszystkie.
      final transforms = <Pos, Gem>{};
      final triggers = <Pos>{};
      for (final p in board.positions) {
        final g = board.gemAt(p);
        if (g != null && !g.isColorBomb && g.color == targetColor) {
          transforms[p] = g.copyWith(kind: otherGem.kind);
          triggers.add(p);
        }
      }
      triggers.add(bomb);
      return ComboResult(
        remove: {bomb},
        transforms: transforms,
        triggerAfterTransform: triggers,
      );
    }

    // Striped + Striped → krzyż przez punkt swapu (rząd + kolumna `b`)
    final striped = {GemKind.stripedHorizontal, GemKind.stripedVertical};
    if (striped.contains(kindA) && striped.contains(kindB)) {
      final out = <Pos>{};
      for (var c = 0; c < board.cols; c++) {
        out.add(Pos(b.row, c));
      }
      for (var r = 0; r < board.rows; r++) {
        out.add(Pos(r, b.col));
      }
      return ComboResult(remove: out);
    }

    // Wrapped + Wrapped → 5x5
    if (kindA == GemKind.wrapped && kindB == GemKind.wrapped) {
      final out = <Pos>{};
      for (var dr = -2; dr <= 2; dr++) {
        for (var dc = -2; dc <= 2; dc++) {
          final p = Pos(b.row + dr, b.col + dc);
          if (board.inBounds(p)) out.add(p);
        }
      }
      return ComboResult(remove: out);
    }

    // Striped + Wrapped → 3 rzędy + 3 kolumny
    final isWrappedStriped = (kindA == GemKind.wrapped && striped.contains(kindB)) ||
        (kindB == GemKind.wrapped && striped.contains(kindA));
    if (isWrappedStriped) {
      final out = <Pos>{};
      for (var c = 0; c < board.cols; c++) {
        for (var dr = -1; dr <= 1; dr++) {
          final p = Pos(b.row + dr, c);
          if (board.inBounds(p)) out.add(p);
        }
      }
      for (var r = 0; r < board.rows; r++) {
        for (var dc = -1; dc <= 1; dc++) {
          final p = Pos(r, b.col + dc);
          if (board.inBounds(p)) out.add(p);
        }
      }
      return ComboResult(remove: out);
    }

    return ComboResult.empty;
  }
}

class ComboResult {
  final Set<Pos> remove;
  final Map<Pos, Gem> transforms;
  final Set<Pos> triggerAfterTransform;

  const ComboResult({
    this.remove = const {},
    this.transforms = const {},
    this.triggerAfterTransform = const {},
  });

  static const empty = ComboResult();

  bool get isEmpty =>
      remove.isEmpty && transforms.isEmpty && triggerAfterTransform.isEmpty;
}
