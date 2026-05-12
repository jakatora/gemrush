import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/profile.dart';
import 'package:gemrush/data/repositories/profile_repository.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('.dart_tool/test_hive_profile');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }
  });

  setUp(() async {
    if (await Hive.boxExists('profile')) {
      await Hive.deleteBoxFromDisk('profile');
    }
  });

  test('init tworzy domyślny profil', () async {
    final repo = ProfileRepository();
    await repo.init();
    expect(repo.current.coins, 100);
    expect(repo.current.lives, 5);
  });

  test('addCoins zwiększa saldo', () async {
    final repo = ProfileRepository();
    await repo.init();
    await repo.addCoins(50);
    expect(repo.current.coins, 150);
  });

  test('spendCoins zwraca false gdy brak salda', () async {
    final repo = ProfileRepository();
    await repo.init();
    final ok = await repo.spendCoins(999);
    expect(ok, false);
    expect(repo.current.coins, 100);
  });

  test('regenerateLives przywraca jedno życie po 30 min', () async {
    final repo = ProfileRepository();
    await repo.init();
    await repo.setLives(3);
    final now = DateTime.now();
    repo.current.lastLifeRegenAt =
        now.subtract(const Duration(minutes: 30, seconds: 1)).millisecondsSinceEpoch;
    await repo.save();
    repo.regenerateLives(now);
    expect(repo.current.lives, 4);
  });

  test('regenerateLives kapuje przy max 5', () async {
    final repo = ProfileRepository();
    await repo.init();
    repo.current.lives = 5;
    repo.regenerateLives(DateTime.now());
    expect(repo.current.lives, 5);
  });
}
