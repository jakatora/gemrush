import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../game_logic/gem.dart';

/// Wizualna reprezentacja jednego klejnotu. Rysowana proceduralnie
/// (nie wymaga asset PNG — dzięki temu działa od razu bez grafiki finalnej).
class GemSprite extends PositionComponent {
  Gem gem;
  double cellSize;

  GemSprite({
    required this.gem,
    required this.cellSize,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(cellSize), anchor: Anchor.center);

  void updateGem(Gem newGem) {
    gem = newGem;
  }

  void updateCellSize(double s) {
    cellSize = s;
    size = Vector2.all(s);
  }

  Color get _color {
    switch (gem.color) {
      case GemColor.red:
        return AppColors.gemRed;
      case GemColor.blue:
        return AppColors.gemBlue;
      case GemColor.green:
        return AppColors.gemGreen;
      case GemColor.yellow:
        return AppColors.gemYellow;
      case GemColor.purple:
        return AppColors.gemPurple;
      case GemColor.orange:
        return AppColors.gemOrange;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = cellSize * 0.42;
    final center = Offset(cellSize / 2, cellSize / 2);

    // Cień
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(0, 4), radius, shadow);

    // Główne wypełnienie — radial gradient z 3 stopniami głębi
    final base = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(_color, Colors.white, 0.35)!,
          _color.withValues(alpha: 0.95),
          Color.lerp(_color, Colors.black, 0.55)!,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, base);

    // Ciemny outline + jasny inner ring
    final outline = Paint()
      ..color = Color.lerp(_color, Colors.black, 0.65)!.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outline);

    final innerRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.85, innerRing);

    // Połysk główny (lewa górna)
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(
        center.translate(-radius * 0.4, -radius * 0.4),
        radius * 0.22,
        highlight);
    // Mały drugi rozbłysk
    canvas.drawCircle(
        center.translate(-radius * 0.55, -radius * 0.15),
        radius * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.5));

    _renderShapeOverlay(canvas, center, radius);
    _renderKindOverlay(canvas, center, radius);
  }

  /// Kształt dla a11y (daltonisty rozpoznają po kształcie nie tylko po kolorze).
  void _renderShapeOverlay(Canvas canvas, Offset center, double radius) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final r = radius * 0.55;
    switch (gem.color) {
      case GemColor.red:
        // romb
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r, center.dy)
          ..close();
        canvas.drawPath(path, p);
        break;
      case GemColor.blue:
        // kropla
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..quadraticBezierTo(center.dx + r, center.dy, center.dx, center.dy + r)
          ..quadraticBezierTo(center.dx - r, center.dy, center.dx, center.dy - r);
        canvas.drawPath(path, p);
        break;
      case GemColor.green:
        canvas.drawCircle(center, r * 0.85, p);
        break;
      case GemColor.yellow:
        // gwiazda
        final path = _starPath(center, r, 5);
        canvas.drawPath(path, p);
        break;
      case GemColor.purple:
        // sześciokąt
        final path = _polygonPath(center, r, 6);
        canvas.drawPath(path, p);
        break;
      case GemColor.orange:
        // kwadrat
        final rect = Rect.fromCenter(
            center: center, width: r * 1.6, height: r * 1.6);
        canvas.drawRect(rect, p);
        break;
    }
  }

  void _renderKindOverlay(Canvas canvas, Offset center, double radius) {
    switch (gem.kind) {
      case GemKind.normal:
        return;
      case GemKind.stripedHorizontal:
        _drawStripes(canvas, center, radius, horizontal: true);
        break;
      case GemKind.stripedVertical:
        _drawStripes(canvas, center, radius, horizontal: false);
        break;
      case GemKind.wrapped:
        _drawWrapped(canvas, center, radius);
        break;
      case GemKind.colorBomb:
        _drawColorBomb(canvas, center, radius);
        break;
    }
  }

  void _drawStripes(Canvas canvas, Offset center, double radius, {required bool horizontal}) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 3;
    final r = radius * 0.85;
    for (var i = -1; i <= 1; i++) {
      final offset = i * r * 0.4;
      if (horizontal) {
        canvas.drawLine(
          Offset(center.dx - r, center.dy + offset),
          Offset(center.dx + r, center.dy + offset),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(center.dx + offset, center.dy - r),
          Offset(center.dx + offset, center.dy + r),
          paint,
        );
      }
    }
  }

  void _drawWrapped(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.7, paint);
    canvas.drawCircle(center, radius * 0.45, paint);
  }

  void _drawColorBomb(Canvas canvas, Offset center, double radius) {
    final colors = [
      AppColors.gemRed,
      AppColors.gemOrange,
      AppColors.gemYellow,
      AppColors.gemGreen,
      AppColors.gemBlue,
      AppColors.gemPurple,
    ];
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(colors: colors).createShader(rect);
    canvas.drawCircle(center, radius * 0.85, paint);
    final star = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.25, star);
  }

  Path _starPath(Offset c, double r, int points) {
    final path = Path();
    final step = math.pi / points;
    for (var i = 0; i < points * 2; i++) {
      final angle = i * step - math.pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = c.dx + radius * math.cos(angle);
      final y = c.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _polygonPath(Offset c, double r, int sides) {
    final path = Path();
    final step = 2 * math.pi / sides;
    for (var i = 0; i < sides; i++) {
      final angle = i * step - math.pi / 2;
      final x = c.dx + r * math.cos(angle);
      final y = c.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
