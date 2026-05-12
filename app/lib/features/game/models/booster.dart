enum BoosterType {
  hammer,        // rozbij dowolny klejnot
  shuffle,       // przetasuj planszę
  hint,          // pokaż możliwy ruch
  extraMoves,    // +5 ruchów (w trakcie gry)
  colorBombStart; // wstaw color bomb na start

  int get coinCost => switch (this) {
        BoosterType.hammer => 75,
        BoosterType.shuffle => 75,
        BoosterType.hint => 50,
        BoosterType.extraMoves => 200,
        BoosterType.colorBombStart => 150,
      };
}

class BoosterSelection {
  final BoosterType type;
  final bool fromRewardedAd;

  const BoosterSelection({required this.type, this.fromRewardedAd = false});
}
