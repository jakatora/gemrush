import 'package:flutter/services.dart';

/// Haptic patterns dla różnych eventów gry. Wszystkie respektują `enabled`.
class HapticsService {
  bool enabled = true;

  // Podstawowe (bezpośrednie API systemu)
  void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  void selection() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  // Wzorce dla wydarzeń gameplay'u

  /// Swap dwóch gemów — lekki klik.
  void onSwap() => selection();

  /// Match 3 — lekkie uderzenie.
  void onMatch3() => light();

  /// Match 4 — średnie (większa nagroda).
  void onMatch4() => medium();

  /// Match 5 lub L-shape — mocne.
  void onMatchBig() => heavy();

  /// Wybuch specjala — mocne uderzenie.
  void onSpecialExplode() => heavy();

  /// Combo (kaskada ≥ 2) — sekwencja medium + light.
  Future<void> onCascadeCombo() async {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    HapticFeedback.lightImpact();
  }

  /// Wygrana poziomu — fanfara: medium-light-heavy.
  Future<void> onLevelWin() async {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Przegrana — pojedyncze ciężkie + niskie.
  Future<void> onLevelLose() async {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
  }

  /// Booster aktywowany — średnie.
  void onBoosterUse() => medium();

  /// Achievement odblokowany — light + medium z pauzą.
  Future<void> onAchievementUnlocked() async {
    if (!enabled) return;
    HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    HapticFeedback.mediumImpact();
  }

  /// Negatywny event (np. niedozwolony swap, brak monet) — selection klik krótki.
  void onInvalid() => selection();

  /// Coin pickup — bardzo subtelny klik.
  void onCoinPickup() => selection();
}
