import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../../data/repositories/level_repository.dart';
import '../../providers/app_providers.dart';
import 'flame_components/gem_rush_game.dart';
import 'models/level_data.dart';
import 'widgets/hud.dart';
import 'widgets/result_dialogs.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.levelId});
  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  LevelData? _level;
  GemRushGame? _game;
  GameSnapshot _snapshot =
      const GameSnapshot(score: 0, movesLeft: 0, goalProgress: 0, stars: 0, isWin: false, isLose: false);
  final _repo = LevelRepository();
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLevel();
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
    final game = GemRushGame(
      levelData: data,
      onUpdate: (s) {
        if (!mounted) return;
        setState(() => _snapshot = s);
      },
      onWin: _handleWin,
      onLose: _handleLose,
    );
    setState(() {
      _level = data;
      _game = game;
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

    final coinsEarned = 10 + (snap.stars > 1 ? 5 : 0) + (snap.stars > 2 ? 10 : 0);
    await profileRepo.addCoins(coinsEarned);
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    await progressRepo.recordResult(
      levelId: widget.levelId,
      stars: snap.stars,
      score: snap.score,
      won: true,
    );

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

    final showed = await ads.maybeShowInterstitial(
      currentLevel: widget.levelId,
      placement: 'post_level_win',
    );
    if (!showed && mounted) {
      // continue without ad
    }

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

  void _pauseMenu() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Pauza'),
        content: const Text('Wrócić do mapy świata?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Graj dalej'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(Routes.map);
            },
            child: const Text('Mapa'),
          ),
        ],
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
    return Scaffold(
      body: Column(
        children: [
          GameHud(
            levelId: widget.levelId,
            score: _snapshot.score,
            movesLeft: _snapshot.movesLeft,
            goals: _game!.goals,
            onPause: _pauseMenu,
          ),
          Expanded(child: GameWidget(game: _game!)),
        ],
      ),
    );
  }
}
