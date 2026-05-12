import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/achievement.dart';
import 'package:gemrush/data/repositories/achievements_repository.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('.dart_tool/test_hive_achievements');
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AchievementProgressAdapter());
    }
  });

  setUp(() async {
    if (await Hive.boxExists('achievements')) {
      await Hive.deleteBoxFromDisk('achievements');
    }
  });

  test('setProgress poniżej targetu — brak odblokowania', () async {
    final repo = AchievementsRepository();
    await repo.init();
    final res = await repo.setProgress('rookie', 5);
    expect(res.hasUnlocks, false);
    expect(res.coinsEarned, 0);
    expect(repo.isUnlocked('rookie'), false);
  });

  test('setProgress osiąga target — odblokowuje + nagroda', () async {
    final repo = AchievementsRepository();
    await repo.init();
    final res = await repo.setProgress('first_blood', 1);
    expect(res.hasUnlocks, true);
    expect(res.coinsEarned, 20); // first_blood = 20
    expect(repo.isUnlocked('first_blood'), true);
  });

  test('powtórne setProgress dla unlocked — brak ponownej nagrody', () async {
    final repo = AchievementsRepository();
    await repo.init();
    await repo.setProgress('first_blood', 1);
    final res = await repo.setProgress('first_blood', 1);
    expect(res.hasUnlocks, false);
    expect(res.coinsEarned, 0);
  });

  test('AchievementDef.byId zwraca poprawny obiekt', () {
    final def = AchievementDef.byId('master');
    expect(def, isNotNull);
    expect(def!.coinReward, 1000);
    expect(def.target, 100);
  });

  test('all() zwraca wszystkie achievementy z progressem', () async {
    final repo = AchievementsRepository();
    await repo.init();
    final all = repo.all();
    expect(all.length, AchievementDef.all.length);
  });

  test('unlockedCount liczy tylko odblokowane', () async {
    final repo = AchievementsRepository();
    await repo.init();
    expect(repo.unlockedCount, 0);
    await repo.setProgress('first_blood', 1);
    expect(repo.unlockedCount, 1);
  });
}
