import 'package:gemrush/core/services/ads_service.dart';
import 'package:gemrush/core/services/analytics_service.dart';

/// FakeAdsService — pomija realne wywołania AdMob.
/// Konfigurowalny "isReady" oraz "rewardOnShow" do testów.
class FakeAdsService extends AdsService {
  FakeAdsService() : super(analytics: AnalyticsService());

  bool readyFlag = true;
  bool rewardOnShow = true;
  bool shownInterstitial = false;
  String? lastRewardedPlacement;

  @override
  Future<void> init() async {}

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> preloadRewarded(String placement) async {}

  @override
  bool isRewardedReady(String placement) => readyFlag;

  @override
  Future<bool> maybeShowInterstitial({
    required int currentLevel,
    required String placement,
  }) async {
    shownInterstitial = true;
    return true;
  }

  @override
  Future<RewardedResult> showRewarded(String placement) async {
    lastRewardedPlacement = placement;
    return RewardedResult(rewarded: rewardOnShow, amount: rewardOnShow ? 1 : 0);
  }
}
