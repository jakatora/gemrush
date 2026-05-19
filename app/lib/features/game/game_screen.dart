import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../../data/repositories/level_repository.dart';
import '../../providers/app_providers.dart';
import 'booster_actions.dart';
import 'flame_components/gem_rush_game.dart';
import 'game_result_handler.dart';
import 'models/booster.dart';
import 'models/level_data.dart';
import 'widgets/booster_bar.dart';
import 'widgets/hud.dart';
import 'widgets/pause_dialog.dart';
import 'widgets/pre_game_dialog.dart';
import 'widgets/tutorial_overlay.dart';
import 'world_theme.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.levelId});
  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  LevelData? _level;
  GemRushGame? _game;
  GameSnapshot _snapshot = const GameSnapshot(
    score: 0,
    movesLeft: 0,
    goalProgress: 0,
    stars: 0,
    isWin: false,
    isLose: false,
  );
  final _repo = LevelRepository();
  String? _loadError;
  Set<BoosterType> _openingBoosters = {};
  bool _preGameShown = false;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLevel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flame sam pauzuje pętlę gry na background — nie potrzebujemy ręcznie
    // ustawiać `busy`. Wcześniej setowalismy busy=true na pause ale nie
    // odznaczalismy na resume → gra zostawala zamrozona po powrocie z tla.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(audioProvider).stopMusic();
    }
  }

  Future<void> _loadLevel() async {
    final analytics = ref.read(analyticsProvider);
    analytics.logLevelStart(widget.levelId, 1);
    final data = await _repo.tryLoad(widget.levelId);
    if (!mounted) return;
    if (data == null) {
      setState(() => _loadError = 'Brak danych poziomu ${widget.levelId}');
      return;
    }
    setState(() => _level = data);

    // Tutorial dla nowych graczy — tylko level 1 i tylko jeśli jeszcze nie ukończony.
    final progress = ref.read(progressRepoProvider);
    if (widget.levelId == 1 && (progress.getLevel(1)?.stars ?? 0) == 0) {
      _showTutorial = true;
    }

    if (!_preGameShown && mounted) {
      _preGameShown = true;
      await _showPreGame(data);
    } else {
      _spawnGame(data);
    }
  }

  Future<void> _showPreGame(LevelData data) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PreGameDialog(
        level: data,
        onStart: (selected) {
          _openingBoosters = selected;
          Navigator.of(context).pop(true);
        },
      ),
    );
    if (result != true) {
      if (mounted) context.pop();
      return;
    }
    // Deduct cost
    final cost = _openingBoosters.fold<int>(0, (s, b) => s + b.coinCost);
    if (cost > 0) {
      final ok = await ref.read(profileRepoProvider).spendCoins(cost);
      if (!ok) _openingBoosters = {}; // safety
      ref.read(coinsProvider.notifier).state =
          ref.read(profileRepoProvider).current.coins;
    }
    _spawnGame(data);
  }

  void _spawnGame(LevelData data) {
    final haptics = ref.read(hapticsProvider);
    setState(() {
      _game = GemRushGame(
        levelData: data,
        openingBoosters: _openingBoosters,
        onUpdate: (s) {
          if (!mounted) return;
          setState(() => _snapshot = s);
        },
        onWin: _handleWin,
        onLose: _handleLose,
        onHapticEvent: (event) {
          switch (event) {
            case 'swap':
              haptics.onSwap();
            case 'match3':
              haptics.onMatch3();
            case 'match4':
              haptics.onMatch4();
            case 'match_big':
              haptics.onMatchBig();
            case 'special':
              haptics.onSpecialExplode();
              // Quest: special_5 — utworzenie gemu specjalnego (match-4/5/L).
              ref.read(questsRepoProvider).recordEvent(DateTime.now(),
                  questId: 'special_5');
            case 'cascade':
              haptics.onCascadeCombo();
            case 'win':
              haptics.onLevelWin();
            case 'lose':
              haptics.onLevelLose();
          }
        },
      );
    });
  }

  GameResultHandler _resultHandler() => GameResultHandler(
        ref: ref,
        context: context,
        levelId: widget.levelId,
        level: _level!,
        game: _game,
        openingBoosters: _openingBoosters,
        onRetry: () {
          if (mounted) {
            setState(() => _game = null);
            _preGameShown = true;
            _loadLevel();
          }
        },
        isMountedCheck: () => mounted,
      );

  Future<void> _handleWin(GameSnapshot snap) => _resultHandler().handleWin(snap);
  Future<void> _handleLose(GameSnapshot snap) =>
      _resultHandler().handleLose(snap);

  BoosterActions _boosters() => BoosterActions(
        ref: ref,
        context: context,
        game: _game,
        isMountedCheck: () => mounted,
      );

  Future<void> _onHintTap() => _boosters().hint();
  Future<void> _onShuffleTap() => _boosters().shuffle();
  Future<void> _onExtraMovesTap() => _boosters().extraMoves();

  void _pauseMenu() {
    if (_game != null) _game!.busy = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PauseDialog(
        onResume: () {
          if (_game != null) _game!.busy = false;
        },
        onRestart: () {
          if (mounted) {
            setState(() => _game = null);
            _preGameShown = true;
            _loadLevel();
          }
        },
        onQuit: () => context.go(Routes.map),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_loadError!)),
      );
    }
    if (_game == null || _level == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = WorldTheme.forLevel(widget.levelId);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.gradient.first,
              const Color(0xFF0E0B2C),
            ],
          ),
        ),
        child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  GameHud(
                    levelId: widget.levelId,
                    score: _snapshot.score,
                    movesLeft: _snapshot.movesLeft,
                    goals: _game!.goals,
                    onPause: _pauseMenu,
                  ),
                  Expanded(
                    child: GameWidget(
                      game: _game!,
                      loadingBuilder: (_) => const ColoredBox(
                        color: Color(0xFF2A1E70),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFB627),
                          ),
                        ),
                      ),
                      errorBuilder: (_, _) => const ColoredBox(
                        color: Color(0xFF2A1E70),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nie udało się załadować poziomu. Spróbuj ponownie.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  BoosterBar(
                    busy: _game?.busy ?? false,
                    onHintTap: _onHintTap,
                    onShuffleTap: _onShuffleTap,
                    onExtraMovesTap: _onExtraMovesTap,
                  ),
                ],
              ),
            ),
            if (_showTutorial)
              Positioned.fill(
                child: TutorialOverlay(
                  onDone: () => setState(() => _showTutorial = false),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
