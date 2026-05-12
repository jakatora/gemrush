import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../game_logic/board.dart';
import '../game_logic/cascade_engine.dart';
import '../game_logic/gem.dart';
import 'gem_sprite.dart';
import 'particle_helper.dart';

/// Komponent rysujący planszę: siatkę, tła komórek (jelly/ice/blocked), gemy.
class BoardRenderer extends PositionComponent {
  Board board;
  Vector2 gameSize;
  final Map<int, GemSprite> _sprites = {};
  double cellSize = 0;
  Offset originPx = Offset.zero;
  Offset _dragAccum = Offset.zero;

  BoardRenderer({required this.board, required this.gameSize}) {
    _computeLayout();
  }

  void updateLayout(Vector2 newSize) {
    gameSize = newSize;
    _computeLayout();
    for (final sprite in _sprites.values) {
      sprite.updateCellSize(cellSize);
    }
    syncFromBoard(animate: false);
  }

  void _computeLayout() {
    final padding = 16.0;
    final availableW = gameSize.x - padding * 2;
    final availableH = gameSize.y - padding * 2;
    final cellW = availableW / board.cols;
    final cellH = availableH / board.rows;
    cellSize = cellW < cellH ? cellW : cellH;
    final boardW = cellSize * board.cols;
    final boardH = cellSize * board.rows;
    originPx = Offset(
      (gameSize.x - boardW) / 2,
      (gameSize.y - boardH) / 2,
    );
  }

  Vector2 cellCenter(Pos p) {
    final x = originPx.dx + p.col * cellSize + cellSize / 2;
    final y = originPx.dy + p.row * cellSize + cellSize / 2;
    return Vector2(x, y);
  }

  Pos posFromGlobal(Vector2 canvasPos) {
    final col = ((canvasPos.x - originPx.dx) / cellSize).floor();
    final row = ((canvasPos.y - originPx.dy) / cellSize).floor();
    return Pos(row.clamp(0, board.rows - 1), col.clamp(0, board.cols - 1));
  }

  Offset dragAccumulate(Vector2 delta) {
    _dragAccum = _dragAccum.translate(delta.x, delta.y);
    return _dragAccum;
  }

  void dragReset() {
    _dragAccum = Offset.zero;
  }

  /// Pełna synchronizacja warstwy wizualnej z stanem boardu.
  void syncFromBoard({required bool animate}) {
    final currentIds = <int>{};
    for (final p in board.positions) {
      final gem = board.gemAt(p);
      if (gem == null) continue;
      currentIds.add(gem.id);
      var sprite = _sprites[gem.id];
      if (sprite == null) {
        sprite = GemSprite(
          gem: gem,
          cellSize: cellSize,
          position: cellCenter(p),
        );
        _sprites[gem.id] = sprite;
        add(sprite);
      } else {
        sprite.updateGem(gem);
        if (animate) {
          sprite.add(MoveEffect.to(cellCenter(p),
              EffectController(duration: 0.18, curve: Curves.easeOutCubic)));
        } else {
          sprite.position = cellCenter(p);
        }
      }
    }
    final toRemove = _sprites.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in toRemove) {
      _sprites.remove(id)?.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paintBlocked = Paint()..color = const Color(0x33000000);
    final paintCell = Paint()..color = const Color(0x14FFFFFF);
    final paintIce = Paint()
      ..color = const Color(0x66B7D3FF)
      ..style = PaintingStyle.fill;
    final paintChoco = Paint()..color = const Color(0xFF5B2E13);
    final paintJelly = Paint()..color = const Color(0x6649D88B);
    final paintGrid = Paint()
      ..color = AppColors.muted.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final boardW = cellSize * board.cols;
    final boardH = cellSize * board.rows;
    final boardRect =
        Rect.fromLTWH(originPx.dx, originPx.dy, boardW, boardH);
    final bgPaint = Paint()..color = AppColors.surface.withValues(alpha: 0.6);
    final rrect = RRect.fromRectAndRadius(
        boardRect.inflate(6), const Radius.circular(16));
    canvas.drawRRect(rrect, bgPaint);

    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final rect = Rect.fromLTWH(
          originPx.dx + c * cellSize,
          originPx.dy + r * cellSize,
          cellSize,
          cellSize,
        );
        final cell = board.cells[r][c];
        if (cell.blocked) {
          canvas.drawRect(rect.deflate(2), paintBlocked);
          continue;
        }
        canvas.drawRect(rect.deflate(2), paintCell);
        if (cell.jellyLayers > 0) {
          canvas.drawRect(rect.deflate(4), paintJelly);
          if (cell.jellyLayers == 2) {
            canvas.drawRect(rect.deflate(7), paintJelly);
          }
        }
        if (cell.chocolate) {
          canvas.drawRect(rect.deflate(3), paintChoco);
        }
        if (cell.iceLayers > 0) {
          canvas.drawRect(rect.deflate(3), paintIce);
        }
        // Siatka
        canvas.drawRect(rect, paintGrid);
      }
    }
  }

  Future<void> animateSwap(Pos a, Pos b, {required double duration}) async {
    final ga = board.gemAt(a);
    final gb = board.gemAt(b);
    if (ga == null || gb == null) return;
    final sa = _sprites[ga.id];
    final sb = _sprites[gb.id];
    final targetA = cellCenter(a);
    final targetB = cellCenter(b);
    sa?.add(MoveEffect.to(targetA, EffectController(duration: duration)));
    sb?.add(MoveEffect.to(targetB, EffectController(duration: duration)));
    await Future<void>.delayed(
        Duration(milliseconds: (duration * 1000).round()));
  }

  Future<void> animateCascadeStep(CascadeStep step) async {
    // Particle burst dla każdego usuniętego pola — kolor zgodny z gemem.
    for (final p in step.removed) {
      final pos = cellCenter(p);
      // gem na board już zwykle usunięty, więc kolor z step nieznany — bierzemy biały sparkle.
      add(buildSparkle(position: pos));
    }
    // Specjale przy spawn — większy burst.
    for (final entry in step.spawnedSpecials.entries) {
      final pos = cellCenter(entry.key);
      add(buildMatchBurst(
        position: pos,
        color: _flameColorOf(entry.value),
        count: 16,
        radius: 36,
      ));
    }
    syncFromBoard(animate: true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  Color _flameColorOf(Gem gem) {
    switch (gem.color) {
      case GemColor.red:
        return AppColors.gemRed;
      case GemColor.blue:
        return AppColors.gemBlue;
      case GemColor.green:
        return AppColors.gemGreen;
      case GemColor.yellow:
        return AppColors.gemYellow;
      case GemColor.purple:
        return AppColors.gemPurple;
      case GemColor.orange:
        return AppColors.gemOrange;
    }
  }

  /// Highlight ruchu (rewarded hint).
  void flashHint(Pos a, Pos b) {
    final sa = _sprites[board.gemAt(a)?.id];
    final sb = _sprites[board.gemAt(b)?.id];
    for (final s in [sa, sb]) {
      if (s == null) continue;
      s.add(SequenceEffect([
        ScaleEffect.to(Vector2.all(1.2),
            EffectController(duration: 0.2, alternate: true)),
        ScaleEffect.to(Vector2.all(1.2),
            EffectController(duration: 0.2, alternate: true)),
      ]));
    }
  }
}
