import 'board.dart';
import 'gem.dart';

/// Operuje grawitacją (spadanie gemów) i refillem górnego rzędu.
class GravityEngine {
  /// Spuszcza wszystkie gemy w dół. Zwraca mapę "gemId → (from, to)" do animacji.
  Map<int, GemMove> applyGravity(Board board) {
    final moves = <int, GemMove>{};
    for (var c = 0; c < board.cols; c++) {
      // Skanuj od dołu do góry. Każdy pusty playable slot przyciąga pierwszy gem z góry.
      var targetRow = board.rows - 1;
      while (targetRow >= 0) {
        final targetCell = board.cells[targetRow][c];
        if (!targetCell.isPlayable) {
          targetRow -= 1;
          continue;
        }
        if (targetCell.gem != null) {
          targetRow -= 1;
          continue;
        }
        var sourceRow = targetRow - 1;
        while (sourceRow >= 0) {
          final sourceCell = board.cells[sourceRow][c];
          if (!sourceCell.isPlayable) {
            sourceRow -= 1;
            // Blokada przerywa kolumnę. Zachowanie zgodne z większością match-3.
            break;
          }
          if (sourceCell.gem == null) {
            sourceRow -= 1;
            continue;
          }
          // Przesuń sourceCell.gem → targetCell.
          final gem = sourceCell.gem!;
          targetCell.gem = gem;
          sourceCell.gem = null;
          moves[gem.id] = GemMove(
            gemId: gem.id,
            from: Pos(sourceRow, c),
            to: Pos(targetRow, c),
          );
          break;
        }
        if (sourceRow < 0 || targetCell.gem == null) {
          // Nie ma więcej gemów do spuszczenia w tej kolumnie.
          targetRow -= 1;
          continue;
        }
        targetRow -= 1;
      }
    }
    return moves;
  }

  /// Wypełnia puste komórki od góry (czyste pole top row jeśli playable).
  Map<int, GemMove> refillTop(Board board) {
    final moves = <int, GemMove>{};
    for (var c = 0; c < board.cols; c++) {
      var spawnRowAbove = -1;
      for (var r = 0; r < board.rows; r++) {
        final cell = board.cells[r][c];
        if (!cell.isPlayable) continue;
        if (cell.gem != null) continue;
        final newGem = board.newRandomGem();
        cell.gem = newGem;
        moves[newGem.id] = GemMove(
          gemId: newGem.id,
          from: Pos(spawnRowAbove, c),
          to: Pos(r, c),
        );
        spawnRowAbove -= 1;
      }
    }
    return moves;
  }
}

class GemMove {
  final int gemId;
  final Pos from;
  final Pos to;
  const GemMove({required this.gemId, required this.from, required this.to});
}
