import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile extends HiveObject {
  @HiveField(0)
  int coins;

  @HiveField(1)
  int lives;

  @HiveField(2)
  int lastLifeRegenAt;

  @HiveField(3)
  int lastSeenLevel;

  @HiveField(4)
  bool removeAdsPurchased;

  @HiveField(5)
  bool unlimitedLivesActive;

  @HiveField(6)
  int unlimitedLivesUntil;

  Profile({
    this.coins = 100,
    this.lives = 5,
    this.lastLifeRegenAt = 0,
    this.lastSeenLevel = 1,
    this.removeAdsPurchased = false,
    this.unlimitedLivesActive = false,
    this.unlimitedLivesUntil = 0,
  });

  static const int maxLives = 5;
  static const int lifeRegenSeconds = 30 * 60;
}
