import 'package:hive_flutter/hive_flutter.dart';

import '../models/profile.dart';

class ProfileRepository {
  static const _boxName = 'profile';
  static const _key = 'me';

  late final Box<Profile> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Profile>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, Profile());
    }
  }

  Profile get current => _box.get(_key)!;

  Future<void> save() async {
    await current.save();
  }

  Future<void> addCoins(int amount) async {
    final p = current;
    p.coins += amount;
    await p.save();
  }

  Future<bool> spendCoins(int amount) async {
    final p = current;
    if (p.coins < amount) return false;
    p.coins -= amount;
    await p.save();
    return true;
  }

  Future<void> setLives(int lives) async {
    final p = current;
    p.lives = lives.clamp(0, Profile.maxLives);
    await p.save();
  }

  /// Liczy regenerację życ na podstawie ostatniego znacznika czasu.
  /// Zwraca aktualną liczbę żyć.
  int regenerateLives(DateTime now) {
    final p = current;
    if (p.unlimitedLivesActive && p.unlimitedLivesUntil > now.millisecondsSinceEpoch) {
      return Profile.maxLives;
    }
    if (p.unlimitedLivesActive && p.unlimitedLivesUntil <= now.millisecondsSinceEpoch) {
      p.unlimitedLivesActive = false;
    }
    if (p.lives >= Profile.maxLives) {
      p.lastLifeRegenAt = now.millisecondsSinceEpoch;
      p.save();
      return p.lives;
    }
    if (p.lastLifeRegenAt == 0) {
      p.lastLifeRegenAt = now.millisecondsSinceEpoch;
      p.save();
      return p.lives;
    }
    final elapsedSec = (now.millisecondsSinceEpoch - p.lastLifeRegenAt) ~/ 1000;
    final earned = elapsedSec ~/ Profile.lifeRegenSeconds;
    if (earned <= 0) return p.lives;
    final newLives = (p.lives + earned).clamp(0, Profile.maxLives);
    final consumed = newLives - p.lives;
    p.lives = newLives;
    p.lastLifeRegenAt += consumed * Profile.lifeRegenSeconds * 1000;
    if (newLives == Profile.maxLives) {
      p.lastLifeRegenAt = now.millisecondsSinceEpoch;
    }
    p.save();
    return p.lives;
  }

  Duration timeUntilNextLife(DateTime now) {
    final p = current;
    if (p.lives >= Profile.maxLives) return Duration.zero;
    if (p.lastLifeRegenAt == 0) return Duration.zero;
    final nextAtMs =
        p.lastLifeRegenAt + Profile.lifeRegenSeconds * 1000;
    final remaining = nextAtMs - now.millisecondsSinceEpoch;
    if (remaining <= 0) return Duration.zero;
    return Duration(milliseconds: remaining);
  }

  Future<void> markRemoveAdsPurchased() async {
    final p = current;
    p.removeAdsPurchased = true;
    await p.save();
  }
}
