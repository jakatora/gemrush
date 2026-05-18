import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/quest.dart';

void main() {
  test('pickRandom zwraca dokładnie N questow', () {
    final picked = QuestPool.pickRandom(3, 42);
    expect(picked.length, 3);
  });

  test('pickRandom z tym samym seed zwraca te same questy', () {
    final a = QuestPool.pickRandom(3, 12345);
    final b = QuestPool.pickRandom(3, 12345);
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
  });

  test('pickRandom z roznym seed zwraca rozne questy (zwykle)', () {
    final a = QuestPool.pickRandom(3, 1);
    final b = QuestPool.pickRandom(3, 999);
    // Conservative: oczekujemy ze przynajmniej jeden jest inny
    final aIds = a.map((q) => q.id).toSet();
    final bIds = b.map((q) => q.id).toSet();
    expect(aIds.intersection(bIds).length, lessThan(3));
  });

  test('wszystkie questy w puli maja niepuste pola', () {
    for (final q in QuestPool.pickRandom(QuestPool.all.length, 0)) {
      expect(q.id, isNotEmpty);
      expect(q.title, isNotEmpty);
      expect(q.target, greaterThan(0));
      expect(q.coinReward, greaterThan(0));
    }
  });

  test('Quest progressRatio handle target=0 i clamp do 1.0', () {
    final q = Quest(
      id: 'x',
      title: 'x',
      description: '',
      target: 0,
      coinReward: 10,
    );
    expect(q.progressRatio, 0.0);

    final q2 = Quest(
      id: 'y',
      title: 'y',
      description: '',
      target: 10,
      coinReward: 10,
      progress: 999,
    );
    expect(q2.progressRatio, 1.0);
  });
}
