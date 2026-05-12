import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';

class BoosterBar extends ConsumerWidget {
  const BoosterBar({
    super.key,
    required this.onHintTap,
    required this.onShuffleTap,
    required this.busy,
  });

  final Future<void> Function() onHintTap;
  final Future<void> Function() onShuffleTap;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.read(adsServiceProvider);
    final hintReady = ads.isRewardedReady('hint');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BoosterButton(
            icon: Icons.lightbulb,
            label: hintReady ? 'Podpowiedź\n(reklama)' : 'Podpowiedź\n50 monet',
            onTap: busy ? null : onHintTap,
          ),
          const SizedBox(width: 12),
          _BoosterButton(
            icon: Icons.shuffle,
            label: 'Tasuj\n75 monet',
            onTap: busy ? null : onShuffleTap,
          ),
        ],
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  const _BoosterButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap == null ? null : () => onTap!(),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
