import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/achievement.dart';
import 'data/models/app_settings.dart';
import 'data/models/daily_challenge.dart';
import 'data/models/daily_state.dart';
import 'data/models/game_stats.dart';
import 'data/models/level_progress.dart';
import 'data/models/profile.dart';
import 'data/models/quest.dart';
import 'features/game/flame_components/gem_sprite.dart';
import 'providers/app_providers.dart';

/// Trzymamy stage'y init żeby ErrorApp pokazał gdzie pad.
String _currentStage = 'initial';

Future<void> main() async {
  // Łap WSZYSTKO (w tym async). Bez tego: czarny ekran przy crashu w main().
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Globalny FlutterError handler — łapie błędy widgetów.
      FlutterError.onError = (details) {
        debugPrint('[flutter-error] ${details.exception}');
        debugPrint('[flutter-error] stage at crash: $_currentStage');
      };

      await _bootstrap();
    },
    (error, stack) {
      // Coś padło w runZoned. Pokaż błąd na ekranie zamiast czarnego.
      runApp(_ErrorApp(
        error: '$error',
        stage: _currentStage,
        stack: '$stack',
      ));
    },
  );
}

Future<void> _bootstrap() async {
  _currentStage = 'orientation';
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  _currentStage = 'hive_init';
  await Hive.initFlutter();

  _currentStage = 'hive_adapters';
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(LevelProgressAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(DailyStateAdapter());
  Hive.registerAdapter(AchievementProgressAdapter());
  Hive.registerAdapter(GameStatsAdapter());
  Hive.registerAdapter(DailyChallengeAdapter());
  Hive.registerAdapter(QuestSetAdapter());
  Hive.registerAdapter(QuestAdapter());

  final container = ProviderContainer();

  _currentStage = 'profile_init';
  await _safeBoxInit(() => container.read(profileRepoProvider).init(), 'profile');

  _currentStage = 'progress_init';
  await _safeBoxInit(() => container.read(progressRepoProvider).init(), 'progress');

  _currentStage = 'progress_heal';
  try {
    await container.read(progressRepoProvider).healZeroStarWins();
  } catch (e) {
    debugPrint('[bootstrap] heal failed (non-fatal): $e');
  }

  _currentStage = 'settings_init';
  await _safeBoxInit(() => container.read(settingsRepoProvider).init(), 'settings');

  _currentStage = 'daily_init';
  await _safeBoxInit(() => container.read(dailyRepoProvider).init(), 'daily');

  _currentStage = 'achievements_init';
  await _safeBoxInit(
      () => container.read(achievementsRepoProvider).init(), 'achievements');

  _currentStage = 'stats_init';
  await _safeBoxInit(() => container.read(statsRepoProvider).init(), 'stats');

  _currentStage = 'daily_challenge_init';
  await _safeBoxInit(
      () => container.read(dailyChallengeRepoProvider).init(), 'daily_challenge');

  _currentStage = 'quests_init';
  await _safeBoxInit(() => container.read(questsRepoProvider).init(), 'quests');

  _currentStage = 'audio_init';
  try {
    await container.read(audioProvider).init();
  } catch (e) {
    debugPrint('[bootstrap] audio init failed (non-fatal): $e');
  }

  _currentStage = 'settings_sync';
  final settings = container.read(settingsRepoProvider).current;
  container.read(audioProvider).soundEnabled = settings.soundEnabled;
  container.read(audioProvider).musicEnabled = settings.musicEnabled;
  container.read(hapticsProvider).enabled = settings.hapticsEnabled;
  GemSprite.colorBlindMode = settings.colorBlindMode;

  // AdMob i IAP są teraz STUBAMI (plugins usunięte z pubspec) — kod
  // niżej istnieje dla forward-compatibility gdy wrócimy do pluginów.
  _currentStage = 'mobile_services';
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (isMobile) {
    () async {
      try {
        final consent = container.read(consentProvider);
        await consent.requestConsent();
        await consent.requestATTIfNeeded();
        await container.read(adsServiceProvider).init();
      } catch (e) {
        debugPrint('[main] ads init skipped: $e');
      }
    }();
    () async {
      try {
        await container.read(iapServiceProvider).init();
      } catch (e) {
        debugPrint('[main] iap init skipped: $e');
      }
    }();
  }

  _currentStage = 'regenerate_lives';
  container.read(profileRepoProvider).regenerateLives(DateTime.now());

  _currentStage = 'runApp';
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GemRushApp(),
    ),
  );
  _currentStage = 'done';
}

/// Jeśli Hive box się popsuje (np. mismatch typeId po update), spróbuj
/// usunąć z dysku i otworzyć ponownie. Bez tego cala apka pada przy starcie.
Future<void> _safeBoxInit(
    Future<void> Function() initFn, String boxName) async {
  try {
    await initFn();
  } catch (e) {
    debugPrint('[bootstrap] box "$boxName" init failed: $e');
    debugPrint('[bootstrap] retrying after deleteBoxFromDisk...');
    try {
      await Hive.deleteBoxFromDisk(boxName);
      await initFn();
    } catch (e2) {
      debugPrint('[bootstrap] retry of "$boxName" failed: $e2');
      rethrow;
    }
  }
}

/// App pokazujący błąd startupu zamiast czarnego ekranu.
class _ErrorApp extends StatelessWidget {
  const _ErrorApp({
    required this.error,
    required this.stage,
    required this.stack,
  });

  final String error;
  final String stage;
  final String stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A0F2E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: Color(0xFFFF5C7C)),
                  const SizedBox(height: 12),
                  const Text(
                    'GemRush — błąd startupu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB627)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Stage',
                            style: TextStyle(
                                color: Color(0xFFFFB627),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        Text(stage,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 12),
                        const Text('Error',
                            style: TextStyle(
                                color: Color(0xFFFF5C7C),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        SelectableText(error,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 12),
                        const Text('Stack',
                            style: TextStyle(
                                color: Color(0xFFB8B0E0),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        SelectableText(stack,
                            style: const TextStyle(
                                color: Color(0xFFB8B0E0), fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Skopiuj powyższy tekst i wyślij — sfixuję.',
                    style: TextStyle(color: Color(0xFFB8B0E0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
