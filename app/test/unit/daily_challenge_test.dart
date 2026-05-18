import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/daily_challenge.dart';

void main() {
  test('dateKeyFor returns YYYYMMDD format', () {
    expect(DailyChallenge.dateKeyFor(DateTime(2026, 5, 16)), 20260516);
    expect(DailyChallenge.dateKeyFor(DateTime(2026, 12, 31)), 20261231);
    expect(DailyChallenge.dateKeyFor(DateTime(2026, 1, 1)), 20260101);
  });

  test('isForToday true tylko gdy dateKey matches', () {
    final c = DailyChallenge(
      dateKeyYyyymmdd: 20260516,
      levelId: 5,
    );
    expect(c.isForToday(DateTime(2026, 5, 16)), true);
    expect(c.isForToday(DateTime(2026, 5, 17)), false);
    expect(c.isForToday(DateTime(2026, 5, 15, 23, 59)), false);
  });

  test('default completed=false, bonusCoins=50', () {
    final c = DailyChallenge();
    expect(c.completed, false);
    expect(c.bonusCoins, 50);
  });
}
