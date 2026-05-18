import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../../providers/app_providers.dart';
import 'widgets/daily_challenge_card.dart';
import 'widgets/daily_reward_card.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);
    final lives = ref.watch(livesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.cardGradient1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Badge(
                      icon: Icons.favorite,
                      color: AppColors.danger,
                      label: '$lives',
                    ),
                    _Badge(
                      icon: Icons.monetization_on,
                      color: AppColors.accent,
                      label: '$coins',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const DailyRewardCard(),
                const DailyChallengeCard(),
                const Spacer(),
                Text(
                  'GemRush',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Match. Smash. Win.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.push(Routes.map),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Graj'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 64),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconButton(
                      icon: Icons.shopping_bag,
                      label: 'Sklep',
                      onTap: () => context.push(Routes.shop),
                    ),
                    _IconButton(
                      icon: Icons.emoji_events,
                      label: 'Osiągnięcia',
                      onTap: () => context.push(Routes.achievements),
                    ),
                    _IconButton(
                      icon: Icons.settings,
                      label: 'Ustawienia',
                      onTap: () => context.push(Routes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              )),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.accent, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
