import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/repositories/profile_repository.dart';
import 'analytics_service.dart';

/// Definicje produktów. Cena lokalna pobierana ze sklepu (Google/Apple) przy `loadProducts`.
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

  /// Ilość monet dawanych przez produkt (0 dla non-coin).
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

class IapService {
  IapService({required this.profileRepo, required this.analytics});

  final ProfileRepository profileRepo;
  final AnalyticsService analytics;
  final InAppPurchase _iap = InAppPurchase.instance;

  bool _available = false;
  bool get available => _available;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => _products;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      if (kDebugMode) debugPrint('[iap] store not available');
      return;
    }
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate, onDone: () {
      _sub?.cancel();
    });
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_available) return;
    final resp = await _iap.queryProductDetails(IapProducts.all);
    if (resp.error != null) {
      if (kDebugMode) debugPrint('[iap] query error: ${resp.error}');
    }
    for (final p in resp.productDetails) {
      _products[p.id] = p;
    }
    if (kDebugMode) {
      debugPrint('[iap] loaded ${_products.length}/${IapProducts.all.length}');
    }
  }

  Future<bool> buy(String productId) async {
    final p = _products[productId];
    if (p == null) {
      if (kDebugMode) debugPrint('[iap] product missing: $productId');
      return false;
    }
    final param = PurchaseParam(productDetails: p);
    if (IapProducts.nonConsumables.contains(productId)) {
      return _iap.buyNonConsumable(purchaseParam: param);
    }
    return _iap.buyConsumable(purchaseParam: param, autoConsume: false);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _handlePurchaseSuccess(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        if (kDebugMode) debugPrint('[iap] error: ${purchase.error}');
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      // Consumable confirm następuje przez `completePurchase` powyżej —
      // platforma sama oznacza zakup jako "skonsumowany".
    }
  }

  Future<void> _handlePurchaseSuccess(PurchaseDetails p) async {
    final coins = IapProducts.coinsFor(p.productID);
    if (coins > 0) {
      await profileRepo.addCoins(coins);
    }
    if (p.productID == IapProducts.removeAds) {
      await profileRepo.markRemoveAdsPurchased();
    }
    if (p.productID == IapProducts.starterPack) {
      await profileRepo.setLives(5);
    }
    if (p.productID == IapProducts.unlimitedLives24h) {
      final profile = profileRepo.current;
      profile.unlimitedLivesActive = true;
      profile.unlimitedLivesUntil =
          DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
      await profile.save();
    }
    analytics.logIapPurchase(p.productID, 0, 'PLN');
    // TODO[BLOCKER B-IAP-RECEIPT]: walidacja receipta po stronie backendu
    // (przeciw spoof'om). Wymaga Cloud Function + Google Play Developer API +
    // Apple App Store Verification endpoint.
  }

  void dispose() {
    _sub?.cancel();
  }
}
