import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../providers/app_providers.dart';

class BoosterBar extends ConsumerWidget {
  const BoosterBar({
    super.key,
    required this.onHintTap,
    required this.onShuffleTap,
    required this.onExtraMovesTap,
    required this.busy,
  });

  final Future<void> Function() onHintTap;
  final Future<void> Function() onShuffleTap;
  final Future<void> Function() onExtraMovesTap;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.read(adsServiceProvider);
    final hintReady = ads.isRewardedReady('hint');
    final extraMovesReady = ads.isRewardedReady('extra_moves');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BoosterButton(
            icon: Icons.lightbulb,
            label: hintReady
                ? context.tr(en: 'Hint\nad', pl: 'Hint\nreklama')
                : 'Hint\n50 ☆',
            onTap: busy ? null : onHintTap,
          ),
          _BoosterButton(
            icon: Icons.shuffle,
            label: context.tr(en: 'Shuffle\n75 ☆', pl: 'Tasuj\n75 ☆'),
            onTap: busy ? null : onShuffleTap,
          ),
          _BoosterButton(
            icon: Icons.add_circle,
            label: extraMovesReady
                ? context.tr(
                    en: '+5 moves\nad',
                    pl: '+5 ruch\nreklama',
                  )
                : context.tr(en: '+5 moves\n200 ☆', pl: '+5 ruch\n200 ☆'),
            onTap: busy ? null : onExtraMovesTap,
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap == null ? null : () => onTap!(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.accent, size: 22),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
