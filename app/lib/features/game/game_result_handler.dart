// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_locale.dart';
import '../../providers/app_providers.dart';
import 'flame_components/gem_rush_game.dart';
import 'models/booster.dart';
import 'models/level_data.dart';
import 'widgets/result_dialogs.dart';

/// Wszystkie side-effects wygranej: progress, monety, daily challenge,
/// achievements, quest events, stats, dialog, interstitial.
///
/// Wydzielone z GameScreen żeby `_GameScreenState` był czytelny.
class GameResultHandler {
  GameResultHandler({
    required this.ref,
    required this.context,
    required this.levelId,
    required this.level,
    required this.game,
    required this.openingBoosters,
    required this.onRetry,
    required this.isMountedCheck,
  });

  final WidgetRef ref;
  final BuildContext context;
  final int levelId;
  final LevelData level;
  final GemRushGame? game;
  final Set<BoosterType> openingBoosters;
  final VoidCallback onRetry;
  final bool Function() isMountedCheck;

  Future<void> handleWin(GameSnapshot snap) async {
    final analytics = ref.read(analyticsProvider);
    final ads = ref.read(adsServiceProvider);

    analytics.logLevelComplete(
      levelId,
      snap.stars,
      snap.score,
      level.moves - snap.movesLeft,
    );

    final coinsEarned = await _awardCoinsAndRecordWin(snap);
    await _recordQuestEvents(snap, coinsEarned);
    await _updateStatsAndAchievements(snap, coinsEarned);

    if (!isMountedCheck()) return;
    await _showWinDialog(snap, coinsEarned, ads);

    await ads.maybeShowInterstitial(
      currentLevel: levelId,
      placement: 'post_level_win',
    );

    if (isMountedCheck()) context.pop();
  }

  Future<void> handleLose(GameSnapshot snap) async {
    final analytics = ref.read(analyticsProvider);
    final profileRepo = ref.read(profileRepoProvider);
    final progressRepo = ref.read(progressRepoProvider);
    final ads = ref.read(adsServiceProvider);

    analytics.logLevelFail(levelId, snap.goalProgress);

    profileRepo.current.lives =
        (profileRepo.current.lives - 1).clamp(0, 5);
    await profileRepo.save();
    ref.read(livesProvider.notifier).state = profileRepo.current.lives;

    await progressRepo.recordResult(
      levelId: levelId,
      stars: 0,
      score: snap.score,
      won: false,
    );

    if (!isMountedCheck()) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LoseDialog(
        onRetry: onRetry,
        onClose: () {},
        onExtraMovesRewarded: () async {
          final res = await ads.showRewarded('extra_moves');
          if (res.rewarded) {
            game?.grantExtraMoves(5);
            return true;
          }
          return false;
        },
      ),
    );

    await ads.maybeShowInterstitial(
      currentLevel: levelId,
      placement: 'post_level_lose',
    );

    if (isMountedCheck()) context.pop();
  }

  // ============================================================
  //  PRIVATE
  // ============================================================

  Future<int> _awardCoinsAndRecordWin(GameSnapshot snap) async {
    final profileRepo = ref.read(profileRepoProvider);
    final progressRepo = ref.read(progressRepoProvider);
    final dailyChallengeRepo = ref.read(dailyChallengeRepoProvider);

    final isDailyChallenge =
        dailyChallengeRepo.isDailyChallenge(levelId, DateTime.now());
    final dailyBonus = isDailyChallenge
        ? dailyChallengeRepo
            .ensureForToday(DateTime.now(), progressRepo.highestUnlocked)
            .bonusCoins
        : 0;
    final coinsEarned = 10 +
        (snap.stars > 1 ? 5 : 0) +
        (snap.stars > 2 ? 10 : 0) +
        dailyBonus;
    await profileRepo.addCoins(coinsEarned);
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    await progressRepo.recordResult(
      levelId: levelId,
      stars: snap.stars,
      score: snap.score,
      won: true,
    );
    if (isDailyChallenge) {
      await dailyChallengeRepo.markCompleted(DateTime.now());
    }
    return coinsEarned;
  }

  Future<void> _recordQuestEvents(GameSnapshot snap, int coinsEarned) async {
    final quests = ref.read(questsRepoProvider);
    final now = DateTime.now();
    await quests.recordEvent(now, questId: 'win_3');
    await quests.recordEvent(now, questId: 'win_5');
    await quests.recordEvent(now,
        questId: 'win_no_boost', delta: openingBoosters.isEmpty ? 1 : 0);
    await quests.recordEvent(now, questId: 'star_5', delta: snap.stars);
    await quests.recordEvent(now, questId: 'coins_100', delta: coinsEarned);
    final maxCascade = game?.maxCascadeReached ?? 0;
    if (maxCascade >= 3) {
      await quests.recordEvent(now, questId: 'cascade_3');
    }
    if (maxCascade >= 4) {
      await quests.recordEvent(now, questId: 'combo_4');
    }
    if (snap.score >= 50000) {
      await quests.recordEvent(now, questId: 'score_50k', delta: snap.score);
    }
  }

  Future<void> _updateStatsAndAchievements(
      GameSnapshot snap, int coinsEarned) async {
    final stats = ref.read(statsRepoProvider);
    final achievements = ref.read(achievementsRepoProvider);
    final profileRepo = ref.read(profileRepoProvider);
    final progressRepo = ref.read(progressRepoProvider);

    await stats.recordGamePlayed(
      won: true,
      score: snap.score,
      maxCascadeStep: game?.maxCascadeReached ?? 0,
    );
    await stats.recordCoinsEarned(coinsEarned);

    final updates = <(String, int)>[
      ('first_blood', progressRepo.highestUnlocked),
      ('rookie', progressRepo.highestUnlocked),
      ('persistent', progressRepo.highestUnlocked),
      ('master', progressRepo.highestUnlocked),
      ('legend', progressRepo.highestUnlocked),
      ('eternal', progressRepo.highestUnlocked),
      ('star_hunter', progressRepo.totalStars),
      ('star_master', progressRepo.totalStars),
      ('star_perfectionist', progressRepo.totalStars),
      ('star_legend', progressRepo.totalStars),
      ('star_eternal', progressRepo.totalStars),
      ('big_spender', stats.current.totalCoinsSpent),
    ];
    if ((game?.maxCascadeReached ?? 0) >= 5) {
      updates.add(('combo_kid', 1));
    }
    for (final (id, value) in updates) {
      final res = await achievements.setProgress(id, value);
      if (res.hasUnlocks) {
        await profileRepo.addCoins(res.coinsEarned);
        ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
        for (final def in res.justUnlocked) {
          if (!isMountedCheck()) break;
          final ctx = context;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                '🏆 ${def.localizedName(ctx)}! +${def.coinReward} '
                '${ctx.tr(en: 'coins', pl: 'monet')}',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _showWinDialog(GameSnapshot snap, int coinsEarned, dynamic ads) async {
    final profileRepo = ref.read(profileRepoProvider);
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
  }
}
