import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/world_theme.dart';

void main() {
  test('forLevel zwraca odpowiedni motyw per swiat', () {
    expect(WorldTheme.forLevel(1).name, contains('Plaża'));
    expect(WorldTheme.forLevel(15).name, contains('Plaża')); // ostatni lvl swiata 1
    expect(WorldTheme.forLevel(16).name, contains('Las'));
    expect(WorldTheme.forLevel(91).name, contains('Kosmiczna'));
    expect(WorldTheme.forLevel(100).name, contains('Kosmiczna'));
    expect(WorldTheme.forLevel(200).name, contains('Pradawne'));
    expect(WorldTheme.forLevel(201).name, contains('Zimowa'));
    expect(WorldTheme.forLevel(300).name, contains('Wieczność'));
  });

  test('forWorld zwraca bezposrednio swiat', () {
    expect(WorldTheme.forWorld(7).name, contains('Kosmiczna'));
    expect(WorldTheme.forWorld(17).name, contains('Wieczność'));
  });

  test('forWorld fallback do swiata 1 dla nieznanego id', () {
    expect(WorldTheme.forWorld(999).name, contains('Plaża'));
  });

  test('kazdy motyw ma niepusty gradient i akcent', () {
    for (var w = 1; w <= 17; w++) {
      final t = WorldTheme.forWorld(w);
      expect(t.gradient.length, greaterThanOrEqualTo(2));
      expect(t.accent, isNotNull);
      expect(t.name, isNotEmpty);
    }
  });
}
