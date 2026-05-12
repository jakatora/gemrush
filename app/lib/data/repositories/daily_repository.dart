import 'package:hive_flutter/hive_flutter.dart';

import '../models/daily_state.dart';

class DailyRepository {
  static const _boxName = 'daily';
  static const _key = 'state';

  late final Box<DailyState> _box;

  Future<void> init() async {
    _box = await Hive.openBox<DailyState>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, DailyState());
    }
  }

  DailyState get current => _box.get(_key)!;

  /// Wywoływane przy starcie aplikacji. Zwraca tuple:
  /// (canClaim, rewardAmount).
  ({bool canClaim, int rewardCoins}) statusFor(DateTime now) {
    final s = current;
    if (!s.canClaim(now)) {
      return (canClaim: false, rewardCoins: 0);
    }
    if (s.streakBroken(now)) {
      // Streak reset zaplanowany — UI pokaże nagrodę dnia 1.
      return (canClaim: true, rewardCoins: DailyState.rewards.first);
    }
    return (canClaim: true, rewardCoins: s.nextRewardCoins());
  }

  /// Wywołane gdy gracz odbiera nagrodę. Zwraca przyznaną liczbę monet.
  Future<int> claim(DateTime now) async {
    final s = current;
    if (!s.canClaim(now)) return 0;
    if (s.streakBroken(now)) {
      s.currentStreak = 0;
    }
    final reward = s.nextRewardCoins();
    s.currentStreak += 1;
    s.lastClaimedAtMs = now.millisecondsSinceEpoch;
    await s.save();
    return reward;
  }
}
