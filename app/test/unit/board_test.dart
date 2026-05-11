import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/board.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/match_finder.dart' as mf;

void main() {
  test('fillRandomNoMatches nie tworzy startowych matchy', () {
    for (var seed = 0; seed < 10; seed++) {
      final b = Board(rows: 9, cols: 9, rng: Random(seed));
      b.fillRandomNoMatches();
      final m = mf.MatchFinder().findMatches(b);
      expect(m, isEmpty, reason: 'seed $seed: ${m.length} matchy na starcie');
    }
  });

  test('swap zamienia gemy sąsiadów i odrzuca nie-sąsiadów', () {
    final b = Board(rows: 3, cols: 3);
    b.setGem(const Pos(0, 0), Gem(id: 1, color: GemColor.red));
    b.setGem(const Pos(0, 1), Gem(id: 2, color: GemColor.blue));
    b.setGem(const Pos(2, 2), Gem(id: 3, color: GemColor.green));

    expect(b.swap(const Pos(0, 0), const Pos(0, 1)), true);
    expect(b.gemAt(const Pos(0, 0))!.color, GemColor.blue);
    expect(b.gemAt(const Pos(0, 1))!.color, GemColor.red);

    expect(b.swap(const Pos(0, 0), const Pos(2, 2)), false,
        reason: 'nie sąsiednie');
  });

  test('hasAnyValidMove zwraca true gdy istnieje ruch', () {
    final b = Board(rows: 3, cols: 4);
    // Wymagający setup: jeden konkretny swap robi match-3.
    // R B B    swap (0,0) <-> (0,1):
    // R G G    R B B → B R B (R w środku — match-3 pionowo z R,R poniżej)
    // R G G
    b.setGem(const Pos(0, 0), Gem(id: 1, color: GemColor.red));
    b.setGem(const Pos(0, 1), Gem(id: 2, color: GemColor.blue));
    b.setGem(const Pos(0, 2), Gem(id: 3, color: GemColor.blue));
    b.setGem(const Pos(0, 3), Gem(id: 4, color: GemColor.green));
    b.setGem(const Pos(1, 0), Gem(id: 5, color: GemColor.red));
    b.setGem(const Pos(1, 1), Gem(id: 6, color: GemColor.green));
    b.setGem(const Pos(1, 2), Gem(id: 7, color: GemColor.blue));
    b.setGem(const Pos(1, 3), Gem(id: 8, color: GemColor.green));
    b.setGem(const Pos(2, 0), Gem(id: 9, color: GemColor.red));
    b.setGem(const Pos(2, 1), Gem(id: 10, color: GemColor.green));
    b.setGem(const Pos(2, 2), Gem(id: 11, color: GemColor.green));
    b.setGem(const Pos(2, 3), Gem(id: 12, color: GemColor.blue));
    // Swap (0,1) <-> (1,1) daje match 3 niebieskich w (0,1)-(0,2)... nie, te są już blue.
    // Najprościej: powinno znaleźć jakikolwiek ruch.
    expect(b.hasAnyValidMove(), true);
  });
}
