// Procedural app icon generator — wytwarza placeholder branding.
//
// Generuje:
//   assets/branding/icon_1024.png      — pełna ikona 1024×1024 (App Store / Play)
//   assets/branding/icon_fg.png        — adaptive foreground 432×432 (Android)
//   assets/branding/feature_1024x500.png — Play Store feature graphic
//
// Po wygenerowaniu odpal:
//   flutter pub run flutter_launcher_icons
// to zaaplikuje ikony do iOS (Assets.xcassets) i Android (mipmap).
//
// Uruchom: dart run tool/generate_icon.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _bg1 = [0x17, 0x0E, 0x45]; // background dark purple
const _bg2 = [0x6A, 0x4B, 0xFF]; // primary
const _accent = [0xFF, 0xB6, 0x27]; // gold
const _gemColors = [
  [0xFF, 0x47, 0x57], // red
  [0x4F, 0x8D, 0xFF], // blue
  [0x49, 0xD8, 0x8B], // green
  [0xFF, 0xD2, 0x3F], // yellow
  [0xB0, 0x4C, 0xFF], // purple
  [0xFF, 0x88, 0x38], // orange
];

void main() {
  final outDir = Directory('assets/branding');
  outDir.createSync(recursive: true);

  _writeIcon(1024, '${outDir.path}/icon_1024.png',
      includeBackground: true);
  _writeIcon(432, '${outDir.path}/icon_fg.png',
      includeBackground: false, padding: 48);
  _writeFeatureGraphic('${outDir.path}/feature_1024x500.png');

  stdout.writeln('Wygenerowano ikony do ${outDir.path}/');
  stdout.writeln('Teraz odpal: flutter pub run flutter_launcher_icons');
}

void _writeIcon(int size, String path,
    {required bool includeBackground, int padding = 0}) {
  final image = img.Image(width: size, height: size);
  if (includeBackground) {
    _fillRadialGradient(image, _bg2, _bg1);
  }
  _drawCentralGem(image, padding: padding);
  _drawCornerGems(image, padding: padding);
  File(path).writeAsBytesSync(img.encodePng(image));
}

void _fillRadialGradient(img.Image image, List<int> inner, List<int> outer) {
  final cx = image.width / 2;
  final cy = image.height / 2;
  final maxR = math.sqrt(cx * cx + cy * cy);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final r = math.sqrt(dx * dx + dy * dy) / maxR;
      final t = r.clamp(0.0, 1.0);
      final c = img.ColorUint8.rgba(
        (inner[0] * (1 - t) + outer[0] * t).round(),
        (inner[1] * (1 - t) + outer[1] * t).round(),
        (inner[2] * (1 - t) + outer[2] * t).round(),
        255,
      );
      image.setPixel(x, y, c);
    }
  }
}

void _drawCentralGem(img.Image image, {int padding = 0}) {
  final cx = image.width ~/ 2;
  final cy = image.height ~/ 2;
  final radius = (image.width / 2 - padding) * 0.55;

  // shadow
  _drawCircle(image, cx + 4, cy + 8, radius.round(),
      img.ColorUint8.rgba(0, 0, 0, 180));

  // body — large rhombus (czerwony gem)
  _drawRhombus(
    image: image,
    cx: cx,
    cy: cy,
    halfW: (radius * 1.05).round(),
    halfH: (radius * 1.25).round(),
    fillTop: _accent,
    fillBottom: _gemColors[0],
  );

  // highlight (lewy górny róg romba)
  _drawRhombusInner(
    image: image,
    cx: cx - (radius * 0.35).round(),
    cy: cy - (radius * 0.45).round(),
    halfW: (radius * 0.32).round(),
    halfH: (radius * 0.4).round(),
    color: [255, 255, 255, 200],
  );

  // mała gwiazdka błyszcząca
  _drawCircle(image, cx - (radius * 0.55).round(),
      cy - (radius * 0.15).round(), 6, img.ColorRgba8(255, 255, 255, 220));
}

void _drawCornerGems(img.Image image, {int padding = 0}) {
  final s = image.width;
  final small = (s * 0.10).round();
  final inset = (s * 0.15 + padding).round();
  final positions = [
    [inset, inset, 1],            // top-left blue
    [s - inset, inset, 2],        // top-right green
    [inset, s - inset, 4],        // bottom-left purple
    [s - inset, s - inset, 5],    // bottom-right orange
  ];
  for (final pos in positions) {
    final c = _gemColors[pos[2]];
    _drawCircle(
      image,
      pos[0],
      pos[1] + 3,
      small,
      img.ColorRgba8(0, 0, 0, 100),
    );
    _drawCircle(
      image,
      pos[0],
      pos[1],
      small,
      img.ColorRgba8(c[0], c[1], c[2], 255),
    );
    _drawCircle(
      image,
      pos[0] - (small * 0.35).round(),
      pos[1] - (small * 0.35).round(),
      (small * 0.3).round(),
      img.ColorRgba8(255, 255, 255, 180),
    );
  }
}

void _drawRhombus({
  required img.Image image,
  required int cx,
  required int cy,
  required int halfW,
  required int halfH,
  required List<int> fillTop,
  required List<int> fillBottom,
}) {
  for (var y = -halfH; y <= halfH; y++) {
    final t = (y + halfH) / (2 * halfH);
    final color = img.ColorRgba8(
      (fillTop[0] * (1 - t) + fillBottom[0] * t).round(),
      (fillTop[1] * (1 - t) + fillBottom[1] * t).round(),
      (fillTop[2] * (1 - t) + fillBottom[2] * t).round(),
      255,
    );
    final widthAtY = (halfW * (1 - (y.abs() / halfH))).round();
    for (var x = -widthAtY; x <= widthAtY; x++) {
      final px = cx + x;
      final py = cy + y;
      if (px >= 0 && py >= 0 && px < image.width && py < image.height) {
        image.setPixel(px, py, color);
      }
    }
  }
}

void _drawRhombusInner({
  required img.Image image,
  required int cx,
  required int cy,
  required int halfW,
  required int halfH,
  required List<int> color,
}) {
  for (var y = -halfH; y <= halfH; y++) {
    final widthAtY = (halfW * (1 - (y.abs() / halfH))).round();
    for (var x = -widthAtY; x <= widthAtY; x++) {
      final px = cx + x;
      final py = cy + y;
      if (px >= 0 && py >= 0 && px < image.width && py < image.height) {
        image.setPixel(px, py,
            img.ColorRgba8(color[0], color[1], color[2], color[3]));
      }
    }
  }
}

void _drawCircle(img.Image image, int cx, int cy, int r, img.Color color) {
  for (var y = -r; y <= r; y++) {
    for (var x = -r; x <= r; x++) {
      if (x * x + y * y <= r * r) {
        final px = cx + x;
        final py = cy + y;
        if (px >= 0 && py >= 0 && px < image.width && py < image.height) {
          image.setPixel(px, py, color);
        }
      }
    }
  }
}

void _writeFeatureGraphic(String path) {
  final width = 1024;
  final height = 500;
  final image = img.Image(width: width, height: height);
  // gradient
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final t = x / width;
      final c = img.ColorRgba8(
        (_bg2[0] * (1 - t) + _bg1[0] * t).round(),
        (_bg2[1] * (1 - t) + _bg1[1] * t).round(),
        (_bg2[2] * (1 - t) + _bg1[2] * t).round(),
        255,
      );
      image.setPixel(x, y, c);
    }
  }
  // duży gem po lewej
  _drawRhombus(
    image: image,
    cx: 250,
    cy: 250,
    halfW: 130,
    halfH: 160,
    fillTop: _accent,
    fillBottom: _gemColors[0],
  );
  // pas gemów po prawej
  for (var i = 0; i < 5; i++) {
    final c = _gemColors[i % _gemColors.length];
    _drawCircle(image, 580 + i * 80, 250, 38,
        img.ColorRgba8(c[0], c[1], c[2], 255));
    _drawCircle(image, 580 + i * 80 - 14, 250 - 14, 12,
        img.ColorRgba8(255, 255, 255, 200));
  }
  File(path).writeAsBytesSync(img.encodePng(image));
}
