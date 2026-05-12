import 'package:hive/hive.dart';

part 'daily_state.g.dart';

/// Stan systemu codziennej nagrody (7-day cycle).
@HiveType(typeId: 3)
class DailyState extends HiveObject {
  @HiveField(0)
  int lastClaimedAtMs;

  @HiveField(1)
  int currentStreak;

  DailyState({
    this.lastClaimedAtMs = 0,
    this.currentStreak = 0,
  });

  static const rewards = <int>[10, 20, 30, 50, 75, 100, 200];

  /// Czy gracz może zgarnąć nagrodę "dzisiaj" (lokalny czas).
  bool canClaim(DateTime now) {
    if (lastClaimedAtMs == 0) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastClaimedAtMs);
    final lastDay = DateTime(last.year, last.month, last.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(lastDay);
  }

  /// Po pominięciu pełnego dnia streak resetuje się do 1.
  bool streakBroken(DateTime now) {
    if (lastClaimedAtMs == 0) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(lastClaimedAtMs);
    final lastDay = DateTime(last.year, last.month, last.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(lastDay).inDays > 1;
  }

  int nextRewardCoins() => rewards[currentStreak % rewards.length];
}
