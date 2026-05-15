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
          // Reaguj na zmiany w Hive boxie progress -> auto-rebuild po wygranej.
          child: ValueListenableBuilder(
            valueListenable: progressRepo.listenable(),
            builder: (context, _, _) {
              final unlocked = progressRepo.highestUnlocked;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: worldRanges.length,
                itemBuilder: (context, idx) {
                  final worldIdx = idx + 1;
                  return _WorldSection(
                    worldId: worldIdx,
                    unlocked: unlocked,
                    onTap: (lvl) => context.push(Routes.gameWithLevel(lvl)),
                    stars: (lvl) => progressRepo.getLevel(lvl)?.stars ?? 0,
                  );
                },
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

  static const _worldThemes = <int, ({String name, IconData icon, List<Color> gradient})>{
    1: (name: 'Tutorial Plaża', icon: Icons.beach_access, gradient: [Color(0xFF4F8DFF), Color(0xFFFFD23F)]),
    2: (name: 'Las Kryształów', icon: Icons.forest, gradient: [Color(0xFF49D88B), Color(0xFF6A4BFF)]),
    3: (name: 'Lodowe Jaskinie', icon: Icons.ac_unit, gradient: [Color(0xFFB7D3FF), Color(0xFF4F8DFF)]),
    4: (name: 'Pustynia Złota', icon: Icons.wb_sunny, gradient: [Color(0xFFFFB627), Color(0xFFFF8838)]),
    5: (name: 'Wulkaniczne Klify', icon: Icons.local_fire_department, gradient: [Color(0xFFFF4757), Color(0xFFB04CFF)]),
    6: (name: 'Niebiańskie Wyspy', icon: Icons.cloud, gradient: [Color(0xFFB7D3FF), Color(0xFFB04CFF)]),
    7: (name: 'Kosmiczna Forteca', icon: Icons.rocket_launch, gradient: [Color(0xFF170E45), Color(0xFFFF4757)]),
    8: (name: 'Podwodne Głębiny', icon: Icons.water, gradient: [Color(0xFF005577), Color(0xFF49D88B)]),
    9: (name: 'Magiczna Wieża', icon: Icons.castle, gradient: [Color(0xFFB04CFF), Color(0xFFFFB627)]),
    10: (name: 'Mroczny Las', icon: Icons.park, gradient: [Color(0xFF0E1F0E), Color(0xFF49D88B)]),
    11: (name: 'Cyberprzestrzeń', icon: Icons.developer_board, gradient: [Color(0xFF00FFEA), Color(0xFFB04CFF)]),
    12: (name: 'Smoczy Tron', icon: Icons.whatshot, gradient: [Color(0xFF8B0000), Color(0xFFFFD23F)]),
    13: (name: 'Mglista Wyspa', icon: Icons.foggy, gradient: [Color(0xFF707070), Color(0xFFB7D3FF)]),
    14: (name: 'Pradawne Ruiny', icon: Icons.account_balance, gradient: [Color(0xFF3D2B1F), Color(0xFFFF4757)]),
  };

  @override
  Widget build(BuildContext context) {
    final theme = _worldThemes[worldId]!;
    final count = worldRanges[worldId]!;
    var firstId = 0;
    for (var i = 1; i < worldId; i++) {
      firstId += worldRanges[i]!;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradient.map((c) => c.withValues(alpha: 0.3)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.gradient.first.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(theme.icon, color: theme.gradient.last, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Świat $worldId · ${theme.name}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
