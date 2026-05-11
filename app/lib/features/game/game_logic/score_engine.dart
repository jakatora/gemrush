import 'gem.dart';
import 'match_finder.dart';

/// Engine punktacji. Stanowy: trzyma mnożnik kaskady.
class ScoreEngine {
  int _score = 0;
  int _cascadeStep = 0;

  static const int basePerGem = 20;
  static const int bonusFor4 = 60;
  static const int bonusFor5 = 140;
  static const int bonusForL = 140;
  static const double maxMultiplier = 5.0;

  int get score => _score;
  int get cascadeStep => _cascadeStep;

  /// Wywołane po każdej kaskadzie. Pierwsza fala = step 0 (mnożnik 1.0).
  void onCascadeStep() {
    _cascadeStep += 1;
  }

  /// Resetuj między ruchami gracza.
  void resetCascade() {
    _cascadeStep = 0;
  }

  void reset() {
    _score = 0;
    _cascadeStep = 0;
  }

  /// Mnożnik dla aktualnego kroku kaskady (rośnie z każdym kolejnym).
  double get multiplier {
    final m = 1.0 + 0.5 * _cascadeStep;
    return m > maxMultiplier ? maxMultiplier : m;
  }

  /// Punkty za jeden match.
  int pointsForMatch(Match m) {
    final base = m.length * basePerGem;
    var bonus = 0;
    switch (m.shape) {
      case MatchShape.lineOf3:
        bonus = 0;
        break;
      case MatchShape.lineOf4:
        bonus = bonusFor4;
        break;
      case MatchShape.lineOf5plus:
        bonus = bonusFor5;
        break;
      case MatchShape.lShape:
        bonus = bonusForL;
        break;
    }
    return ((base + bonus) * multiplier).round();
  }

  /// Punkty za usunięcie gemu (np. z efektu specjalnego, nie ze zwykłego matcha).
  int pointsForRemoval({GemKind kind = GemKind.normal}) {
    var pts = basePerGem;
    if (kind.isSpecial) pts *= 3;
    return (pts * multiplier).round();
  }

  void addScore(int pts) {
    _score += pts;
  }

  void awardMatches(List<Match> matches) {
    for (final m in matches) {
      _score += pointsForMatch(m);
    }
  }

  /// Bonus przy końcu poziomu — każdy pozostały ruch konwertowany na punkty
  /// (Candy Crush style — w UI: zostają striped i kaskadowo wybuchają).
  int finalMoveBonus(int movesLeft) => movesLeft * 1000;
}
