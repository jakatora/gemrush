import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../game_logic/board.dart';
import '../game_logic/cascade_engine.dart';
import '../game_logic/gem.dart';
import '../game_logic/goal_checker.dart';
import '../game_logic/hint_finder.dart';
import '../game_logic/match_finder.dart';
import '../game_logic/score_engine.dart';
import '../game_logic/special_gem_effects.dart';
import '../models/booster.dart';
import '../models/level_data.dart';
import 'board_renderer.dart';

/// Główny komponent Flame: trzyma stan domeny + warstwę wizualną.
class GemRushGame extends FlameGame with DragCallbacks, TapCallbacks {
  GemRushGame({
    required this.levelData,
    required this.onUpdate,
    required this.onWin,
    required this.onLose,
    this.openingBoosters = const {},
  });

  final LevelData levelData;
  final Set<BoosterType> openingBoosters;
  final void Function(GameSnapshot) onUpdate;
  final void Function(GameSnapshot) onWin;
  final void Function(GameSnapshot) onLose;

  late Board board;
  late GoalChecker goals;
  final ScoreEngine score = ScoreEngine();
  final CascadeEngine cascadeEngine = CascadeEngine();
  late BoardRenderer renderer;

  int movesLeft = 0;
  bool busy = false;
  int maxCascadeReached = 0;
  final bool _settled = true;

  @override
  Color backgroundColor() => const Color(0xFF1B1640);

  @override
  Future<void> onLoad() async {
    movesLeft = levelData.moves;
    board = Board(
      rows: levelData.rows,
      cols: levelData.cols,
      allowedColors: levelData.allowedColors,
      rng: Random(),
    );
    _applyLayout();
    board.fillRandomNoMatches();
    if (!board.hasAnyValidMove()) {
      board.shuffleUntilPlayable();
    }
    goals = GoalChecker(levelData.goals);

    renderer = BoardRenderer(board: board, gameSize: size);
    await add(renderer);

    _applyOpeningBoosters();

    renderer.syncFromBoard(animate: false);
    _emit();
  }

  void _applyOpeningBoosters() {
    if (openingBoosters.contains(BoosterType.extraMoves)) {
      movesLeft += 5;
    }
    if (openingBoosters.contains(BoosterType.colorBombStart)) {
      // Wstaw color bomb na środku, podmieniając istniejący gem.
      final center = Pos(board.rows ~/ 2, board.cols ~/ 2);
      final cell = board.cellAt(center);
      if (cell.isPlayable) {
        cell.gem = Gem(
          id: board.nextId(),
          color: GemColor.red,
          kind: GemKind.colorBomb,
        );
      }
    }
  }

  // ============================================================
  //  PUBLIC API — używane przez UI (booster bar, rewarded hint)
  // ============================================================

  /// Znajduje możliwy ruch i pokazuje highlight.
  /// Zwraca true jeśli znaleziono, false jeśli trzeba shuffle.
  bool useHint() {
    final hint = HintFinder().findHint(board);
    if (hint == null) return false;
    renderer.flashHint(hint.a, hint.b);
    return true;
  }

  /// Tasuje planszę aż znajdzie konfigurację z dostępnym ruchem.
  Future<void> useShuffle() async {
    busy = true;
    board.shuffleUntilPlayable();
    renderer.syncFromBoard(animate: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    busy = false;
  }

  /// Rozbija pojedynczy klejnot na danej pozycji (booster Hammer).
  Future<void> useHammerAt(Pos p) async {
    if (busy) return;
    if (!board.inBounds(p)) return;
    final gem = board.gemAt(p);
    if (gem == null) return;
    busy = true;
    board.setGem(p, null);
    final gMoves = cascadeEngine.gravity.applyGravity(board);
    final rMoves = cascadeEngine.gravity.refillTop(board);
    renderer.syncFromBoard(animate: true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    // Następnie naturalna kaskada — jeśli powstały matche, rozwiąż.
    final steps = cascadeEngine.processFullCascade(
      board,
      score: score,
      goals: goals,
    );
    for (final s in steps) {
      await renderer.animateCascadeStep(s);
    }
    busy = false;
    _emit();
    _checkWinLose();
    // unused move maps — silencer
    gMoves.length;
    rMoves.length;
  }

  void _checkWinLose() {
    if (goals.allGoalsMet) {
      _onWin();
    } else if (movesLeft <= 0) {
      _onLose();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_settled && size.x > 0 && size.y > 0 && isLoaded) {
      renderer.updateLayout(size);
    }
  }

  void _applyLayout() {
    for (var r = 0; r < levelData.rows && r < levelData.layout.length; r++) {
      final row = levelData.layout[r];
      for (var c = 0; c < levelData.cols && c < row.length; c++) {
        final ch = row[c];
        final cell = board.cells[r][c];
        switch (ch) {
          case 'G':
            break;
          case 'J':
            cell.jellyLayers = 1;
            break;
          case 'K':
            cell.jellyLayers = 2;
            break;
          case 'I':
            cell.iceLayers = 1;
            break;
          case 'C':
            cell.chocolate = true;
            break;
          case 'X':
            cell.blocked = true;
            break;
          case '.':
            cell.blocked = true;
            break;
          default:
            break;
        }
      }
    }
  }

  // ============================================================
  //  GESTURES
  // ============================================================

  Pos? _dragStart;
  bool _dragHandled = false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (busy) return;
    _dragHandled = false;
    final pos = renderer.posFromGlobal(event.canvasPosition);
    _dragStart = pos;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragHandled || _dragStart == null) return;
    final delta = event.localDelta;
    final threshold = renderer.cellSize * 0.4;
    if (delta.length < 1) return;
    final accum = renderer.dragAccumulate(delta);
    if (accum.distance < threshold) return;
    final dx = accum.dx;
    final dy = accum.dy;
    Pos target;
    if (dx.abs() > dy.abs()) {
      target = dx > 0 ? _dragStart!.right : _dragStart!.left;
    } else {
      target = dy > 0 ? _dragStart!.down : _dragStart!.up;
    }
    _dragHandled = true;
    renderer.dragReset();
    _attemptSwap(_dragStart!, target);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _dragStart = null;
    _dragHandled = false;
    renderer.dragReset();
  }

  // ============================================================
  //  SWAP + KASKADA
  // ============================================================

  Future<void> _attemptSwap(Pos a, Pos b) async {
    if (busy) return;
    if (!board.inBounds(a) || !board.inBounds(b)) return;
    if (!a.isAdjacentTo(b)) return;
    final ga = board.gemAt(a);
    final gb = board.gemAt(b);
    if (ga == null || gb == null) return;
    busy = true;
    movesLeft -= 1;

    // 1. Wstępna animacja swap
    if (!board.swap(a, b)) {
      busy = false;
      return;
    }
    await renderer.animateSwap(a, b, duration: 0.15);

    // 2. Sprawdź combo specjali / matche
    Set<Pos> triggers = {};
    final swappedA = board.gemAt(a);
    final swappedB = board.gemAt(b);

    final combo = SpecialGemEffects().resolveCombo(board, a, b);
    if (!combo.isEmpty) {
      for (final e in combo.transforms.entries) {
        board.setGem(e.key, e.value);
      }
      triggers = {...combo.remove, ...combo.triggerAfterTransform};
    } else {
      // Jeśli któryś gem jest color bomb po swapie — od razu aktywuj
      if (swappedA?.isColorBomb == true || swappedB?.isColorBomb == true) {
        triggers = {a, b};
      }
    }

    final matches = MatchFinder().findMatches(board);
    if (matches.isEmpty && triggers.isEmpty) {
      // Cofnij — niedopuszczalny ruch.
      board.swap(a, b);
      await renderer.animateSwap(a, b, duration: 0.2);
      movesLeft += 1; // zwroć ruch
      busy = false;
      _emit();
      return;
    }

    final steps = cascadeEngine.processFullCascade(
      board,
      score: score,
      goals: goals,
      swapTarget: b,
      initialTriggers: triggers,
    );

    for (final step in steps) {
      if (step.cascadeIndex > maxCascadeReached) {
        maxCascadeReached = step.cascadeIndex;
      }
      await renderer.animateCascadeStep(step);
    }

    busy = false;
    _emit();

    if (goals.allGoalsMet) {
      _onWin();
    } else if (movesLeft <= 0) {
      _onLose();
    } else if (!board.hasAnyValidMove()) {
      board.shuffleUntilPlayable();
      renderer.syncFromBoard(animate: true);
    }
  }

  void _onWin() {
    renderer.celebrateWin();
    final stars = goals.starsFromScore(score.score, levelData.starThresholds);
    onWin(GameSnapshot(
      score: score.score,
      movesLeft: movesLeft,
      goalProgress: goals.totalProgress,
      stars: stars,
      isWin: true,
      isLose: false,
    ));
  }

  void _onLose() {
    onLose(GameSnapshot(
      score: score.score,
      movesLeft: movesLeft,
      goalProgress: goals.totalProgress,
      stars: 0,
      isWin: false,
      isLose: true,
    ));
  }

  void grantExtraMoves(int n) {
    movesLeft += n;
    _emit();
  }

  void _emit() {
    onUpdate(GameSnapshot(
      score: score.score,
      movesLeft: movesLeft,
      goalProgress: goals.totalProgress,
      stars: 0,
      isWin: false,
      isLose: false,
    ));
  }
}

class GameSnapshot {
  final int score;
  final int movesLeft;
  final double goalProgress;
  final int stars;
  final bool isWin;
  final bool isLose;

  const GameSnapshot({
    required this.score,
    required this.movesLeft,
    required this.goalProgress,
    required this.stars,
    required this.isWin,
    required this.isLose,
  });
}
