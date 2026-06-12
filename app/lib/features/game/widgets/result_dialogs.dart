import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_locale.dart';
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
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _animateStarsSequence();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
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

    return ScaleTransition(
      scale: CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
      child: Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr(en: 'Level complete!', pl: 'Poziom ukończony!'),
                style: const TextStyle(
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
            Text(
                '${context.tr(en: 'Score', pl: 'Wynik')}: ${widget.score}',
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
                label: Text(context.tr(
                  en: 'Double coins (ad)',
                  pl: 'Podwój monety (reklama)',
                )),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onContinue();
              },
              child: Text(context.tr(en: 'Continue', pl: 'Dalej')),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class LoseDialog extends ConsumerStatefulWidget {
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
  ConsumerState<LoseDialog> createState() => _LoseDialogState();
}

class _LoseDialogState extends ConsumerState<LoseDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.read(adsServiceProvider);
    final ready = ads.isRewardedReady('extra_moves');

    return ScaleTransition(
      scale: _scale,
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Smutna ikona z subtelnym puls effectem
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger.withValues(alpha: 0.18),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.5),
                        width: 2),
                  ),
                  child: const Icon(Icons.sentiment_dissatisfied,
                      size: 64, color: AppColors.danger),
                ),
              ),
              const SizedBox(height: 16),
              Text(context.tr(en: 'Out of moves', pl: 'Zabrakło ruchów'),
                  style: const TextStyle(
                    fontSize: 22,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 20),
              if (ready)
                ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await widget.onExtraMovesRewarded();
                    if (ok && context.mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.play_circle),
                  label: Text(context.tr(
                    en: '+5 moves (ad)',
                    pl: '+5 ruchów (reklama)',
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onRetry();
                },
                child: Text(
                    context.tr(en: 'Try again', pl: 'Spróbuj ponownie')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClose();
                },
                child: Text(context.tr(en: 'Exit', pl: 'Wyjdź'),
                    style: const TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
