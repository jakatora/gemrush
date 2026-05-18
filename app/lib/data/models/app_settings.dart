import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool musicEnabled;

  @HiveField(2)
  bool hapticsEnabled;

  @HiveField(3)
  String language;

  @HiveField(4)
  bool consentGiven;

  @HiveField(5)
  bool colorBlindMode;

  AppSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.language = 'pl',
    this.consentGiven = false,
    this.colorBlindMode = false,
  });
}
