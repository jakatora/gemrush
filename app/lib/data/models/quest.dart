import 'dart:math';

import 'package:hive/hive.dart';

part 'quest.g.dart';

@HiveType(typeId: 7)
class QuestSet extends HiveObject {
  @HiveField(0)
  int dateKeyYyyymmdd;

  @HiveField(1)
  List<Quest> quests;

  QuestSet({
    this.dateKeyYyyymmdd = 0,
    this.quests = const [],
  });

  bool isForToday(DateTime now) =>
      dateKeyYyyymmdd == now.year * 10000 + now.month * 100 + now.day;

  int get completedCount => quests.where((q) => q.completed).length;
}

@HiveType(typeId: 8)
class Quest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int target;

  @HiveField(4)
  int progress;

  @HiveField(5)
  int coinReward;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  bool claimed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
    required this.coinReward,
    this.completed = false,
    this.claimed = false,
  });

  double get progressRatio =>
      target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);
}

/// Statyczna pula questów — losowane są 3 dziennie.
class QuestPool {
  static const all = [
    _Q('win_3', 'Wygraj 3 poziomy', '', 3, 30),
    _Q('win_5', 'Wygraj 5 poziomów', '', 5, 50),
    _Q('cascade_3', 'Wykonaj kaskadę 3×', 'W jednej grze', 1, 40),
    _Q('special_5', 'Stwórz 5 gemów specjalnych', 'W ciągu dnia', 5, 60),
    _Q('coins_100', 'Zarób 100 monet', 'Z poziomów', 100, 30),
    _Q('booster_use', 'Użyj 2 boostery', '', 2, 25),
    _Q('score_50k', 'Zdobądź 50 000 punktów', 'W jednym poziomie', 50000, 80),
    _Q('star_5', 'Zdobądź 5 gwiazdek', '', 5, 50),
    _Q('combo_4', 'Wykonaj kaskadę 4×', '', 1, 70),
    _Q('hint_use', 'Użyj 1 podpowiedź', '', 1, 15),
    _Q('shuffle_1', 'Użyj 1 tasowanie', '', 1, 20),
    _Q('win_no_boost', 'Wygraj 2 poziomy bez boosterów', '', 2, 60),
  ];

  static List<Quest> pickRandom(int count, int seed) {
    final pool = List<_Q>.of(all);
    pool.shuffle(Random(seed));
    return pool.take(count).map(_toQuest).toList();
  }

  static Quest _toQuest(_Q d) => Quest(
        id: d.id,
        title: d.title,
        description: d.desc,
        target: d.target,
        coinReward: d.reward,
      );
}

class _Q {
  final String id;
  final String title;
  final String desc;
  final int target;
  final int reward;
  const _Q(this.id, this.title, this.desc, this.target, this.reward);
}
