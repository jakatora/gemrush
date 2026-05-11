import 'package:flutter/foundation.dart';

import '../game_logic/gem.dart';
import 'level_goal.dart';

/// Statyczne dane poziomu (z JSON).
@immutable
class LevelData {
  final int id;
  final int world;
  final int rows;
  final int cols;
  final int moves;
  final List<LevelGoal> goals;
  final List<int> starThresholds; // [1★, 2★, 3★]
  final List<String> layout; // jeden string per rząd
  final List<GemColor> allowedColors;

  const LevelData({
    required this.id,
    required this.world,
    required this.rows,
    required this.cols,
    required this.moves,
    required this.goals,
    required this.starThresholds,
    required this.layout,
    required this.allowedColors,
  });

  factory LevelData.fromJson(Map<String, dynamic> j) {
    final boardSize = (j['boardSize'] as List).cast<num>();
    final goals = (j['goals'] as List)
        .map((e) => LevelGoal.fromJson(e as Map<String, dynamic>))
        .toList();
    final colors = (j['allowedColors'] as List?)
            ?.cast<String>()
            .map((s) => GemColor.values.firstWhere((c) => c.name == s))
            .toList() ??
        List.of(GemColor.all);
    return LevelData(
      id: (j['id'] as num).toInt(),
      world: (j['world'] as num).toInt(),
      rows: boardSize[0].toInt(),
      cols: boardSize[1].toInt(),
      moves: (j['moves'] as num).toInt(),
      goals: goals,
      starThresholds:
          (j['starThresholds'] as List).cast<num>().map((e) => e.toInt()).toList(),
      layout: (j['layout'] as List).cast<String>(),
      allowedColors: colors,
    );
  }
}
