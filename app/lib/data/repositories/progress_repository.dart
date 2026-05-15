import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/level_progress.dart';

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
    final existing = _box.get(levelId);
    if (existing == null) {
      await _box.put(
        levelId,
        LevelProgress(
          levelId: levelId,
          stars: won ? stars : 0,
          bestScore: won ? score : 0,
          attempts: 1,
        ),
      );
      return;
    }
    existing.attempts += 1;
    if (won) {
      if (stars > existing.stars) existing.stars = stars;
      if (score > existing.bestScore) existing.bestScore = score;
    }
    await existing.save();
  }

  bool isUnlocked(int levelId) {
    if (levelId <= 1) return true;
    final prev = _box.get(levelId - 1);
    return prev != null && prev.stars > 0;
  }

  int get highestUnlocked {
    var i = 1;
    while (i <= 100 && isUnlocked(i + 1)) {
      i += 1;
    }
    return i;
  }

  int get totalStars =>
      _box.values.fold<int>(0, (sum, lp) => sum + lp.stars);
}
