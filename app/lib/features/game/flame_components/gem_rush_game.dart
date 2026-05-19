import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../game_logic/board.dart';
import '../game_logic/cascade_engine.dart';
import '../game_logic/gem.dart';
import '../game_logic/goal_checker.dart';
import '../game_logic/score_engine.dart';
import '../models/booster.dart';
import '../models/level_data.dart';
import 'board_renderer.dart';
import 'game_snapshot.dart';
import 'gem_rush_game_swap.dart';

export 'game_snapshot.dart';

/// Główny komponent Flame: trzyma stan domeny + warstwę wizualną.
///
/// Splitowany na 4 pliki:
///   - `gem_rush_game.dart` (ten plik) — lifecycle, layout, gestures, win/lose
///   - `gem_rush_game_swap.dart` — extension `attemptSwap` (logika swap+cascade)
///   - `gem_rush_game_boosters.dart` — extension `useHint/useShuffle/useHammerAt`
///   - `game_snapshot.dart` — model snapshot przekazywany do UI
class GemRushGame extends FlameGame with DragCallbacks, TapCallbacks {
  GemRushGame({
    required this.levelData,
    required this.onUpdate,
    required this.onWin,
    required this.onLose,
    this.openingBoosters = const {},
    this.onHapticEvent,
  });

  final LevelData levelData;
  final Set<BoosterType> openingBoosters;
  final void Function(GameSnapshot) onUpdate;
  final void Function(GameSnapshot) onWin;
  final void Function(GameSnapshot) onLose;

  /// Optional callback for UI to map game events → haptics service.
  /// Event names: 'swap', 'match3', 'match4', 'match_big', 'special',
  /// 'cascade', 'win', 'lose'.
  final void Function(String event)? onHapticEvent;

  late Board board;
  // `goals` jest czytane przez GameHud w build() — czyli ZANIM async onLoad()
  // się wykona. Dlatego inicjalizujemy je leniwie z levelData (dostępne od
  // konstrukcji), zamiast w onLoad. Bez tego: LateInitializationError → szary ekran.
  late final GoalChecker goals = GoalChecker(levelData.goals);
  final ScoreEngine score = ScoreEngine();
  final CascadeEngine cascadeEngine = CascadeEngine();
  late BoardRenderer renderer;

  int movesLeft = 0;
  bool busy = false;
  int maxCascadeReached = 0;

  @override
  Color backgroundColor() => const Color(0xFF2A1E70);

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

    renderer = BoardRenderer(board: board, gameSize: size);
    await add(renderer);

    _applyOpeningBoosters();

    renderer.syncFromBoard(animate: false);
    emitUpdate();
  }

  void _applyOpeningBoosters() {
    if (openingBoosters.contains(BoosterType.extraMoves)) {
      movesLeft += 5;
    }
    if (openingBoosters.contains(BoosterType.colorBombStart)) {
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

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x > 0 && size.y > 0 && isLoaded) {
      renderer.updateLayout(size);
    }
  }

  @override
  void onMount() {
    super.onMount();
    if (size.x > 0 && size.y > 0) {
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
  //  GESTURES — drag detection. Swap logic w GemRushGameSwap extension.
  // ============================================================

  Pos? _dragStart;
  bool _dragHandled = false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (busy) return;
    _dragHandled = false;
    _dragStart = renderer.posFromGlobal(event.canvasPosition);
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
    attemptSwap(_dragStart!, target); // extension method from gem_rush_game_swap.dart
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _dragStart = null;
    _dragHandled = false;
    renderer.dragReset();
  }

  // ============================================================
  //  WIN/LOSE/EMIT — wywoływane z extensions (swap, boosters)
  // ============================================================

  void checkWinLose() {
    if (goals.allGoalsMet) {
      onWinInternal();
    } else if (movesLeft <= 0) {
      onLoseInternal();
    }
  }

  void onWinInternal() {
    renderer.celebrateWin();
    onHapticEvent?.call('win');
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

  void onLoseInternal() {
    onHapticEvent?.call('lose');
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
    emitUpdate();
  }

  void emitUpdate() {
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
