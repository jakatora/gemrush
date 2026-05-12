import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_stats.dart';

class StatsRepository {
  static const _boxName = 'stats';
  static const _key = 'global';
  late final Box<GameStats> _box;

  Future<void> init() async {
    _box = await Hive.openBox<GameStats>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, GameStats());
    }
  }

  GameStats get current => _box.get(_key)!;

  Future<void> recordGamePlayed({required bool won, required int score, required int maxCascadeStep}) async {
    final s = current;
    s.gamesPlayed += 1;
    if (won) s.gamesWon += 1;
    if (score > s.highestScore) s.highestScore = score;
    if (maxCascadeStep > s.maxCascade) s.maxCascade = maxCascadeStep;
    await s.save();
  }

  Future<void> recordCoinsEarned(int amount) async {
    current.totalCoinsEarned += amount;
    await current.save();
  }

  Future<void> recordCoinsSpent(int amount) async {
    current.totalCoinsSpent += amount;
    await current.save();
  }

  Future<void> recordBoosterUsed() async {
    current.boostersUsed += 1;
    await current.save();
  }

  Future<void> recordRewardedAd() async {
    current.rewardedAdsWatched += 1;
    await current.save();
  }

  Future<void> recordInterstitial() async {
    current.interstitialsShown += 1;
    await current.save();
  }
}
