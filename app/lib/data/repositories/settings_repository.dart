import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';

class SettingsRepository {
  static const _boxName = 'settings';
  static const _key = 'app';

  late final Box<AppSettings> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AppSettings>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, AppSettings());
    }
  }

  AppSettings get current => _box.get(_key)!;

  Future<void> setSound(bool v) async {
    current.soundEnabled = v;
    await current.save();
  }

  Future<void> setMusic(bool v) async {
    current.musicEnabled = v;
    await current.save();
  }

  Future<void> setHaptics(bool v) async {
    current.hapticsEnabled = v;
    await current.save();
  }

  Future<void> setLanguage(String v) async {
    current.language = v;
    await current.save();
  }

  Future<void> setConsentGiven(bool v) async {
    current.consentGiven = v;
    await current.save();
  }

  Future<void> setColorBlindMode(bool v) async {
    current.colorBlindMode = v;
    await current.save();
  }
}
