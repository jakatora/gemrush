import 'package:hive_flutter/hive_flutter.dart';

import '../models/achievement.dart';

/// Wynik zwracany przez progress update — informuje czy świeżo odblokowano.
class AchievementUpdateResult {
  final List<AchievementDef> justUnlocked;
  final int coinsEarned;
  AchievementUpdateResult(this.justUnlocked, this.coinsEarned);
  bool get hasUnlocks => justUnlocked.isNotEmpty;
}

class AchievementsRepository {
  static const _boxName = 'achievements';
  late final Box<AchievementProgress> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AchievementProgress>(_boxName);
  }

  AchievementProgress _getOrCreate(String id) {
    var p = _box.get(id);
    if (p == null) {
      p = AchievementProgress(id: id);
      _box.put(id, p);
    }
    return p;
  }

  AchievementProgress get(String id) => _getOrCreate(id);

  bool isUnlocked(String id) => _box.get(id)?.isUnlocked ?? false;

  /// Aktualizuje progres do `value` (bezwzględne — nie inkrementuje).
  /// Zwraca info czy odblokowano.
  Future<AchievementUpdateResult> setProgress(String id, int value) async {
    final def = AchievementDef.byId(id);
    if (def == null) return AchievementUpdateResult(const [], 0);
    final p = _getOrCreate(id);
    if (p.isUnlocked) {
      p.progress = value;
      await p.save();
      return AchievementUpdateResult(const [], 0);
    }
    p.progress = value;
    if (value >= def.target) {
      p.unlockedAtMs = DateTime.now().millisecondsSinceEpoch;
      await p.save();
      return AchievementUpdateResult([def], def.coinReward);
    }
    await p.save();
    return AchievementUpdateResult(const [], 0);
  }

  /// Inkrementuje progres o 1 (dla countowanych eventów).
  Future<AchievementUpdateResult> increment(String id) async {
    final p = _getOrCreate(id);
    return setProgress(id, p.progress + 1);
  }

  /// Pełna lista (definicja + progress).
  List<({AchievementDef def, AchievementProgress progress})> all() {
    return AchievementDef.all
        .map((def) => (def: def, progress: _getOrCreate(def.id)))
        .toList();
  }

  int get unlockedCount =>
      _box.values.where((p) => p.isUnlocked).length;
}
