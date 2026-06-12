import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../providers/app_providers.dart';

class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRepo = ref.watch(progressRepoProvider);
    final challengeRepo = ref.watch(dailyChallengeRepoProvider);
    final ch = challengeRepo.ensureForToday(
      DateTime.now(),
      progressRepo.highestUnlocked,
    );

    if (ch.completed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(
                    en: "Today's challenge completed!",
                    pl: 'Dzisiejsze wyzwanie ukończone!',
                  ),
                  style: const TextStyle(color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB04CFF), Color(0xFFFF4757)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push(Routes.gameWithLevel(ch.levelId)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                              en: 'Daily challenge', pl: 'Dzienne wyzwanie'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${context.tr(en: 'Level', pl: 'Poziom')} ${ch.levelId} · bonus +${ch.bonusCoins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
