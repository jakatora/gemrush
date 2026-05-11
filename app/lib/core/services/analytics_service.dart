/// Lekki wrapper analytics. Dopóki Firebase nie jest skonfigurowany
/// (wymaga założenia projektu Firebase), używamy print-stub w debug.
/// Wszystkie wywołania są fire-and-forget i nigdy nie crashują aplikacji.
library;

import 'package:flutter/foundation.dart';

class AnalyticsService {
  void logEvent(String name, [Map<String, Object?>? params]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params ?? const {}}');
    }
    // TODO: po `flutterfire configure` podłącz FirebaseAnalytics.instance.logEvent.
  }

  void logLevelStart(int levelId, int attempt) =>
      logEvent('level_start', {'level_id': levelId, 'attempt': attempt});

  void logLevelComplete(int levelId, int stars, int score, int movesUsed) =>
      logEvent('level_complete', {
        'level_id': levelId,
        'stars': stars,
        'score': score,
        'moves_used': movesUsed,
      });

  void logLevelFail(int levelId, double goalProgress) =>
      logEvent('level_fail', {
        'level_id': levelId,
        'goal_progress': goalProgress,
      });

  void logAdRequest(String type, String placement) =>
      logEvent('ad_request', {'ad_type': type, 'placement': placement});

  void logAdLoaded(String type, String placement, int loadMs) =>
      logEvent('ad_loaded',
          {'ad_type': type, 'placement': placement, 'load_time_ms': loadMs});

  void logAdShown(String type, String placement) =>
      logEvent('ad_shown', {'ad_type': type, 'placement': placement});

  void logAdFailed(String type, String placement, String error) =>
      logEvent('ad_failed',
          {'ad_type': type, 'placement': placement, 'error': error});

  void logRewardedCompleted(String placement, num reward) =>
      logEvent('rewarded_completed',
          {'placement': placement, 'reward': reward});

  void logIapPurchase(String productId, num value, String currency) =>
      logEvent('iap_purchase', {
        'product_id': productId,
        'value': value,
        'currency': currency,
      });
}
