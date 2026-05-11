import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/game_logic/board.dart';
import 'package:gemrush/features/game/game_logic/gem.dart';
import 'package:gemrush/features/game/game_logic/match_finder.dart' as mf;

Board _boardFromGrid(List<List<int>> grid) {
  final rows = grid.length;
  final cols = grid[0].length;
  final board = Board(rows: rows, cols: cols);
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      final idx = grid[r][c];
      if (idx >= 0) {
        board.setGem(Pos(r, c), Gem(id: board.nextId(), color: GemColor.all[idx]));
      }
    }
  }
  return board;
}

void main() {
  final finder = mf.MatchFinder();

  test('horizontal 3-match', () {
    final board = _boardFromGrid([
      [0, 0, 0, 1],
      [2, 3, 4, 5],
    ]);
    final matches = finder.findMatches(board);
    expect(matches, hasLength(1));
    expect(matches.first.length, 3);
    expect(matches.first.shape, mf.MatchShape.lineOf3);
    expect(matches.first.isHorizontal, true);
  });

  test('vertical 3-match', () {
    final board = _boardFromGrid([
      [0, 1, 2],
      [0, 3, 4],
      [0, 5, 1],
    ]);
    final matches = finder.findMatches(board);
    expect(matches, hasLength(1));
    expect(matches.first.length, 3);
    expect(matches.first.shape, mf.MatchShape.lineOf3);
    expect(matches.first.isHorizontal, false);
  });

  test('horizontal 4-match → lineOf4', () {
    final board = _boardFromGrid([
      [0, 0, 0, 0, 1],
    ]);
    final matches = finder.findMatches(board);
    expect(matches, hasLength(1));
    expect(matches.first.shape, mf.MatchShape.lineOf4);
  });

  test('5-match → lineOf5plus', () {
    final board = _boardFromGrid([
      [0, 0, 0, 0, 0, 1],
    ]);
    final matches = finder.findMatches(board);
    expect(matches, hasLength(1));
    expect(matches.first.shape, mf.MatchShape.lineOf5plus);
  });

  test('L-shape match merges horizontal + vertical', () {
    // Layout:
    //  0 0 0
    //  0 . .
    //  0 . .
    final board = _boardFromGrid([
      [0, 0, 0],
      [0, 1, 2],
      [0, 3, 4],
    ]);
    final matches = finder.findMatches(board);
    final lShapes = matches.where((m) => m.shape == mf.MatchShape.lShape);
    expect(lShapes, isNotEmpty);
    expect(lShapes.first.positions.length, 5);
  });

  test('no match for separated triples', () {
    final board = _boardFromGrid([
      [0, 0, 1, 0, 0],
    ]);
    final matches = finder.findMatches(board);
    expect(matches, isEmpty);
  });

  test('color bombs are ignored in match runs', () {
    final board = Board(rows: 1, cols: 4);
    board.setGem(Pos(0, 0), Gem(id: 1, color: GemColor.red));
    board.setGem(
        Pos(0, 1), Gem(id: 2, color: GemColor.red, kind: GemKind.colorBomb));
    board.setGem(Pos(0, 2), Gem(id: 3, color: GemColor.red));
    board.setGem(Pos(0, 3), Gem(id: 4, color: GemColor.red));
    final matches = finder.findMatches(board);
    // Po obu stronach color bomb mamy max 2-w-rzędzie → brak matcha.
    expect(matches, hasLength(0));
  });
}
