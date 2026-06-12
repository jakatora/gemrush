import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_locale.dart';
import '../../data/models/achievement.dart';
import '../../providers/app_providers.dart';

enum _Filter { all, unlocked, locked }

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(achievementsRepoProvider);
    final all = repo.all();
    final unlocked = repo.unlockedCount;
    final total = AchievementDef.all.length;

    final filtered = all.where((item) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.unlocked:
          return item.progress.isUnlocked;
        case _Filter.locked:
          return !item.progress.isUnlocked;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${context.tr(en: 'Achievements', pl: 'Osiągnięcia')} $unlocked/$total'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<_Filter>(
              segments: [
                ButtonSegment(
                    value: _Filter.all,
                    label: Text(context.tr(en: 'All', pl: 'Wszystkie'))),
                ButtonSegment(
                    value: _Filter.unlocked,
                    label: Text(context.tr(en: 'Unlocked', pl: 'Zdobyte'))),
                ButtonSegment(
                    value: _Filter.locked,
                    label:
                        Text(context.tr(en: 'Locked', pl: 'Do zdobycia'))),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.tr(
                          en: 'No items in this category',
                          pl: 'Brak pozycji w tej kategorii',
                        ),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      return _AchievementTile(
                          def: item.def, progress: item.progress);
                    },
                  ),
          ),
        ],
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
                gradient: unlocked
                    ? const LinearGradient(
                        colors: [AppColors.accent, AppColors.warning],
                      )
                    : null,
                color: unlocked
                    ? null
                    : AppColors.muted.withValues(alpha: 0.2),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
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
                  Text(def.localizedName(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            unlocked ? AppColors.onSurface : AppColors.muted,
                      )),
                  Text(def.localizedDescription(context),
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
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
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
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
