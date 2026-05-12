import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Generuje krótką eksplozję cząstek na podanej pozycji.
/// Używane przy usuwaniu gemów (match explosion).
ParticleSystemComponent buildMatchBurst({
  required Vector2 position,
  required Color color,
  int count = 12,
  double radius = 28,
}) {
  final rng = Random();
  return ParticleSystemComponent(
    position: position,
    particle: Particle.generate(
      count: count,
      lifespan: 0.45,
      generator: (i) {
        final angle = (i / count) * 2 * pi + rng.nextDouble() * 0.4;
        final speed = radius * (2.5 + rng.nextDouble() * 1.5);
        return AcceleratedParticle(
          acceleration: Vector2(0, 240),
          speed: Vector2(cos(angle), sin(angle)) * speed,
          child: CircleParticle(
            radius: 3 + rng.nextDouble() * 2,
            paint: Paint()..color = color.withValues(alpha: 0.9),
          ),
        );
      },
    ),
  );
}

ParticleSystemComponent buildSparkle({
  required Vector2 position,
  Color color = Colors.white,
}) {
  return ParticleSystemComponent(
    position: position,
    particle: Particle.generate(
      count: 6,
      lifespan: 0.6,
      generator: (i) => MovingParticle(
        from: Vector2.zero(),
        to: Vector2(0, -30 - i * 4.0),
        child: CircleParticle(
          radius: 2,
          paint: Paint()..color = color,
        ),
      ),
    ),
  );
}
