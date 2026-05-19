import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'flame_components/gem_rush_game.dart';
import 'flame_components/gem_rush_game_boosters.dart';

/// Booster tap handlers (hint, shuffle, +5 ruchów) wydzielone z GameScreen.
class BoosterActions {
  BoosterActions({
    required this.ref,
    required this.context,
    required this.game,
    required this.isMountedCheck,
  });

  final WidgetRef ref;
  final BuildContext context;
  final GemRushGame? game;
  final bool Function() isMountedCheck;

  Future<void> hint() async {
    final ads = ref.read(adsServiceProvider);
    final profileRepo = ref.read(profileRepoProvider);
    if (ads.isRewardedReady('hint')) {
      final res = await ads.showRewarded('hint');
      if (!res.rewarded) return;
    } else {
      final ok = await profileRepo.spendCoins(50);
      if (!ok) {
        _snack('Za mało monet');
        return;
      }
      ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    }
    final found = game?.useHint() ?? false;
    await ref
        .read(questsRepoProvider)
        .recordEvent(DateTime.now(), questId: 'hint_use');
    await ref
        .read(questsRepoProvider)
        .recordEvent(DateTime.now(), questId: 'booster_use');
    await ref.read(statsRepoProvider).recordBoosterUsed();
    if (!found && isMountedCheck()) {
      _snack('Brak dostępnych ruchów — tasuję');
      await game?.useShuffle();
    }
  }

  Future<void> shuffle() async {
    final profileRepo = ref.read(profileRepoProvider);
    final ok = await profileRepo.spendCoins(75);
    if (!ok) {
      _snack('Za mało monet');
      return;
    }
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    await game?.useShuffle();
    await ref
        .read(questsRepoProvider)
        .recordEvent(DateTime.now(), questId: 'shuffle_1');
    await ref
        .read(questsRepoProvider)
        .recordEvent(DateTime.now(), questId: 'booster_use');
    await ref.read(statsRepoProvider).recordBoosterUsed();
    await ref.read(statsRepoProvider).recordCoinsSpent(75);
  }

  Future<void> extraMoves() async {
    final ads = ref.read(adsServiceProvider);
    final profileRepo = ref.read(profileRepoProvider);
    if (ads.isRewardedReady('extra_moves')) {
      final res = await ads.showRewarded('extra_moves');
      if (res.rewarded) {
        game?.grantExtraMoves(5);
        await ref.read(statsRepoProvider).recordBoosterUsed();
      }
      return;
    }
    final ok = await profileRepo.spendCoins(200);
    if (!ok) {
      _snack('Za mało monet');
      return;
    }
    ref.read(coinsProvider.notifier).state = profileRepo.current.coins;
    game?.grantExtraMoves(5);
    await ref
        .read(questsRepoProvider)
        .recordEvent(DateTime.now(), questId: 'booster_use');
    await ref.read(statsRepoProvider).recordBoosterUsed();
    await ref.read(statsRepoProvider).recordCoinsSpent(200);
  }

  void _snack(String msg) {
    if (!isMountedCheck()) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
