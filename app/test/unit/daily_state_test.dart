import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/daily_state.dart';

void main() {
  test('canClaim true gdy nigdy nie odebrano', () {
    final s = DailyState();
    expect(s.canClaim(DateTime(2026, 5, 12)), true);
  });

  test('canClaim false gdy odebrano dzisiaj', () {
    final now = DateTime(2026, 5, 12, 14, 30);
    final s = DailyState(
      lastClaimedAtMs: now.millisecondsSinceEpoch,
      currentStreak: 1,
    );
    expect(s.canClaim(now.add(const Duration(hours: 2))), false);
  });

  test('canClaim true gdy minął dzień', () {
    final last = DateTime(2026, 5, 11, 14, 30);
    final s = DailyState(
      lastClaimedAtMs: last.millisecondsSinceEpoch,
      currentStreak: 1,
    );
    expect(s.canClaim(DateTime(2026, 5, 12)), true);
  });

  test('streakBroken po 2 dniach przerwy', () {
    final last = DateTime(2026, 5, 10);
    final s = DailyState(lastClaimedAtMs: last.millisecondsSinceEpoch);
    expect(s.streakBroken(DateTime(2026, 5, 12)), true);
  });

  test('streakBroken false gdy 1 dzień przerwy', () {
    final last = DateTime(2026, 5, 11);
    final s = DailyState(lastClaimedAtMs: last.millisecondsSinceEpoch);
    expect(s.streakBroken(DateTime(2026, 5, 12)), false);
  });

  test('nextRewardCoins iteruje 7-dniowy cykl', () {
    final s = DailyState();
    expect(s.nextRewardCoins(), 10);
    s.currentStreak = 6;
    expect(s.nextRewardCoins(), 200);
    s.currentStreak = 7;
    expect(s.nextRewardCoins(), 10); // cykl restartuje
  });
}
