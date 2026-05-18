import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 4)
class AchievementProgress extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int progress;

  @HiveField(2)
  int unlockedAtMs;

  AchievementProgress({
    required this.id,
    this.progress = 0,
    this.unlockedAtMs = 0,
  });

  bool get isUnlocked => unlockedAtMs > 0;
}

/// Statyczna definicja achievementu (nie persisted).
class AchievementDef {
  final String id;
  final String name;
  final String description;
  final int target;
  final int coinReward;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
    this.coinReward = 50,
  });

  static const all = <AchievementDef>[
    AchievementDef(
      id: 'first_blood',
      name: 'Pierwsze zwycięstwo',
      description: 'Ukończ pierwszy poziom',
      target: 1,
      coinReward: 20,
    ),
    AchievementDef(
      id: 'rookie',
      name: 'Początkujący',
      description: 'Ukończ 10 poziomów',
      target: 10,
    ),
    AchievementDef(
      id: 'persistent',
      name: 'Wytrwały',
      description: 'Ukończ 50 poziomów',
      target: 50,
      coinReward: 200,
    ),
    AchievementDef(
      id: 'master',
      name: 'Mistrz GemRush',
      description: 'Ukończ 100 poziomów',
      target: 100,
      coinReward: 1000,
    ),
    AchievementDef(
      id: 'legend',
      name: 'Legenda GemRush',
      description: 'Ukończ 200 poziomów',
      target: 200,
      coinReward: 3000,
    ),
    AchievementDef(
      id: 'eternal',
      name: 'Wieczny Mistrz',
      description: 'Ukończ wszystkie 300 poziomów',
      target: 300,
      coinReward: 7500,
    ),
    AchievementDef(
      id: 'star_hunter',
      name: 'Łowca gwiazd',
      description: 'Zdobądź 50 gwiazdek',
      target: 50,
      coinReward: 150,
    ),
    AchievementDef(
      id: 'star_master',
      name: 'Władca gwiazd',
      description: 'Zdobądź 200 gwiazdek',
      target: 200,
      coinReward: 500,
    ),
    AchievementDef(
      id: 'star_perfectionist',
      name: 'Perfekcjonista',
      description: 'Zdobądź 300 gwiazdek',
      target: 300,
      coinReward: 2000,
    ),
    AchievementDef(
      id: 'star_legend',
      name: 'Niebiański Władca',
      description: 'Zdobądź 600 gwiazdek',
      target: 600,
      coinReward: 5000,
    ),
    AchievementDef(
      id: 'star_eternal',
      name: 'Gwiazda Wieczna',
      description: 'Zdobądź wszystkie 900 gwiazdek',
      target: 900,
      coinReward: 10000,
    ),
    AchievementDef(
      id: 'combo_kid',
      name: 'Combo Kid',
      description: 'Wykonaj kaskadę 5x',
      target: 1,
      coinReward: 75,
    ),
    AchievementDef(
      id: 'big_spender',
      name: 'Bogacz',
      description: 'Wydaj 500 monet',
      target: 500,
      coinReward: 100,
    ),
    AchievementDef(
      id: 'daily_streak_7',
      name: 'Tygodniowy rytuał',
      description: 'Zaloguj się 7 dni z rzędu',
      target: 7,
      coinReward: 200,
    ),
  ];

  static AchievementDef? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
