import 'package:flutter_test/flutter_test.dart';
import 'package:gemrush/features/game/models/booster.dart';

void main() {
  test('BoosterType.coinCost — wszystkie warianty', () {
    expect(BoosterType.hammer.coinCost, 75);
    expect(BoosterType.shuffle.coinCost, 75);
    expect(BoosterType.hint.coinCost, 50);
    expect(BoosterType.extraMoves.coinCost, 200);
    expect(BoosterType.colorBombStart.coinCost, 150);
  });

  test('BoosterSelection fromRewardedAd default false', () {
    const sel = BoosterSelection(type: BoosterType.hint);
    expect(sel.fromRewardedAd, false);
  });
}
