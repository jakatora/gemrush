import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/iap_service.dart';
import '../../providers/app_providers.dart';

/// Badge typu na karcie sklepowej.
enum _Badge { none, popular, bestValue, limited }

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.watch(iapServiceProvider);
    final products = iap.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Sklep')),
      body: products.isEmpty
          ? const _StoreUnavailable()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionHeader('Wyłącz reklamy'),
                _IapCard(
                  product: products[IapProducts.removeAds],
                  ref: ref,
                  badge: _Badge.popular,
                  description: 'Bez przerw między poziomami. Reward ads zostają.',
                ),
                const SizedBox(height: 16),
                const _SectionHeader('Monety'),
                _IapCard(
                  product: products[IapProducts.coins100],
                  ref: ref,
                  description: '+100 monet',
                ),
                _IapCard(
                  product: products[IapProducts.coins500],
                  ref: ref,
                  badge: _Badge.popular,
                  description: '+600 monet (20% bonus)',
                ),
                _IapCard(
                  product: products[IapProducts.coins1200],
                  ref: ref,
                  badge: _Badge.bestValue,
                  description: '+1600 monet (33% bonus)',
                ),
                _IapCard(
                  product: products[IapProducts.coins3000],
                  ref: ref,
                  description: '+4500 monet (50% bonus)',
                ),
                const SizedBox(height: 16),
                const _SectionHeader('Pakiety'),
                _IapCard(
                  product: products[IapProducts.starterPack],
                  ref: ref,
                  badge: _Badge.limited,
                  description: '200 monet + 10 żyć + 3 boostery',
                ),
                _IapCard(
                  product: products[IapProducts.weekendPack],
                  ref: ref,
                  badge: _Badge.limited,
                  description: '500 monet + unlim. życia 24h',
                ),
                _IapCard(
                  product: products[IapProducts.unlimitedLives24h],
                  ref: ref,
                  description: '24h bez limitu żyć',
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _IapCard extends StatelessWidget {
  const _IapCard({
    required this.product,
    required this.ref,
    this.badge = _Badge.none,
    this.description,
  });

  final ProductDetails? product;
  final WidgetRef ref;
  final _Badge badge;
  final String? description;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(Icons.help_outline, color: AppColors.muted),
          title: Text('Produkt niedostępny'),
          subtitle: Text('Skonfiguruj IAP w Google Play / App Store Connect.'),
        ),
      );
    }
    final coins = IapProducts.coinsFor(product!.id);
    final isHighlight = badge == _Badge.bestValue || badge == _Badge.popular;

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlight
                ? BorderSide(
                    color: badge == _Badge.bestValue
                        ? AppColors.success
                        : AppColors.accent,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                coins > 0 ? Icons.monetization_on : Icons.shopping_bag,
                color: AppColors.accent,
              ),
            ),
            title: Text(
              product!.title.isEmpty ? product!.id : product!.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              description ?? product!.description,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: ElevatedButton(
              onPressed: () => ref.read(iapServiceProvider).buy(product!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: badge == _Badge.bestValue
                    ? AppColors.success
                    : null,
              ),
              child: Text(product!.price),
            ),
          ),
        ),
        if (badge != _Badge.none) _badgeWidget(),
      ],
    );
  }

  Widget _badgeWidget() {
    final (label, color) = switch (badge) {
      _Badge.popular => ('POPULARNY', AppColors.accent),
      _Badge.bestValue => ('NAJLEPSZA WARTOŚĆ', AppColors.success),
      _Badge.limited => ('LIMITOWANY', AppColors.danger),
      _Badge.none => ('', AppColors.primary),
    };
    return Positioned(
      top: 0,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StoreUnavailable extends StatelessWidget {
  const _StoreUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppColors.muted),
            SizedBox(height: 16),
            Text(
              'Sklep niedostępny',
              style: TextStyle(fontSize: 20, color: AppColors.onSurface),
            ),
            SizedBox(height: 8),
            Text(
              'Sprawdź połączenie z internetem lub upewnij się, że produkty IAP zostały skonfigurowane w Google Play / App Store Connect.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
