import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/app_locale.dart';
import '../core/services/ads_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/consent_service.dart';
import '../core/services/haptics_service.dart';
import '../core/services/iap_service.dart';
import '../data/repositories/achievements_repository.dart';
import '../data/repositories/daily_challenge_repository.dart';
import '../data/repositories/daily_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/quests_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/stats_repository.dart';

/// Pojedyncze providery serwisów. Wszystkie ustawiane przez `init()` w `main.dart`.
final analyticsProvider = Provider<AnalyticsService>((_) => AnalyticsService());

final hapticsProvider = Provider<HapticsService>((_) => HapticsService());

final audioProvider = Provider<AudioService>((_) => AudioService());

final consentProvider = Provider<ConsentService>((_) => ConsentService());

final profileRepoProvider = Provider<ProfileRepository>((_) => ProfileRepository());
final progressRepoProvider = Provider<ProgressRepository>((_) => ProgressRepository());
final settingsRepoProvider = Provider<SettingsRepository>((_) => SettingsRepository());
final dailyRepoProvider = Provider<DailyRepository>((_) => DailyRepository());
final achievementsRepoProvider =
    Provider<AchievementsRepository>((_) => AchievementsRepository());
final statsRepoProvider = Provider<StatsRepository>((_) => StatsRepository());
final dailyChallengeRepoProvider =
    Provider<DailyChallengeRepository>((_) => DailyChallengeRepository());
final questsRepoProvider = Provider<QuestsRepository>((_) => QuestsRepository());

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

/// Trzyma aktualny LocaleNotifier (ChangeNotifier). Init z settings repo
/// w main.dart, po init settingsRepoProvider.
final localeNotifierProvider = Provider<LocaleNotifier>((ref) {
  final settings = ref.read(settingsRepoProvider).current;
  return LocaleNotifier(AppLocale.fromCode(settings.language));
});

/// Reactive: aktualna liczba monet i żyć (do widgetów HUD/Menu).
final coinsProvider = StateProvider<int>((ref) {
  return ref.read(profileRepoProvider).current.coins;
});
final livesProvider = StateProvider<int>((ref) {
  return ref.read(profileRepoProvider).current.lives;
});
