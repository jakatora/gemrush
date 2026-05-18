import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/daily_challenge.dart';

class DailyChallengeRepository {
  static const _boxName = 'daily_challenge';
  static const _key = 'today';
  late final Box<DailyChallenge> _box;

  Future<void> init() async {
    _box = await Hive.openBox<DailyChallenge>(_boxName);
  }

  /// Zwraca wyzwanie na dzisiaj; jeśli nie istnieje lub jest sprzed dziś,
  /// generuje nowe (deterministicznie z daty — wszyscy mają ten sam poziom
  /// dnia).
  DailyChallenge ensureForToday(DateTime now, int highestUnlocked) {
    final todayKey = DailyChallenge.dateKeyFor(now);
    var ch = _box.get(_key);
    if (ch == null || !ch.isForToday(now)) {
      // Generuj — z seed = dateKey, level z zakresu 1..min(50, highestUnlocked)
      final rng = Random(todayKey);
      final maxLevel = highestUnlocked.clamp(1, 50);
      final levelId = 1 + rng.nextInt(maxLevel);
      ch = DailyChallenge(
        dateKeyYyyymmdd: todayKey,
        levelId: levelId,
        completed: false,
        bonusCoins: 50,
      );
      _box.put(_key, ch);
    }
    return ch;
  }

  Future<void> markCompleted(DateTime now) async {
    final ch = _box.get(_key);
    if (ch != null && ch.isForToday(now) && !ch.completed) {
      ch.completed = true;
      await ch.save();
    }
  }

  bool isDailyChallenge(int levelId, DateTime now) {
    final ch = _box.get(_key);
    return ch != null && ch.isForToday(now) && ch.levelId == levelId;
  }
}
