import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/profile.dart';
import '../../../providers/app_providers.dart';

/// Pokazuje serduszka + countdown do regeneracji.
/// Refresh co 1s.
class LivesMeter extends ConsumerStatefulWidget {
  const LivesMeter({super.key});

  @override
  ConsumerState<LivesMeter> createState() => _LivesMeterState();
}

class _LivesMeterState extends ConsumerState<LivesMeter> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      // Re-regenerate i refresh.
      ref.read(profileRepoProvider).regenerateLives(DateTime.now());
      ref.read(livesProvider.notifier).state =
          ref.read(profileRepoProvider).current.lives;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lives = ref.watch(livesProvider);
    final remaining =
        ref.read(profileRepoProvider).timeUntilNextLife(_now);
    final showTimer = lives < Profile.maxLives && remaining > Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.danger.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.favorite, color: AppColors.danger, size: 22),
              Text(
                '$lives',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (showTimer) ...[
            const SizedBox(width: 8),
            Text(
              _formatDuration(remaining),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
