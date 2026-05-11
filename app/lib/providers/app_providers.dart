import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/ads_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/consent_service.dart';
import '../core/services/haptics_service.dart';
import '../core/services/iap_service.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';

/// Pojedyncze providery serwisów. Wszystkie ustawiane przez `init()` w `main.dart`.
final analyticsProvider = Provider<AnalyticsService>((_) => AnalyticsService());

final hapticsProvider = Provider<HapticsService>((_) => HapticsService());

final audioProvider = Provider<AudioService>((_) => AudioService());

final consentProvider = Provider<ConsentService>((_) => ConsentService());

final profileRepoProvider = Provider<ProfileRepository>((_) => ProfileRepository());
final progressRepoProvider = Provider<ProgressRepository>((_) => ProgressRepository());
final settingsRepoProvider = Provider<SettingsRepository>((_) => SettingsRepository());

final adsServiceProvider = Provider<AdsService>((ref) {
  final analytics = ref.read(analyticsProvider);
  return AdsService(analytics: analytics);
});

final iapServiceProvider = Provider<IapService>((ref) {
  return IapService(
    profileRepo: ref.read(profileRepoProvider),
    analytics: ref.read(analyticsProvider),
  );
});

/// Reactive: aktualna liczba monet i żyć (do widgetów HUD/Menu).
final coinsProvider = StateProvider<int>((ref) {
  return ref.read(profileRepoProvider).current.coins;
});
final livesProvider = StateProvider<int>((ref) {
  return ref.read(profileRepoProvider).current.lives;
});
