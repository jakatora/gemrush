import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/board.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/hint_finder.dart';

Board _b(List<List<int>> grid) {
  final b = Board(rows: grid.length, cols: grid[0].length);
  for (var r = 0; r < b.rows; r++) {
    for (var c = 0; c < b.cols; c++) {
      final i = grid[r][c];
      if (i >= 0) {
        b.setGem(Pos(r, c), Gem(id: b.nextId(), color: GemColor.all[i]));
      }
    }
  }
  return b;
}

void main() {
  final hf = HintFinder();

  test('zwraca null gdy brak ruchu', () {
    // 2x2 plansza alternujących kolorów — brak match-3 możliwy.
    final board = _b([
      [0, 1],
      [1, 0],
    ]);
    expect(hf.findHint(board), isNull);
  });

  test('znajduje ruch dający match-3 poziomy', () {
    // R B R    swap (0,1) <-> (1,1) daje match w kolumnie 1 (3xB).
    // R B X
    // R B X
    final board = _b([
      [0, 1, 0],
      [0, 1, 2],
      [0, 1, 2],
    ]);
    // (0,0), (1,0), (2,0) to już matche → ten board ma matche startowe.
    // Ale findHint sprawdza CZY swap dałby match — więc nawet z istniejącymi
    // matchami, jakikolwiek swap dający match zwróci hint.
    final hint = hf.findHint(board);
    expect(hint, isNotNull);
  });

  test('color bomb zawsze daje match (hint)', () {
    final board = Board(rows: 3, cols: 3);
    board.setGem(const Pos(0, 0),
        Gem(id: 1, color: GemColor.red, kind: GemKind.colorBomb));
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        if (r == 0 && c == 0) continue;
        board.setGem(Pos(r, c), Gem(id: 100 + r * 3 + c, color: GemColor.blue));
      }
    }
    final hint = hf.findHint(board);
    expect(hint, isNotNull);
  });
}
