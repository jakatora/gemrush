import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/iap_service.dart';
import '../../providers/app_providers.dart';

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
                _SectionHeader('Wyłącz reklamy'),
                _IapCard(product: products[IapProducts.removeAds], ref: ref),
                const SizedBox(height: 24),
                _SectionHeader('Monety'),
                for (final id in [
                  IapProducts.coins100,
                  IapProducts.coins500,
                  IapProducts.coins1200,
                  IapProducts.coins3000,
                ])
                  _IapCard(product: products[id], ref: ref),
                const SizedBox(height: 24),
                _SectionHeader('Pakiety'),
                _IapCard(product: products[IapProducts.starterPack], ref: ref),
                _IapCard(product: products[IapProducts.weekendPack], ref: ref),
                _IapCard(product: products[IapProducts.unlimitedLives24h], ref: ref),
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
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _IapCard extends StatelessWidget {
  const _IapCard({required this.product, required this.ref});
  final ProductDetails? product;
  final WidgetRef ref;

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, color: AppColors.accent),
        title: Text(product!.title.isEmpty ? product!.id : product!.title),
        subtitle: Text(coins > 0
            ? '+$coins monet — ${product!.description}'
            : product!.description),
        trailing: ElevatedButton(
          onPressed: () => ref.read(iapServiceProvider).buy(product!.id),
          child: Text(product!.price),
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
