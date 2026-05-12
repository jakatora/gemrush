import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/data/models/level_progress.dart';
import 'package:gemrush/data/repositories/progress_repository.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('.dart_tool/test_hive_progress');
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LevelProgressAdapter());
    }
  });

  setUp(() async {
    if (await Hive.boxExists('progress')) {
      await Hive.deleteBoxFromDisk('progress');
    }
  });

  test('isUnlocked: level 1 zawsze odblokowany', () async {
    final repo = ProgressRepository();
    await repo.init();
    expect(repo.isUnlocked(1), true);
    expect(repo.isUnlocked(2), false);
  });

  test('recordResult zapamiętuje best score i max stars', () async {
    final repo = ProgressRepository();
    await repo.init();
    await repo.recordResult(levelId: 1, stars: 1, score: 1000, won: true);
    expect(repo.getLevel(1)!.stars, 1);
    expect(repo.getLevel(1)!.bestScore, 1000);
    // Drugie podejście — mniej gwiazdek, mniejszy score — nic się nie zmienia.
    await repo.recordResult(levelId: 1, stars: 0, score: 500, won: false);
    expect(repo.getLevel(1)!.stars, 1);
    expect(repo.getLevel(1)!.bestScore, 1000);
    expect(repo.getLevel(1)!.attempts, 2);
    // Trzecie — 3 gwiazdki, większy score.
    await repo.recordResult(levelId: 1, stars: 3, score: 2500, won: true);
    expect(repo.getLevel(1)!.stars, 3);
    expect(repo.getLevel(1)!.bestScore, 2500);
  });

  test('odblokowanie kolejnego poziomu po wygranej', () async {
    final repo = ProgressRepository();
    await repo.init();
    await repo.recordResult(levelId: 1, stars: 1, score: 100, won: true);
    expect(repo.isUnlocked(2), true);
    expect(repo.isUnlocked(3), false);
  });

  test('totalStars sumuje gwiazdki', () async {
    final repo = ProgressRepository();
    await repo.init();
    await repo.recordResult(levelId: 1, stars: 3, score: 100, won: true);
    await repo.recordResult(levelId: 2, stars: 2, score: 100, won: true);
    expect(repo.totalStars, 5);
  });
}
