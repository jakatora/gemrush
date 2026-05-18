import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/quest.dart';
import '../../providers/app_providers.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(questsRepoProvider);
    final quests = repo.todayQuests(DateTime.now());
    final completed = quests.where((q) => q.completed).length;

    return Scaffold(
      appBar: AppBar(title: Text('Wyzwania dnia $completed/${quests.length}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Codzienne wyzwania resetują się o północy. Dokończ je, by zarobić bonusowe monety!',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final q in quests) _QuestTile(quest: q, onClaim: _claim),
        ],
      ),
    );
  }

  Future<void> _claim(Quest q) async {
    final repo = ref.read(questsRepoProvider);
    final profile = ref.read(profileRepoProvider);
    final reward = await repo.claimReward(DateTime.now(), q.id);
    if (reward > 0) {
      await profile.addCoins(reward);
      ref.read(coinsProvider.notifier).state = profile.current.coins;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 +$reward monet za: ${q.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    }
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.quest, required this.onClaim});
  final Quest quest;
  final Future<void> Function(Quest q) onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = quest.completed && !quest.claimed;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: quest.claimed
          ? AppColors.surface.withValues(alpha: 0.5)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: canClaim
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              quest.claimed
                  ? Icons.check_circle
                  : quest.completed
                      ? Icons.task_alt
                      : Icons.flag_outlined,
              color: quest.claimed
                  ? AppColors.muted
                  : quest.completed
                      ? AppColors.success
                      : AppColors.accent,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: quest.claimed
                            ? AppColors.muted
                            : AppColors.onSurface,
                      )),
                  if (quest.description.isNotEmpty)
                    Text(quest.description,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: quest.progressRatio,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation(
                          quest.completed ? AppColors.success : AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${quest.progress}/${quest.target}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (canClaim)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                ),
                onPressed: () => onClaim(quest),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: Colors.black, size: 14),
                    Text(' +${quest.coinReward}',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              Column(
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.accent, size: 16),
                  Text('+${quest.coinReward}',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
