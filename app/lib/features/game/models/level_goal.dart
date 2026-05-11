enum GoalType {
  score,
  clearJelly,
  collectIngredients,
  clearObstacles;

  static GoalType fromJson(String s) =>
      values.firstWhere((e) => e.name == s, orElse: () => GoalType.score);
}

class LevelGoal {
  final GoalType type;
  final int target;

  const LevelGoal({required this.type, required this.target});

  factory LevelGoal.fromJson(Map<String, dynamic> j) => LevelGoal(
        type: GoalType.fromJson(j['type'] as String),
        target: (j['target'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'target': target,
      };
}
