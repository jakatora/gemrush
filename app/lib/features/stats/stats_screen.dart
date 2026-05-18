import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsRepoProvider).current;
    final progress = ref.watch(progressRepoProvider);
    final winRatePct = (stats.winRate * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Statystyki')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            icon: Icons.videogame_asset,
            label: 'Rozegrane gry',
            value: '${stats.gamesPlayed}',
            color: AppColors.primary,
          ),
          _StatCard(
            icon: Icons.emoji_events,
            label: 'Wygrane',
            value: '${stats.gamesWon} ($winRatePct%)',
            color: AppColors.success,
          ),
          _StatCard(
            icon: Icons.star,
            label: 'Zebrane gwiazdki',
            value: '${progress.totalStars}',
            color: AppColors.accent,
          ),
          _StatCard(
            icon: Icons.flag,
            label: 'Odblokowany poziom',
            value: '${progress.highestUnlocked}',
            color: AppColors.primary,
          ),
          _StatCard(
            icon: Icons.local_fire_department,
            label: 'Najlepszy wynik',
            value: '${stats.highestScore}',
            color: AppColors.danger,
          ),
          _StatCard(
            icon: Icons.bolt,
            label: 'Największa kaskada',
            value: '${stats.maxCascade}×',
            color: AppColors.warning,
          ),
          const Divider(height: 32),
          _StatCard(
            icon: Icons.monetization_on,
            label: 'Zarobione monety',
            value: '${stats.totalCoinsEarned}',
            color: AppColors.accent,
          ),
          _StatCard(
            icon: Icons.shopping_cart,
            label: 'Wydane monety',
            value: '${stats.totalCoinsSpent}',
            color: AppColors.muted,
          ),
          _StatCard(
            icon: Icons.flash_on,
            label: 'Boostery użyte',
            value: '${stats.boostersUsed}',
            color: AppColors.primary,
          ),
          _StatCard(
            icon: Icons.play_circle,
            label: 'Reklamy obejrzane',
            value: '${stats.rewardedAdsWatched + stats.interstitialsShown}',
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 15),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
