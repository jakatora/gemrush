import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../game_logic/goal_checker.dart';
import '../models/level_goal.dart';
import '../world_theme.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.levelId,
    required this.score,
    required this.movesLeft,
    required this.goals,
    required this.onPause,
  });

  final int levelId;
  final int score;
  final int movesLeft;
  final GoalChecker goals;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final theme = WorldTheme.forLevel(levelId);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _PauseButton(onTap: onPause, accent: theme.accent),
            const SizedBox(width: 8),
            Expanded(child: _ScorePanel(levelId: levelId, score: score, accent: theme.accent)),
            const SizedBox(width: 8),
            _MovesPill(moves: movesLeft, accent: theme.accent),
            const SizedBox(width: 8),
            _GoalsStrip(goals: goals, accent: theme.accent),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap, required this.accent});
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Icon(Icons.pause, color: accent, size: 22),
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.levelId, required this.score, required this.accent});
  final int levelId;
  final int score;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Poziom $levelId',
            style: TextStyle(
              color: accent.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          Text(
            _formatScore(score),
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int s) {
    if (s < 1000) return '$s';
    if (s < 1000000) {
      return '${(s / 1000).toStringAsFixed(s < 10000 ? 1 : 0)}k';
    }
    return '${(s / 1000000).toStringAsFixed(2)}M';
  }
}

class _MovesPill extends StatelessWidget {
  const _MovesPill({required this.moves, required this.accent});
  final int moves;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isLow = moves <= 3;
    final color = isLow ? AppColors.danger : accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: isLow
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ruchy',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(
            '$moves',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsStrip extends StatelessWidget {
  const _GoalsStrip({required this.goals, required this.accent});
  final GoalChecker goals;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: goals.goals.map((g) {
        final progress = goals.progressOf(g.type);
        final done = progress >= g.target;
        IconData icon;
        switch (g.type) {
          case GoalType.score:
            icon = Icons.emoji_events;
            break;
          case GoalType.clearJelly:
            icon = Icons.bubble_chart;
            break;
          case GoalType.collectIngredients:
            icon = Icons.spa;
            break;
          case GoalType.clearObstacles:
            icon = Icons.dangerous;
            break;
        }
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: done
                    ? AppColors.success
                    : accent.withValues(alpha: 0.3),
                width: done ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  done ? Icons.check_circle : icon,
                  color: done ? AppColors.success : accent,
                  size: 18,
                ),
                Text(
                  done ? '✓' : '$progress/${g.target}',
                  style: TextStyle(
                    color: done ? AppColors.success : AppColors.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
