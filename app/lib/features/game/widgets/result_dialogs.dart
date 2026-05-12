import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';

class WinDialog extends ConsumerStatefulWidget {
  const WinDialog({
    super.key,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    required this.onContinue,
    required this.onDoubleCoinsRewarded,
  });

  final int score;
  final int stars;
  final int coinsEarned;
  final VoidCallback onContinue;
  final Future<bool> Function() onDoubleCoinsRewarded;

  @override
  ConsumerState<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends ConsumerState<WinDialog>
    with TickerProviderStateMixin {
  int _starsVisible = 0;

  @override
  void initState() {
    super.initState();
    _animateStarsSequence();
  }

  Future<void> _animateStarsSequence() async {
    for (var i = 1; i <= widget.stars; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() => _starsVisible = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.read(adsServiceProvider);
    final rewardedReady = ads.isRewardedReady('double_coins');

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Poziom ukończony!',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < _starsVisible;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 350),
                    scale: filled ? 1.0 : 0.6,
                    curve: Curves.elasticOut,
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 56,
                      color: filled ? AppColors.accent : AppColors.muted,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text('Wynik: ${widget.score}',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.accent),
                const SizedBox(width: 6),
                Text('+${widget.coinsEarned}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    )),
              ],
            ),
            const SizedBox(height: 20),
            if (rewardedReady)
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await widget.onDoubleCoinsRewarded();
                  if (ok && context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_circle),
                label: const Text('Podwój monety (reklama)'),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onContinue();
              },
              child: const Text('Dalej'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoseDialog extends ConsumerWidget {
  const LoseDialog({
    super.key,
    required this.onRetry,
    required this.onClose,
    required this.onExtraMovesRewarded,
  });

  final VoidCallback onRetry;
  final VoidCallback onClose;
  final Future<bool> Function() onExtraMovesRewarded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.read(adsServiceProvider);
    final ready = ads.isRewardedReady('extra_moves');

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied,
                size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            const Text('Zabrakło ruchów',
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 20),
            if (ready)
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await onExtraMovesRewarded();
                  if (ok && context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_circle),
                label: const Text('+5 ruchów (reklama)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Spróbuj ponownie'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onClose();
              },
              child: const Text('Wyjdź',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
