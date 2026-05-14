import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Pływający tekst "+120" pojawiający się nad usuniętym gemem.
/// Wznosi się i znika w ~700ms.
class ScorePopup extends TextComponent {
  ScorePopup({
    required String value,
    required Vector2 position,
    Color color = Colors.white,
  }) : super(
          text: value,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              shadows: const [
                Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    // TextComponent nie jest OpacityProvider → OpacityEffect rzuca wyjątek.
    // Zamiast fade używamy ruchu w górę + usunięcia po czasie.
    add(MoveByEffect(
      Vector2(0, -50),
      EffectController(duration: 0.7, curve: Curves.easeOut),
    ));
    add(RemoveEffect(delay: 0.7));
  }
}

/// Tekst "GREAT!" / "AMAZING!" / "INSANE!" pojawiający się na środku planszy
/// przy dużych kaskadach. Pulsuje i znika.
class ComboAnnouncer extends TextComponent {
  ComboAnnouncer({
    required String text,
    required Vector2 position,
    required Color color,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: const [
                Shadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 8),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    scale = Vector2.all(0.3);
    // Jeden ciąg: elastyczne wejście → hold → zniknięcie (skala→0).
    // TextComponent nie wspiera OpacityEffect, więc zamiast fade — scale-out.
    add(SequenceEffect([
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.25, curve: Curves.elasticOut),
      ),
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.5),
      ),
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.18, curve: Curves.easeIn),
      ),
    ], onComplete: removeFromParent));
  }

  /// Wybiera napis na podstawie liczby kaskady (0-indexed: 0 = pierwsza fala).
  static String labelFor(int cascadeStep) {
    if (cascadeStep >= 5) return 'INSANE!';
    if (cascadeStep >= 3) return 'AMAZING!';
    if (cascadeStep >= 1) return 'GREAT!';
    return '';
  }

  static Color colorFor(int cascadeStep) {
    if (cascadeStep >= 5) return const Color(0xFFFF4757);
    if (cascadeStep >= 3) return const Color(0xFFB04CFF);
    return const Color(0xFFFFB627);
  }
}
