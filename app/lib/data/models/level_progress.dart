import 'package:hive/hive.dart';

part 'level_progress.g.dart';

@HiveType(typeId: 1)
class LevelProgress extends HiveObject {
  @HiveField(0)
  int levelId;

  @HiveField(1)
  int stars;

  @HiveField(2)
  int bestScore;

  @HiveField(3)
  int attempts;

  LevelProgress({
    required this.levelId,
    this.stars = 0,
    this.bestScore = 0,
    this.attempts = 0,
  });
}
