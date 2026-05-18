import 'package:hive_flutter/hive_flutter.dart';

import '../models/quest.dart';

class QuestsRepository {
  static const _boxName = 'quests';
  static const _key = 'today';
  late final Box<QuestSet> _box;

  Future<void> init() async {
    _box = await Hive.openBox<QuestSet>(_boxName);
  }

  QuestSet ensureForToday(DateTime now) {
    final todayKey = now.year * 10000 + now.month * 100 + now.day;
    var set = _box.get(_key);
    if (set == null || !set.isForToday(now)) {
      final picked = QuestPool.pickRandom(3, todayKey);
      set = QuestSet(dateKeyYyyymmdd: todayKey, quests: picked);
      _box.put(_key, set);
    }
    return set;
  }

  /// Inkrementuje quest po nazwie eventu. Zwraca listę zaktualizowanych
  /// questów (do UI feedbacku).
  Future<List<Quest>> recordEvent(
    DateTime now, {
    required String questId,
    int delta = 1,
  }) async {
    final set = ensureForToday(now);
    final updated = <Quest>[];
    for (final q in set.quests) {
      if (q.id == questId && !q.completed) {
        q.progress = (q.progress + delta).clamp(0, q.target);
        if (q.progress >= q.target) {
          q.completed = true;
        }
        updated.add(q);
      }
    }
    if (updated.isNotEmpty) {
      await set.save();
    }
    return updated;
  }

  /// Wywoływane przy claim (gracz odbiera nagrodę). Zwraca przyznane monety.
  Future<int> claimReward(DateTime now, String questId) async {
    final set = ensureForToday(now);
    for (final q in set.quests) {
      if (q.id == questId && q.completed && !q.claimed) {
        q.claimed = true;
        await set.save();
        return q.coinReward;
      }
    }
    return 0;
  }

  List<Quest> todayQuests(DateTime now) => ensureForToday(now).quests;
}
