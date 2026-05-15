import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/achievement.dart';
import 'data/models/app_settings.dart';
import 'data/models/daily_state.dart';
import 'data/models/game_stats.dart';
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
  Hive.registerAdapter(DailyStateAdapter());
  Hive.registerAdapter(AchievementProgressAdapter());
  Hive.registerAdapter(GameStatsAdapter());

  final container = ProviderContainer();

  await container.read(profileRepoProvider).init();
  await container.read(progressRepoProvider).init();
  // Heal: napraw stare zapisy "won ze stars=0" które blokowaly kolejny poziom.
  await container.read(progressRepoProvider).healZeroStarWins();
  await container.read(settingsRepoProvider).init();
  await container.read(dailyRepoProvider).init();
  await container.read(achievementsRepoProvider).init();
  await container.read(statsRepoProvider).init();
  await container.read(audioProvider).init();

  final settings = container.read(settingsRepoProvider).current;
  container.read(audioProvider).soundEnabled = settings.soundEnabled;
  container.read(audioProvider).musicEnabled = settings.musicEnabled;
  container.read(hapticsProvider).enabled = settings.hapticsEnabled;

  // AdMob i IAP istnieją TYLKO na Android/iOS. Na desktopie (Windows/macOS/Linux)
  // pluginy nie mają implementacji i rzucają wyjątki — dlatego pomijamy je
  // całkowicie. Gra działa normalnie, po prostu bez reklam i sklepu.
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  if (isMobile) {
    // Consent + AdMob — fire-and-forget, nie blokuje runApp.
    () async {
      try {
        final consent = container.read(consentProvider);
        final canAds = await consent.requestConsent();
        await consent.requestATTIfNeeded();
        if (canAds) {
          final ads = container.read(adsServiceProvider);
          await ads.init();
          await ads.preloadRewarded('extra_life');
          await ads.preloadRewarded('extra_moves');
          await ads.preloadRewarded('hint');
          await ads.preloadRewarded('double_coins');
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[main] ads init skipped: $e');
      }
    }();

    () async {
      try {
        await container.read(iapServiceProvider).init();
        final profile = container.read(profileRepoProvider).current;
        container.read(adsServiceProvider).removeAdsPurchased =
            profile.removeAdsPurchased;
      } catch (e) {
        if (kDebugMode) debugPrint('[main] iap init skipped: $e');
      }
    }();
  }

  container.read(profileRepoProvider).regenerateLives(DateTime.now());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GemRushApp(),
    ),
  );
}
