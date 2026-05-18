import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../../data/repositories/level_repository.dart';
import '../../providers/app_providers.dart';
import 'flame_components/gem_rush_game.dart';
import 'models/booster.dart';
import 'models/level_data.dart';
import 'world_theme.dart';
import 'widgets/booster_bar.dart';
import 'widgets/hud.dart';
import 'widgets/pause_dialog.dart';
import 'widgets/pre_game_dialog.dart';
import 'widgets/result_dialogs.dart';
import 'widgets/tutorial_overlay.dart';

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
      );
    });
  }

  Future<void> _handleWin(GameSnapshot snap) async {
    final analytics = ref.read(analyticsProvider);
    final profileRepo = ref.read(profileRepoProvider);
    final progressRepo = ref.read(progressRepoProvider);
    final ads = ref.read(adsServiceProvider);

    analytics.logLevelComplete(
      widget.levelId,
      snap.stars,
      snap.score,
      _level!.moves - snap.movesLeft,
    );

    final coinsEarned =
        10 + (snap.stars > 1 ? 5 : 0) + (snap.stars > 2 ? 10 : 0);
    await profileRepo.addCoins(coinsEarned);
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    await progressRepo.recordResult(
      levelId: widget.levelId,
      stars: snap.stars,
      score: snap.score,
      won: true,
    );

    // Stats + Achievements
    final stats = ref.read(statsRepoProvider);
    final achievements = ref.read(achievementsRepoProvider);
    await stats.recordGamePlayed(
      won: true,
      score: snap.score,
      maxCascadeStep: _game?.maxCascadeReached ?? 0,
    );
    await stats.recordCoinsEarned(coinsEarned);
    final updates = <(String, int)>[
      ('first_blood', progressRepo.highestUnlocked),
      ('rookie', progressRepo.highestUnlocked),
      ('persistent', progressRepo.highestUnlocked),
      ('master', progressRepo.highestUnlocked),
      ('legend', progressRepo.highestUnlocked),
      ('star_hunter', progressRepo.totalStars),
      ('star_master', progressRepo.totalStars),
      ('star_perfectionist', progressRepo.totalStars),
      ('star_legend', progressRepo.totalStars),
      ('big_spender', stats.current.totalCoinsSpent),
    ];
    if ((_game?.maxCascadeReached ?? 0) >= 5) {
      updates.add(('combo_kid', 1));
    }
    for (final (id, value) in updates) {
      final res = await achievements.setProgress(id, value);
      if (res.hasUnlocks) {
        await profileRepo.addCoins(res.coinsEarned);
        ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
        for (final def in res.justUnlocked) {
          if (!mounted) break;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🏆 ${def.name}! +${def.coinReward} monet'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WinDialog(
        score: snap.score,
        stars: snap.stars,
        coinsEarned: coinsEarned,
        onContinue: () {},
        onDoubleCoinsRewarded: () async {
          final result = await ads.showRewarded('double_coins');
          if (result.rewarded) {
            await profileRepo.addCoins(coinsEarned);
            ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
            return true;
          }
          return false;
        },
      ),
    );

    await ads.maybeShowInterstitial(
      currentLevel: widget.levelId,
      placement: 'post_level_win',
    );

    if (mounted) context.pop();
  }

  Future<void> _handleLose(GameSnapshot snap) async {
    final analytics = ref.read(analyticsProvider);
    final profileRepo = ref.read(profileRepoProvider);
    final progressRepo = ref.read(progressRepoProvider);
    final ads = ref.read(adsServiceProvider);

    analytics.logLevelFail(widget.levelId, snap.goalProgress);

    profileRepo.current.lives =
        (profileRepo.current.lives - 1).clamp(0, 5);
    await profileRepo.save();
    ref.read(livesProvider.notifier).state = profileRepo.current.lives;

    await progressRepo.recordResult(
      levelId: widget.levelId,
      stars: 0,
      score: snap.score,
      won: false,
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LoseDialog(
        onRetry: () {
          if (mounted) {
            setState(() => _game = null);
            _preGameShown = true; // skip dialog na retry
            _loadLevel();
          }
        },
        onClose: () {},
        onExtraMovesRewarded: () async {
          final res = await ads.showRewarded('extra_moves');
          if (res.rewarded) {
            _game?.grantExtraMoves(5);
            return true;
          }
          return false;
        },
      ),
    );

    await ads.maybeShowInterstitial(
      currentLevel: widget.levelId,
      placement: 'post_level_lose',
    );

    if (mounted) context.pop();
  }

  Future<void> _onHintTap() async {
    final ads = ref.read(adsServiceProvider);
    final profileRepo = ref.read(profileRepoProvider);
    if (ads.isRewardedReady('hint')) {
      final res = await ads.showRewarded('hint');
      if (!res.rewarded) return;
    } else {
      final ok = await profileRepo.spendCoins(50);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Za mało monet')),
          );
        }
        return;
      }
      ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    }
    final found = _game?.useHint() ?? false;
    if (!found && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępnych ruchów — tasuję')),
      );
      await _game?.useShuffle();
    }
  }

  Future<void> _onShuffleTap() async {
    final profileRepo = ref.read(profileRepoProvider);
    final ok = await profileRepo.spendCoins(75);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Za mało monet')),
        );
      }
      return;
    }
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    await _game?.useShuffle();
  }

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
