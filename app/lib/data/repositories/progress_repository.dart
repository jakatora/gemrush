import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/level_progress.dart';
import 'level_repository.dart' show totalLevels;

class ProgressRepository {
  static const _boxName = 'progress';
  late final Box<LevelProgress> _box;

  Future<void> init() async {
    _box = await Hive.openBox<LevelProgress>(_boxName);
  }

  /// Box jako listenable — używane przez ValueListenableBuilder w MapScreen
  /// żeby UI mapy auto-rebuild gdy zapiszemy nowy postęp z GameScreen.
  ValueListenable<Box<LevelProgress>> listenable() => _box.listenable();

  LevelProgress? getLevel(int levelId) => _box.get(levelId);

  Future<void> recordResult({
    required int levelId,
    required int stars,
    required int score,
    required bool won,
  }) async {
    // Safety net: jeśli wygrał (warunek poziomu spełniony), to z definicji
    // ma co najmniej 1 gwiazdkę — niezależnie od wyliczenia. Bez tego stars=0
    // blokuje odblokowanie kolejnego poziomu.
    final effectiveStars = won ? (stars < 1 ? 1 : stars) : 0;
    final existing = _box.get(levelId);
    if (existing == null) {
      await _box.put(
        levelId,
        LevelProgress(
          levelId: levelId,
          stars: effectiveStars,
          bestScore: won ? score : 0,
          attempts: 1,
        ),
      );
      return;
    }
    existing.attempts += 1;
    if (won) {
      if (effectiveStars > existing.stars) existing.stars = effectiveStars;
      if (score > existing.bestScore) existing.bestScore = score;
    }
    await existing.save();
  }

  /// One-time heal: jeśli istnieją zapisy z `attempts > 0 && stars == 0` które
  /// powstały z poprzedniego buga (won bez nagrody gwiazdy), bump stars→1.
  /// Wywoływane raz przy starcie aplikacji w main.dart.
  Future<int> healZeroStarWins() async {
    var healed = 0;
    for (final p in _box.values.toList()) {
      if (p.attempts > 0 && p.stars == 0 && p.bestScore > 0) {
        p.stars = 1;
        await p.save();
        healed += 1;
      }
    }
    return healed;
  }

  bool isUnlocked(int levelId) {
    if (levelId <= 1) return true;
    final prev = _box.get(levelId - 1);
    return prev != null && prev.stars > 0;
  }

  int get highestUnlocked {
    var i = 1;
    while (i < totalLevels && isUnlocked(i + 1)) {
      i += 1;
    }
    return i;
  }

  int get totalStars =>
      _box.values.fold<int>(0, (sum, lp) => sum + lp.stars);
}
