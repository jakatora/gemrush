import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import '../../core/i18n/app_locale.dart';

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
  final String nameEn;
  final String description;
  final String descriptionEn;
  final int target;
  final int coinReward;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.target,
    this.coinReward = 50,
  });

  String localizedName(BuildContext context) =>
      LocaleScope.of(context) == AppLocale.pl ? name : nameEn;

  String localizedDescription(BuildContext context) =>
      LocaleScope.of(context) == AppLocale.pl ? description : descriptionEn;

  static const all = <AchievementDef>[
    AchievementDef(
      id: 'first_blood',
      name: 'Pierwsze zwycięstwo',
      nameEn: 'First Win',
      description: 'Ukończ pierwszy poziom',
      descriptionEn: 'Complete your first level',
      target: 1,
      coinReward: 20,
    ),
    AchievementDef(
      id: 'rookie',
      name: 'Początkujący',
      nameEn: 'Rookie',
      description: 'Ukończ 10 poziomów',
      descriptionEn: 'Complete 10 levels',
      target: 10,
    ),
    AchievementDef(
      id: 'persistent',
      name: 'Wytrwały',
      nameEn: 'Persistent',
      description: 'Ukończ 50 poziomów',
      descriptionEn: 'Complete 50 levels',
      target: 50,
      coinReward: 200,
    ),
    AchievementDef(
      id: 'master',
      name: 'Mistrz GemRush',
      nameEn: 'Gem Rush Master',
      description: 'Ukończ 100 poziomów',
      descriptionEn: 'Complete 100 levels',
      target: 100,
      coinReward: 1000,
    ),
    AchievementDef(
      id: 'legend',
      name: 'Legenda GemRush',
      nameEn: 'Gem Rush Legend',
      description: 'Ukończ 200 poziomów',
      descriptionEn: 'Complete 200 levels',
      target: 200,
      coinReward: 3000,
    ),
    AchievementDef(
      id: 'eternal',
      name: 'Wieczny Mistrz',
      nameEn: 'Eternal Master',
      description: 'Ukończ wszystkie 300 poziomów',
      descriptionEn: 'Complete all 300 levels',
      target: 300,
      coinReward: 7500,
    ),
    AchievementDef(
      id: 'star_hunter',
      name: 'Łowca gwiazd',
      nameEn: 'Star Hunter',
      description: 'Zdobądź 50 gwiazdek',
      descriptionEn: 'Earn 50 stars',
      target: 50,
      coinReward: 150,
    ),
    AchievementDef(
      id: 'star_master',
      name: 'Władca gwiazd',
      nameEn: 'Star Master',
      description: 'Zdobądź 200 gwiazdek',
      descriptionEn: 'Earn 200 stars',
      target: 200,
      coinReward: 500,
    ),
    AchievementDef(
      id: 'star_perfectionist',
      name: 'Perfekcjonista',
      nameEn: 'Perfectionist',
      description: 'Zdobądź 300 gwiazdek',
      descriptionEn: 'Earn 300 stars',
      target: 300,
      coinReward: 2000,
    ),
    AchievementDef(
      id: 'star_legend',
      name: 'Niebiański Władca',
      nameEn: 'Celestial Sovereign',
      description: 'Zdobądź 600 gwiazdek',
      descriptionEn: 'Earn 600 stars',
      target: 600,
      coinReward: 5000,
    ),
    AchievementDef(
      id: 'star_eternal',
      name: 'Gwiazda Wieczna',
      nameEn: 'Eternal Star',
      description: 'Zdobądź wszystkie 900 gwiazdek',
      descriptionEn: 'Earn all 900 stars',
      target: 900,
      coinReward: 10000,
    ),
    AchievementDef(
      id: 'combo_kid',
      name: 'Combo Kid',
      nameEn: 'Combo Kid',
      description: 'Wykonaj kaskadę 5x',
      descriptionEn: 'Trigger a 5x cascade',
      target: 1,
      coinReward: 75,
    ),
    AchievementDef(
      id: 'big_spender',
      name: 'Bogacz',
      nameEn: 'Big Spender',
      description: 'Wydaj 500 monet',
      descriptionEn: 'Spend 500 coins',
      target: 500,
      coinReward: 100,
    ),
    AchievementDef(
      id: 'daily_streak_7',
      name: 'Tygodniowy rytuał',
      nameEn: 'Weekly Ritual',
      description: 'Zaloguj się 7 dni z rzędu',
      descriptionEn: 'Log in 7 days in a row',
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
