import '../models/level_goal.dart';

/// Sprawdza postęp celów poziomu. Wewnętrzny stan — `progress` per goal type.
class GoalChecker {
  final List<LevelGoal> goals;
  final Map<GoalType, int> _progress = {};

  GoalChecker(this.goals) {
    for (final g in goals) {
      _progress[g.type] = 0;
    }
  }

  int progressOf(GoalType type) => _progress[type] ?? 0;

  int targetOf(GoalType type) =>
      goals.firstWhere((g) => g.type == type).target;

  bool get allGoalsMet =>
      goals.every((g) => progressOf(g.type) >= g.target);

  double get totalProgress {
    if (goals.isEmpty) return 1.0;
    final ratios = goals.map((g) {
      final p = progressOf(g.type);
      return (p / g.target).clamp(0.0, 1.0);
    });
    final sum = ratios.fold<double>(0.0, (s, r) => s + r);
    return sum / goals.length;
  }

  void addScore(int pts) {
    if (!_progress.containsKey(GoalType.score)) return;
    _progress[GoalType.score] = (_progress[GoalType.score] ?? 0) + pts;
  }

  void recordJellyCleared() {
    if (_progress.containsKey(GoalType.clearJelly)) {
      _progress[GoalType.clearJelly] =
          (_progress[GoalType.clearJelly] ?? 0) + 1;
    }
  }

  void recordObstacleCleared() {
    if (_progress.containsKey(GoalType.clearObstacles)) {
      _progress[GoalType.clearObstacles] =
          (_progress[GoalType.clearObstacles] ?? 0) + 1;
    }
  }

  void recordIngredientCollected() {
    if (_progress.containsKey(GoalType.collectIngredients)) {
      _progress[GoalType.collectIngredients] =
          (_progress[GoalType.collectIngredients] ?? 0) + 1;
    }
  }

  int starsFromScore(int score, List<int> thresholds) {
    var stars = 0;
    for (final t in thresholds) {
      if (score >= t) stars += 1;
    }
    return stars;
  }
}
