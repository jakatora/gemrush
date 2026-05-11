import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/board.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/special_gem_effects.dart';

Board _boardWithGems(int rows, int cols) {
  final b = Board(rows: rows, cols: cols);
  for (final p in b.positions) {
    b.setGem(p, Gem(id: b.nextId(), color: GemColor.blue));
  }
  return b;
}

void main() {
  final fx = SpecialGemEffects();

  test('striped horizontal clears entire row', () {
    final b = _boardWithGems(3, 5);
    b.setGem(
        const Pos(1, 2),
        Gem(id: 999, color: GemColor.red, kind: GemKind.stripedHorizontal));
    final removed = fx.resolve(b, {const Pos(1, 2)});
    for (var c = 0; c < 5; c++) {
      expect(removed.contains(Pos(1, c)), true, reason: 'col $c in row 1');
    }
  });

  test('striped vertical clears entire column', () {
    final b = _boardWithGems(4, 4);
    b.setGem(
        const Pos(2, 1),
        Gem(id: 999, color: GemColor.red, kind: GemKind.stripedVertical));
    final removed = fx.resolve(b, {const Pos(2, 1)});
    for (var r = 0; r < 4; r++) {
      expect(removed.contains(Pos(r, 1)), true);
    }
  });

  test('wrapped explodes 3x3', () {
    final b = _boardWithGems(5, 5);
    b.setGem(const Pos(2, 2),
        Gem(id: 999, color: GemColor.red, kind: GemKind.wrapped));
    final removed = fx.resolve(b, {const Pos(2, 2)});
    expect(removed.length, 9);
  });

  test('color bomb removes all of own color', () {
    final b = _boardWithGems(3, 3);
    b.setGem(const Pos(1, 1),
        Gem(id: 999, color: GemColor.blue, kind: GemKind.colorBomb));
    final removed = fx.resolve(b, {const Pos(1, 1)});
    // Wszystkie 9 to blue (minus sam color bomb, który jest też usuwany).
    expect(removed.length, 9);
  });

  test('combo: color bomb + color bomb clears entire board', () {
    final b = _boardWithGems(4, 4);
    b.setGem(const Pos(0, 0),
        Gem(id: 1, color: GemColor.red, kind: GemKind.colorBomb));
    b.setGem(const Pos(0, 1),
        Gem(id: 2, color: GemColor.blue, kind: GemKind.colorBomb));
    final combo = fx.resolveCombo(b, const Pos(0, 0), const Pos(0, 1));
    expect(combo.remove.length, 16);
  });

  test('combo: striped + striped clears row + column', () {
    final b = _boardWithGems(5, 5);
    b.setGem(const Pos(2, 2),
        Gem(id: 1, color: GemColor.red, kind: GemKind.stripedHorizontal));
    b.setGem(const Pos(2, 3),
        Gem(id: 2, color: GemColor.blue, kind: GemKind.stripedVertical));
    final combo = fx.resolveCombo(b, const Pos(2, 2), const Pos(2, 3));
    // pivot to (2, 3): rząd 2 (5 komórek) + kolumna 3 (5 komórek) - 1 wspólna = 9
    expect(combo.remove.length, 9);
  });
}
