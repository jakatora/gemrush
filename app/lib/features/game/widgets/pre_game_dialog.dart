import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../models/booster.dart';
import '../models/level_data.dart';

class PreGameDialog extends ConsumerStatefulWidget {
  const PreGameDialog({
    super.key,
    required this.level,
    required this.onStart,
  });

  final LevelData level;
  final void Function(Set<BoosterType> selected) onStart;

  @override
  ConsumerState<PreGameDialog> createState() => _PreGameDialogState();
}

class _PreGameDialogState extends ConsumerState<PreGameDialog> {
  final Set<BoosterType> _selected = {};

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinsProvider);
    final available = const [
      BoosterType.colorBombStart,
      BoosterType.hammer,
      BoosterType.shuffle,
    ];
    final cost = _selected.fold<int>(0, (s, b) => s + b.coinCost);
    final canAfford = cost <= coins;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Poziom ${widget.level.id}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                )),
            const SizedBox(height: 4),
            Text('${widget.level.moves} ruchów',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            Text('Boostery (opcjonalne):',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: available
                  .map((b) => _BoosterChip(
                        booster: b,
                        selected: _selected.contains(b),
                        affordable: coins >= b.coinCost,
                        onTap: () => setState(() {
                          if (_selected.contains(b)) {
                            _selected.remove(b);
                          } else if (coins >= cost + b.coinCost) {
                            _selected.add(b);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            if (cost > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 4),
                  Text('Koszt: $cost',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: canAfford
                  ? () {
                      Navigator.of(context).pop();
                      widget.onStart(_selected);
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Graj'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuluj',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterChip extends StatelessWidget {
  const _BoosterChip({
    required this.booster,
    required this.selected,
    required this.affordable,
    required this.onTap,
  });

  final BoosterType booster;
  final bool selected;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (booster) {
      BoosterType.hammer => Icons.gavel,
      BoosterType.shuffle => Icons.shuffle,
      BoosterType.hint => Icons.lightbulb,
      BoosterType.extraMoves => Icons.add_circle,
      BoosterType.colorBombStart => Icons.blur_circular,
    };
    final label = switch (booster) {
      BoosterType.hammer => 'Młotek',
      BoosterType.shuffle => 'Tasowanie',
      BoosterType.hint => 'Podpowiedź',
      BoosterType.extraMoves => '+5 ruchów',
      BoosterType.colorBombStart => 'Color bomb',
    };
    return Opacity(
      opacity: affordable ? 1.0 : 0.4,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.cardGradient1,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: affordable ? onTap : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              children: [
                Icon(icon, color: AppColors.accent, size: 26),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                    )),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 12, color: AppColors.muted),
                    Text(' ${booster.coinCost}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
