import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/env_config.dart';
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

/// AdsService — pełna obsługa AdMob:
/// - Interstitial po poziomie z frequency capping
/// - Rewarded dla 4 placementów (extra_life, extra_moves, hint, double_coins)
/// - Preload przed pokazem
/// - Respekt dla `removeAdsPurchased` (interstitial wyłączony, rewarded zostaje)
class AdsService {
  AdsService({required this.analytics});

  final AnalyticsService analytics;

  // Frequency capping (konfigurowalne przez Remote Config w przyszłości)
  int interstitialCooldownSeconds = 90;
  int interstitialLevelsBetween = 2;
  int interstitialFirstLevelAllowed = 4;
  int rewardedDailyCap = 5;

  bool removeAdsPurchased = false;
  bool _initialized = false;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  DateTime? _lastInterstitialAt;
  int _levelsSinceLastInterstitial = 0;

  final Map<String, RewardedAd?> _rewardedByPlacement = {};
  final Map<String, bool> _rewardedLoading = {};
  final Map<String, int> _rewardedShowsToday = {};
  DateTime? _rewardedCountResetDay;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      if (kDebugMode) {
        debugPrint('[ads] initialized. Using test IDs: '
            '${EnvConfig.usingTestAdIds}');
      }
      // Test device IDs — w developmencie pomaga dostać prawdziwe wypełnienia z testowych slotów
      if (EnvConfig.isDev) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: const []),
        );
      }
      unawaited(preloadInterstitial());
    } catch (e) {
      if (kDebugMode) debugPrint('[ads] init error: $e');
    }
  }

  // ============================================================
  //  INTERSTITIAL
  // ============================================================

  Future<void> preloadInterstitial() async {
    if (!_initialized) return;
    if (removeAdsPurchased) return;
    if (_interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    analytics.logAdRequest('interstitial', 'post_level');
    final loadStart = DateTime.now();
    await InterstitialAd.load(
      adUnitId: EnvConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          analytics.logAdLoaded(
            'interstitial',
            'post_level',
            DateTime.now().difference(loadStart).inMilliseconds,
          );
        },
        onAdFailedToLoad: (err) {
          _loadingInterstitial = false;
          _interstitial = null;
          analytics.logAdFailed(
              'interstitial', 'post_level', err.message);
          if (kDebugMode) debugPrint('[ads] interstitial load failed: $err');
        },
      ),
    );
  }

  /// Wywoływany po zakończeniu poziomu. Zwraca true jeśli reklama została pokazana.
  Future<bool> maybeShowInterstitial({
    required int currentLevel,
    required String placement,
  }) async {
    _levelsSinceLastInterstitial += 1;

    if (removeAdsPurchased) return false;
    if (currentLevel < interstitialFirstLevelAllowed) return false;

    final now = DateTime.now();
    if (_lastInterstitialAt != null) {
      final since = now.difference(_lastInterstitialAt!).inSeconds;
      if (since < interstitialCooldownSeconds) return false;
    }
    if (_levelsSinceLastInterstitial < interstitialLevelsBetween) return false;

    final ad = _interstitial;
    if (ad == null) {
      unawaited(preloadInterstitial());
      return false;
    }

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        analytics.logAdShown('interstitial', placement);
      },
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _interstitial = null;
        unawaited(preloadInterstitial());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (a, err) {
        a.dispose();
        _interstitial = null;
        analytics.logAdFailed('interstitial', placement, err.message);
        unawaited(preloadInterstitial());
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await ad.show();
    _lastInterstitialAt = now;
    _levelsSinceLastInterstitial = 0;
    return completer.future;
  }

  // ============================================================
  //  REWARDED
  // ============================================================

  Future<void> preloadRewarded(String placement) async {
    if (!_initialized) return;
    if (_rewardedByPlacement[placement] != null) return;
    if (_rewardedLoading[placement] == true) return;
    _rewardedLoading[placement] = true;
    analytics.logAdRequest('rewarded', placement);
    final loadStart = DateTime.now();
    await RewardedAd.load(
      adUnitId: EnvConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedByPlacement[placement] = ad;
          _rewardedLoading[placement] = false;
          analytics.logAdLoaded(
            'rewarded',
            placement,
            DateTime.now().difference(loadStart).inMilliseconds,
          );
        },
        onAdFailedToLoad: (err) {
          _rewardedLoading[placement] = false;
          _rewardedByPlacement[placement] = null;
          analytics.logAdFailed('rewarded', placement, err.message);
          if (kDebugMode) debugPrint('[ads] rewarded load failed: $err');
        },
      ),
    );
  }

  /// Pokazuje rewarded ad dla wskazanego placement.
  /// placement ∈ {extra_life, extra_moves, hint, double_coins}
  Future<RewardedResult> showRewarded(String placement) async {
    if (!_initialized) {
      return const RewardedResult(rewarded: false, error: 'not_initialized');
    }
    _checkRewardedDailyReset();
    final shows = _rewardedShowsToday[placement] ?? 0;
    if (shows >= rewardedDailyCap) {
      return const RewardedResult(rewarded: false, error: 'daily_cap');
    }
    final ad = _rewardedByPlacement[placement];
    if (ad == null) {
      unawaited(preloadRewarded(placement));
      return const RewardedResult(rewarded: false, error: 'not_ready');
    }

    final completer = Completer<RewardedResult>();
    num rewardAmount = 0;
    bool earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        analytics.logAdShown('rewarded', placement);
      },
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _rewardedByPlacement[placement] = null;
        unawaited(preloadRewarded(placement));
        if (!completer.isCompleted) {
          if (earned) {
            _rewardedShowsToday[placement] = shows + 1;
            analytics.logRewardedCompleted(placement, rewardAmount);
          }
          completer.complete(RewardedResult(
              rewarded: earned, amount: rewardAmount));
        }
      },
      onAdFailedToShowFullScreenContent: (a, err) {
        a.dispose();
        _rewardedByPlacement[placement] = null;
        analytics.logAdFailed('rewarded', placement, err.message);
        if (!completer.isCompleted) {
          completer.complete(RewardedResult(
              rewarded: false, error: err.message));
        }
      },
    );

    await ad.show(onUserEarnedReward: (_, reward) {
      earned = true;
      rewardAmount = reward.amount;
    });
    return completer.future;
  }

  void _checkRewardedDailyReset() {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    if (_rewardedCountResetDay == null ||
        _rewardedCountResetDay!.isBefore(day)) {
      _rewardedShowsToday.clear();
      _rewardedCountResetDay = day;
    }
  }

  bool isRewardedReady(String placement) =>
      _rewardedByPlacement[placement] != null;

  int rewardedShowsRemaining(String placement) {
    _checkRewardedDailyReset();
    final used = _rewardedShowsToday[placement] ?? 0;
    return (rewardedDailyCap - used).clamp(0, rewardedDailyCap);
  }

  void dispose() {
    _interstitial?.dispose();
    for (final ad in _rewardedByPlacement.values) {
      ad?.dispose();
    }
  }
}
