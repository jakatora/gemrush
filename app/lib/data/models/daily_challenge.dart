import 'package:hive/hive.dart';

part 'daily_challenge.g.dart';

/// Codzienne wyzwanie — gracz losowy poziom z bonusem 2× monety.
/// Resetuje się każdej północy lokalnego czasu.
@HiveType(typeId: 6)
class DailyChallenge extends HiveObject {
  @HiveField(0)
  int dateKeyYyyymmdd; // np. 20260516

  @HiveField(1)
  int levelId; // który poziom jest dzisiejszym wyzwaniem

  @HiveField(2)
  bool completed;

  @HiveField(3)
  int bonusCoins; // przyznawane po wygranej

  DailyChallenge({
    this.dateKeyYyyymmdd = 0,
    this.levelId = 1,
    this.completed = false,
    this.bonusCoins = 50,
  });

  static int dateKeyFor(DateTime d) =>
      d.year * 10000 + d.month * 100 + d.day;

  bool isForToday(DateTime now) => dateKeyYyyymmdd == dateKeyFor(now);
}
