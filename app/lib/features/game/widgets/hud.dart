import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../game_logic/goal_checker.dart';
import '../models/level_goal.dart';

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
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.pause, color: AppColors.onSurface),
              onPressed: onPause,
            ),
            Expanded(
              child: Column(
                children: [
                  Text('Poziom $levelId',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _MovesPill(moves: movesLeft),
            const SizedBox(width: 12),
            _GoalsStrip(goals: goals),
          ],
        ),
      ),
    );
  }
}

class _MovesPill extends StatelessWidget {
  const _MovesPill({required this.moves});
  final int moves;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          const Text('Ruchy',
              style: TextStyle(color: AppColors.muted, fontSize: 10)),
          Text(
            '$moves',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsStrip extends StatelessWidget {
  const _GoalsStrip({required this.goals});
  final GoalChecker goals;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: goals.goals.map((g) {
        final progress = goals.progressOf(g.type);
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
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.accent, size: 20),
                Text('$progress/${g.target}',
                    style: const TextStyle(
                        color: AppColors.onSurface, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
