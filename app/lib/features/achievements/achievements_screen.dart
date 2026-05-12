import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/achievement.dart';
import '../../providers/app_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(achievementsRepoProvider);
    final all = repo.all();
    final unlocked = repo.unlockedCount;
    final total = AchievementDef.all.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Osiągnięcia $unlocked/$total'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: all.length,
        itemBuilder: (context, i) {
          final item = all[i];
          return _AchievementTile(def: item.def, progress: item.progress);
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.def, required this.progress});

  final AchievementDef def;
  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.isUnlocked;
    final pct = (progress.progress / def.target).clamp(0.0, 1.0);

    return Card(
      color: unlocked
          ? AppColors.surface
          : AppColors.surface.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked ? AppColors.accent : AppColors.muted.withValues(alpha: 0.2),
              ),
              child: Icon(
                unlocked ? Icons.emoji_events : Icons.lock,
                color: unlocked ? Colors.black : AppColors.muted,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(def.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: unlocked ? AppColors.onSurface : AppColors.muted,
                      )),
                  Text(def.description,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation(
                          unlocked ? AppColors.success : AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${progress.progress}/${def.target}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 16),
                Text('${def.coinReward}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
