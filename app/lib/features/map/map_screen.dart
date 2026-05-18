import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/routes.dart';
import '../../data/repositories/level_repository.dart';
import '../../providers/app_providers.dart';
import '../game/world_theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _scrollCtrl = ScrollController();
  final _worldKeys = <int, GlobalKey>{};

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _jumpToWorld(int worldId) {
    final key = _worldKeys[worldId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showWorldMenu(BuildContext context, int unlocked) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final unlockedWorld = worldForLevel(unlocked);
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: worldRanges.length,
            itemBuilder: (_, idx) {
              final worldId = idx + 1;
              final theme = WorldTheme.forWorld(worldId);
              final reached = worldId <= unlockedWorld;
              return ListTile(
                leading: Icon(theme.icon,
                    color: reached ? theme.accent : AppColors.muted),
                title: Text('Świat $worldId · ${theme.name}',
                    style: TextStyle(
                      color: reached ? AppColors.onSurface : AppColors.muted,
                    )),
                trailing: reached
                    ? const Icon(Icons.arrow_forward_ios, size: 16)
                    : const Icon(Icons.lock, size: 16, color: AppColors.muted),
                onTap: reached
                    ? () {
                        Navigator.pop(ctx);
                        _jumpToWorld(worldId);
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressRepo = ref.watch(progressRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa świata'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Przeskocz do świata',
            onPressed: () =>
                _showWorldMenu(context, progressRepo.highestUnlocked),
          ),
        ],
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
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: worldRanges.length,
                itemBuilder: (context, idx) {
                  final worldIdx = idx + 1;
                  final key =
                      _worldKeys.putIfAbsent(worldIdx, () => GlobalKey());
                  return KeyedSubtree(
                    key: key,
                    child: _WorldSection(
                      worldId: worldIdx,
                      unlocked: unlocked,
                      onTap: (lvl) => context.push(Routes.gameWithLevel(lvl)),
                      stars: (lvl) => progressRepo.getLevel(lvl)?.stars ?? 0,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final theme = WorldTheme.forWorld(worldId);
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
