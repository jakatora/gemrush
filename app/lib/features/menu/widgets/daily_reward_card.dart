import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';

class DailyRewardCard extends ConsumerWidget {
  const DailyRewardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyRepoProvider);
    final status = daily.statusFor(DateTime.now());
    if (!status.canClaim) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final reward = await daily.claim(DateTime.now());
            if (reward > 0) {
              await ref.read(profileRepoProvider).addCoins(reward);
              ref.read(coinsProvider.notifier).state =
                  ref.read(profileRepoProvider).current.coins;
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Codzienna nagroda: +$reward monet!')),
                );
              }
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard,
                    color: Colors.black, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Codzienna nagroda: +${status.rewardCoins} monet',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.black, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
