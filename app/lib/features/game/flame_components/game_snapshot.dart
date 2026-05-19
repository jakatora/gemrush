/// Snapshot stanu gry przekazywany do UI przez callback `onUpdate`,
/// `onWin`, `onLose`. Immutable.
class GameSnapshot {
  final int score;
  final int movesLeft;
  final double goalProgress;
  final int stars;
  final bool isWin;
  final bool isLose;

  const GameSnapshot({
    required this.score,
    required this.movesLeft,
    required this.goalProgress,
    required this.stars,
    required this.isWin,
    required this.isLose,
  });
}
