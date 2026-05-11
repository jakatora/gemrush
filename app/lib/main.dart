import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/app_settings.dart';
import 'data/models/level_progress.dart';
import 'data/models/profile.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(LevelProgressAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  final container = ProviderContainer();

  await container.read(profileRepoProvider).init();
  await container.read(progressRepoProvider).init();
  await container.read(settingsRepoProvider).init();
  await container.read(audioProvider).init();

  final settings = container.read(settingsRepoProvider).current;
  container.read(audioProvider).soundEnabled = settings.soundEnabled;
  container.read(audioProvider).musicEnabled = settings.musicEnabled;
  container.read(hapticsProvider).enabled = settings.hapticsEnabled;

  // Consent + AdMob — fire-and-forget, nie blokuje runApp.
  () async {
    final consent = container.read(consentProvider);
    final canAds = await consent.requestConsent();
    await consent.requestATTIfNeeded();
    if (canAds) {
      await container.read(adsServiceProvider).init();
      final ads = container.read(adsServiceProvider);
      await ads.preloadRewarded('extra_life');
      await ads.preloadRewarded('extra_moves');
      await ads.preloadRewarded('hint');
      await ads.preloadRewarded('double_coins');
    }
  }();

  () async {
    await container.read(iapServiceProvider).init();
    final profile = container.read(profileRepoProvider).current;
    container.read(adsServiceProvider).removeAdsPurchased =
        profile.removeAdsPurchased;
  }();

  container.read(profileRepoProvider).regenerateLives(DateTime.now());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GemRushApp(),
    ),
  );
}
