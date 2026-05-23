import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Wynik wyświetlenia reklamy rewarded.
class RewardedResult {
  final bool rewarded;
  final num amount;
  final String? error;
  const RewardedResult({
    required this.rewarded,
    this.amount = 0,
    this.error,
  });
}

/// AdsService — STUB. Plugin `google_mobile_ads` został tymczasowo usunięty
/// z pubspec (crashował startup na realnym Androidzie).
///
/// Wszystkie metody pozostają z tym samym sygnaturkiem co poprzednio, ale są
/// no-op. To pozwala consumerom (GameScreen, ShopScreen, dialogi) zostać
/// niezmodyfikowanym. Gdy podłożymy z powrotem plugin, podmieniamy
/// implementację tej klasy — reszta projektu się nie ruszy.
class AdsService {
  AdsService({required this.analytics});

  final AnalyticsService analytics;

  int interstitialCooldownSeconds = 90;
  int interstitialLevelsBetween = 2;
  int interstitialFirstLevelAllowed = 4;
  int rewardedDailyCap = 5;

  bool removeAdsPurchased = false;

  Future<void> init() async {
    if (kDebugMode) debugPrint('[ads] STUB — plugin disabled');
  }

  Future<void> preloadInterstitial() async {}
  Future<void> preloadRewarded(String placement) async {}

  Future<bool> maybeShowInterstitial({
    required int currentLevel,
    required String placement,
  }) async {
    return false;
  }

  Future<RewardedResult> showRewarded(String placement) async {
    return const RewardedResult(rewarded: false, error: 'ads_disabled');
  }

  bool isRewardedReady(String placement) => false;

  int rewardedShowsRemaining(String placement) => rewardedDailyCap;

  void dispose() {}
}
