import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import 'analytics_service.dart';

/// Definicje produktów. Stuby do czasu podłączenia z powrotem
/// `in_app_purchase` plugin.
class IapProducts {
  static const removeAds = 'remove_ads';
  static const coins100 = 'coins_100';
  static const coins500 = 'coins_500';
  static const coins1200 = 'coins_1200';
  static const coins3000 = 'coins_3000';
  static const starterPack = 'starter_pack';
  static const weekendPack = 'weekend_pack';
  static const unlimitedLives24h = 'unlimited_lives_24h';

  static const all = {
    removeAds,
    coins100,
    coins500,
    coins1200,
    coins3000,
    starterPack,
    weekendPack,
    unlimitedLives24h,
  };

  static const nonConsumables = {removeAds, starterPack};

  static int coinsFor(String productId) => switch (productId) {
        coins100 => 100,
        coins500 => 600,
        coins1200 => 1600,
        coins3000 => 4500,
        starterPack => 200,
        weekendPack => 500,
        _ => 0,
      };
}

/// Minimalny stand-in dla ProductDetails — żeby ShopScreen się kompilował
/// bez plugin'a `in_app_purchase`.
class ProductDetails {
  final String id;
  final String title;
  final String description;
  final String price;
  const ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
}

/// IapService — STUB. Plugin `in_app_purchase` jest tymczasowo wyłączony
/// (jak google_mobile_ads, oba wymagają Google Play Services i razem
/// crashowaly launch).
///
/// Kod consumerow (ShopScreen, GameScreen.removeAdsPurchased) zostaje
/// niezmieniony. Gdy wracamy do plugin'a, podmieniamy implementację tej
/// klasy + przywracamy package w pubspec.
class IapService {
  IapService({required this.profileRepo, required this.analytics});

  final ProfileRepository profileRepo;
  final AnalyticsService analytics;

  final bool _available = false;
  bool get available => _available;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => _products;

  Future<void> init() async {
    if (kDebugMode) debugPrint('[iap] STUB — plugin disabled');
  }

  Future<void> loadProducts() async {}

  Future<bool> buy(String productId) async => false;

  Future<void> restorePurchases() async {}

  void dispose() {}
}
