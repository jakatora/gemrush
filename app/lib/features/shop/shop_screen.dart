import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_locale.dart';
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
      appBar: AppBar(title: Text(context.tr(en: 'Shop', pl: 'Sklep'))),
      body: products.isEmpty
          ? const _StoreUnavailable()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(
                    context.tr(en: 'Remove ads', pl: 'Wyłącz reklamy')),
                _IapCard(
                  product: products[IapProducts.removeAds],
                  ref: ref,
                  badge: _Badge.popular,
                  description: context.tr(
                    en: 'No interstitials between levels. Reward ads stay.',
                    pl: 'Bez przerw między poziomami. Reward ads zostają.',
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(context.tr(en: 'Coins', pl: 'Monety')),
                _IapCard(
                  product: products[IapProducts.coins100],
                  ref: ref,
                  description: context.tr(en: '+100 coins', pl: '+100 monet'),
                ),
                _IapCard(
                  product: products[IapProducts.coins500],
                  ref: ref,
                  badge: _Badge.popular,
                  description: context.tr(
                    en: '+600 coins (20% bonus)',
                    pl: '+600 monet (20% bonus)',
                  ),
                ),
                _IapCard(
                  product: products[IapProducts.coins1200],
                  ref: ref,
                  badge: _Badge.bestValue,
                  description: context.tr(
                    en: '+1600 coins (33% bonus)',
                    pl: '+1600 monet (33% bonus)',
                  ),
                ),
                _IapCard(
                  product: products[IapProducts.coins3000],
                  ref: ref,
                  description: context.tr(
                    en: '+4500 coins (50% bonus)',
                    pl: '+4500 monet (50% bonus)',
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(context.tr(en: 'Bundles', pl: 'Pakiety')),
                _IapCard(
                  product: products[IapProducts.starterPack],
                  ref: ref,
                  badge: _Badge.limited,
                  description: context.tr(
                    en: '200 coins + 10 lives + 3 boosters',
                    pl: '200 monet + 10 żyć + 3 boostery',
                  ),
                ),
                _IapCard(
                  product: products[IapProducts.weekendPack],
                  ref: ref,
                  badge: _Badge.limited,
                  description: context.tr(
                    en: '500 coins + unlimited lives 24h',
                    pl: '500 monet + unlim. życia 24h',
                  ),
                ),
                _IapCard(
                  product: products[IapProducts.unlimitedLives24h],
                  ref: ref,
                  description: context.tr(
                    en: '24h of unlimited lives',
                    pl: '24h bez limitu żyć',
                  ),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.help_outline, color: AppColors.muted),
          title: Text(context.tr(
            en: 'Product unavailable',
            pl: 'Produkt niedostępny',
          )),
          subtitle: Text(context.tr(
            en: 'Configure IAP in Google Play / App Store Connect.',
            pl: 'Skonfiguruj IAP w Google Play / App Store Connect.',
          )),
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
        if (badge != _Badge.none) _badgeWidget(context),
      ],
    );
  }

  Widget _badgeWidget(BuildContext context) {
    final pl = LocaleScope.of(context) == AppLocale.pl;
    final (label, color) = switch (badge) {
      _Badge.popular => (pl ? 'POPULARNY' : 'POPULAR', AppColors.accent),
      _Badge.bestValue =>
        (pl ? 'NAJLEPSZA WARTOŚĆ' : 'BEST VALUE', AppColors.success),
      _Badge.limited => (pl ? 'LIMITOWANY' : 'LIMITED', AppColors.danger),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              context.tr(en: 'Shop unavailable', pl: 'Sklep niedostępny'),
              style: const TextStyle(
                  fontSize: 20, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                en: 'Check your internet connection or make sure IAP products are configured in Google Play / App Store Connect.',
                pl: 'Sprawdź połączenie z internetem lub upewnij się, że produkty IAP zostały skonfigurowane w Google Play / App Store Connect.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
