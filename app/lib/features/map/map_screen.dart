import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../../data/repositories/level_repository.dart';
import '../../providers/app_providers.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRepo = ref.watch(progressRepoProvider);
    final unlocked = progressRepo.highestUnlocked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa świata'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.cardGradient1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: 7,
            itemBuilder: (context, idx) {
              final worldIdx = idx + 1;
              return _WorldSection(
                worldId: worldIdx,
                unlocked: unlocked,
                onTap: (lvl) => context.push(Routes.gameWithLevel(lvl)),
                stars: (lvl) =>
                    progressRepo.getLevel(lvl)?.stars ?? 0,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WorldSection extends StatelessWidget {
  const _WorldSection({
    required this.worldId,
    required this.unlocked,
    required this.onTap,
    required this.stars,
  });

  final int worldId;
  final int unlocked;
  final void Function(int level) onTap;
  final int Function(int level) stars;

  @override
  Widget build(BuildContext context) {
    final names = [
      '', // 0 unused
      'Tutorial Plaża',
      'Las Kryształów',
      'Lodowe Jaskinie',
      'Pustynia Złota',
      'Wulkaniczne Klify',
      'Niebiańskie Wyspy',
      'Kosmiczna Forteca',
    ];
    final count = worldRanges[worldId]!;
    var firstId = 0;
    for (var i = 1; i < worldId; i++) {
      firstId += worldRanges[i]!;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Świat $worldId · ${names[worldId]}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(count, (i) {
              final lvl = firstId + i + 1;
              final isUnlocked = lvl <= unlocked;
              return _LevelNode(
                level: lvl,
                unlocked: isUnlocked,
                stars: stars(lvl),
                onTap: isUnlocked ? () => onTap(lvl) : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.onTap,
  });

  final int level;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unlocked ? AppColors.surface : AppColors.surface.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 78,
          height: 90,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$level',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: unlocked ? AppColors.onSurface : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < stars;
                  return Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 14,
                    color: filled ? AppColors.accent : AppColors.muted,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
