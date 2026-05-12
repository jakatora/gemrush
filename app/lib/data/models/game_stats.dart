import 'package:hive/hive.dart';

part 'game_stats.g.dart';

@HiveType(typeId: 5)
class GameStats extends HiveObject {
  @HiveField(0)
  int gamesPlayed;

  @HiveField(1)
  int gamesWon;

  @HiveField(2)
  int totalCoinsEarned;

  @HiveField(3)
  int totalCoinsSpent;

  @HiveField(4)
  int boostersUsed;

  @HiveField(5)
  int rewardedAdsWatched;

  @HiveField(6)
  int interstitialsShown;

  @HiveField(7)
  int maxCascade;

  @HiveField(8)
  int highestScore;

  GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.boostersUsed = 0,
    this.rewardedAdsWatched = 0,
    this.interstitialsShown = 0,
    this.maxCascade = 0,
    this.highestScore = 0,
  });

  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;
}
