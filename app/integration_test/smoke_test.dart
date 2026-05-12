// Smoke test — sprawdza że gra:
// 1. Uruchamia się (Hive + ekrany inicjalizują się)
// 2. Splash → Menu w ciągu 2 sekund
// 3. Menu renderuje przycisk "Graj"
// 4. Tap "Graj" przechodzi na mapę
//
// Uruchom: `flutter test integration_test/smoke_test.dart`
import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/app.dart';
import 'package:gemrush/data/models/app_settings.dart';
import 'package:gemrush/data/models/daily_state.dart';
import 'package:gemrush/data/models/level_progress.dart';
import 'package:gemrush/data/models/profile.dart';
import 'package:gemrush/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('.dart_tool/integration_hive');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(LevelProgressAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AppSettingsAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DailyStateAdapter());
  });

  testWidgets('Smoke: cold start → splash → menu', (tester) async {
    final container = ProviderContainer();
    await container.read(profileRepoProvider).init();
    await container.read(progressRepoProvider).init();
    await container.read(settingsRepoProvider).init();
    await container.read(dailyRepoProvider).init();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GemRushApp(),
      ),
    );
    // Splash widoczny.
    expect(find.text('GemRush'), findsWidgets);
    // Splash auto-przechodzi po 1.5s → menu.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    // Menu zawiera przycisk "Graj".
    expect(find.text('Graj'), findsOneWidget);
    // Tap "Graj" → mapa.
    await tester.tap(find.text('Graj'));
    await tester.pumpAndSettle();
    expect(find.text('Mapa świata'), findsOneWidget);
  });
}
