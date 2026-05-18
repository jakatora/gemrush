import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Generator 300 poziomów z proceduralnym balansem.
///
/// 17 światów = 200 (oryginalnych) + 100 (rozszerzonych post-launch).
///
/// ŚWIATY 1-7 (poziomy 1-100) — CORE GAME:
///  1 · Tutorial Plaża    (1-15)   score only, 28 ruchów, plansza 8x8
///  2 · Las Kryształów    (16-30)  score + clearJelly (1 warstwa)
///  3 · Lodowe Jaskinie   (31-45)  score + clearObstacles (ice)
///  4 · Pustynia Złota    (46-60)  score + clearJelly (2 warstwy)
///  5 · Wulkaniczne Klify (61-75)  score + chocolate
///  6 · Niebiańskie Wyspy (76-90)  collectIngredients
///  7 · Kosmiczna Forteca (91-100) mixed hard endgame
///
/// ŚWIATY 15-17 (poziomy 201-300) — POST-LAUNCH EXPANSION:
/// 15 · Zimowa Kraina    (201-235) jelly multi-warstwa + chocolate, finezja
/// 16 · Diamentowa Kopalnia (236-270) gęste obstacles, wszystkie typy mix
/// 17 · Wieczność        (271-300) endgame absolutny, 4 cele + 12-14 ruchów
///
/// ŚWIATY 8-14 (poziomy 101-200) — END GAME:
///  8 · Podwodne Głębiny  (101-115) jelly + ice mix, 5 kolorów
///  9 · Magiczna Wieża    (116-130) chocolate spread + blocked walls
/// 10 · Mroczny Las       (131-145) heavy obstacles + ingredients
/// 11 · Cyberprzestrzeń   (146-160) max score targets, gęsta plansza
/// 12 · Smoczy Tron       (161-175) bossowe, 4 kolory only
/// 13 · Mglista Wyspa     (176-190) jelly 2-layer + collectIngredients
/// 14 · Pradawne Ruiny    (191-200) finałowe 10, wszystko, 14-16 ruchów
///
/// Uruchom: `dart run tool/generate_levels.dart`
void main(List<String> args) {
  final outDir = Directory('assets/data/levels');
  outDir.createSync(recursive: true);
  final rng = Random(42); // deterministic seed → reproducible levels
  for (var id = 1; id <= 300; id++) {
    final level = _generateLevel(id, rng);
    final filename =
        'assets/data/levels/level_${id.toString().padLeft(3, '0')}.json';
    File(filename).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(level));
  }
  stdout.writeln('Wygenerowano 300 poziomów do ${outDir.path}/');
}

Map<String, dynamic> _generateLevel(int id, Random rng) {
  final world = _worldForLevel(id);
  final rows = world == 1 ? 8 : 9;
  final cols = world == 1 ? 8 : 9;
  final moves = _movesForLevel(id, world);
  final layout = _generateLayout(rows, cols, world, id, rng);
  final goals = _generateGoals(world, id, layout);
  final scoreGoal = goals.firstWhere((g) => g['type'] == 'score');
  final scoreTarget = scoreGoal['target'] as int;
  return {
    'id': id,
    'world': world,
    'boardSize': [rows, cols],
    'moves': moves,
    'goals': goals,
    'starThresholds': [
      scoreTarget,
      (scoreTarget * 1.5).round(),
      (scoreTarget * 2.5).round(),
    ],
    'layout': layout,
    'allowedColors': _colorsForLevel(world),
  };
}

int _worldForLevel(int id) {
  if (id <= 15) return 1;
  if (id <= 30) return 2;
  if (id <= 45) return 3;
  if (id <= 60) return 4;
  if (id <= 75) return 5;
  if (id <= 90) return 6;
  if (id <= 100) return 7;
  if (id <= 115) return 8;
  if (id <= 130) return 9;
  if (id <= 145) return 10;
  if (id <= 160) return 11;
  if (id <= 175) return 12;
  if (id <= 190) return 13;
  if (id <= 200) return 14;
  if (id <= 235) return 15;
  if (id <= 270) return 16;
  return 17;
}

int _movesForLevel(int id, int world) {
  // Bazowo: świat 1 = 28, świat 14 = 14. Wewnątrz świata: -1 ruch co kilka poziomów.
  final base = switch (world) {
    1 => 28,
    2 => 24,
    3 => 22,
    4 => 22,
    5 => 20,
    6 => 20,
    7 => 18,
    8 => 20,
    9 => 19,
    10 => 18,
    11 => 17,
    12 => 16,
    13 => 16,
    14 => 15,
    15 => 17,
    16 => 16,
    _ => 14, // 17 (Wieczność)
  };
  final positionInWorld = id - _firstIdOfWorld(world);
  final difficultyOffset = -(positionInWorld ~/ 4);
  return (base + difficultyOffset).clamp(12, 35);
}

int _firstIdOfWorld(int world) {
  var sum = 0;
  for (var w = 1; w < world; w++) {
    sum += _worldLevelCount(w);
  }
  return sum + 1;
}

int _worldLevelCount(int world) {
  // Świat 7 i 14 to "bossowe" z 10 poziomami; reszta po 15.
  // Świat 15, 16 — 35 poziomów (rozszerzenie). 17 — 30 (final endgame).
  if (world == 7 || world == 14) return 10;
  if (world == 15 || world == 16) return 35;
  if (world == 17) return 30;
  return 15;
}

List<String> _colorsForLevel(int world) {
  // Mniejsza paleta = trudniej zrobić match w prawym miejscu.
  if (world <= 2) return _named([0, 1, 2, 3, 4]);
  if (world == 8) return _named([0, 1, 2, 3, 4]); // 5 kolorów — podwodne
  if (world == 12) return _named([0, 2, 4, 5]); // 4 kolory — smoczy tron
  if (world == 14) return _named([0, 1, 2, 3, 4]); // 5 kolorów — finał
  if (world == 15) return _named([1, 2, 3, 4, 5]); // 5 — bez czerwieni (zima)
  if (world == 16) return _named([0, 1, 2, 3, 4, 5]); // 6 — diamentowa kopalnia
  if (world == 17) return _named([0, 1, 3, 5]); // 4 — wieczność, najtrudniej
  return _named([0, 1, 2, 3, 4, 5]); // 6 kolorów
}

List<String> _named(List<int> idx) {
  const names = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
  return idx.map((i) => names[i]).toList();
}

List<String> _generateLayout(int rows, int cols, int world, int id, Random rng) {
  // Strategia per świat:
  // Tutorial → puste (G), kolejne wprowadzają mechaniki, świat 7+ kombinują wszystko.
  final positionInWorld = id - _firstIdOfWorld(world);
  final density = (positionInWorld * 0.02).clamp(0.0, 0.4);

  final layout = <String>[];
  for (var r = 0; r < rows; r++) {
    final buf = StringBuffer();
    for (var c = 0; c < cols; c++) {
      var ch = 'G';
      switch (world) {
        case 1:
          ch = 'G';
          break;
        case 2:
          if (rng.nextDouble() < 0.20 + density) ch = 'J';
          break;
        case 3:
          if (rng.nextDouble() < 0.18 + density) ch = 'I';
          break;
        case 4:
          if (rng.nextDouble() < 0.18 + density) ch = 'K';
          break;
        case 5:
          if (rng.nextDouble() < 0.12 + density) ch = 'C';
          break;
        case 6:
          if ((r == 0 || r == rows - 1) && (c == 0 || c == cols - 1)) ch = 'X';
          break;
        case 7:
          final roll = rng.nextDouble();
          if (roll < 0.15) {
            ch = 'K';
          } else if (roll < 0.27) {
            ch = 'I';
          } else if (roll < 0.37) {
            ch = 'C';
          } else if (roll < 0.42) {
            ch = 'X';
          }
          break;

        // ŚWIATY 8-14 (poziomy 101-200) — coraz gęstsze
        case 8: // Podwodne Głębiny: jelly + ice, ~40% pokrycia
          final roll = rng.nextDouble();
          if (roll < 0.20 + density) {
            ch = 'J';
          } else if (roll < 0.35 + density) {
            ch = 'I';
          }
          break;
        case 9: // Magiczna Wieża: chocolate + ściany blocked po bokach
          if (c == 0 || c == cols - 1) {
            if (r > 1 && r < rows - 2 && rng.nextDouble() < 0.4) ch = 'X';
          } else if (rng.nextDouble() < 0.18 + density) {
            ch = 'C';
          }
          break;
        case 10: // Mroczny Las: jelly 2-layer + środkowe blocked
          if (r == rows ~/ 2 &&
              (c == cols ~/ 2 - 1 || c == cols ~/ 2 + 1) &&
              rng.nextDouble() < 0.5) {
            ch = 'X';
          } else if (rng.nextDouble() < 0.25 + density) {
            ch = 'K';
          }
          break;
        case 11: // Cyberprzestrzeń: gęsta plansza wszystkim
          final roll = rng.nextDouble();
          if (roll < 0.15) {
            ch = 'K';
          } else if (roll < 0.27) {
            ch = 'I';
          } else if (roll < 0.40) {
            ch = 'C';
          } else if (roll < 0.45) {
            ch = 'X';
          } else if (roll < 0.55) {
            ch = 'J';
          }
          break;
        case 12: // Smoczy Tron: 4 kolory + symetryczne ognie (chocolate) w narożnikach
          final inCorner = (r < 2 && c < 2) ||
              (r < 2 && c >= cols - 2) ||
              (r >= rows - 2 && c < 2) ||
              (r >= rows - 2 && c >= cols - 2);
          if (inCorner && rng.nextDouble() < 0.5) {
            ch = 'C';
          } else if (rng.nextDouble() < 0.18 + density) {
            ch = 'I';
          }
          break;
        case 13: // Mglista Wyspa: jelly 2-layer + dropy ingredient
          if (rng.nextDouble() < 0.25 + density) ch = 'K';
          break;
        case 14: // Pradawne Ruiny: bossowe 10 poziomów, wszystko
          final roll = rng.nextDouble();
          if (roll < 0.18) {
            ch = 'K';
          } else if (roll < 0.32) {
            ch = 'I';
          } else if (roll < 0.45) {
            ch = 'C';
          } else if (roll < 0.50) {
            ch = 'X';
          } else if (roll < 0.62) {
            ch = 'J';
          }
          break;
        case 15: // Zimowa Kraina: ice + jelly 2-warstwa, finezja
          final roll = rng.nextDouble();
          if (roll < 0.25 + density) {
            ch = 'K';
          } else if (roll < 0.45 + density) {
            ch = 'I';
          }
          break;
        case 16: // Diamentowa Kopalnia: ALL obstacles, bardzo gęsto
          final roll = rng.nextDouble();
          if (roll < 0.18) {
            ch = 'K';
          } else if (roll < 0.32) {
            ch = 'C';
          } else if (roll < 0.42) {
            ch = 'I';
          } else if (roll < 0.48) {
            ch = 'X';
          } else if (roll < 0.60) {
            ch = 'J';
          }
          break;
        case 17: // Wieczność: bossowe endgame, krzyżowa symetria
          final dx = (c - cols ~/ 2).abs();
          final dy = (r - rows ~/ 2).abs();
          if (dx <= 1 && dy <= 1) {
            // środek otwarty
          } else if ((dx + dy) % 2 == 0 && rng.nextDouble() < 0.6) {
            ch = 'K';
          } else if (rng.nextDouble() < 0.3) {
            ch = 'C';
          } else if (rng.nextDouble() < 0.25) {
            ch = 'I';
          }
          break;
      }
      buf.write(ch);
    }
    layout.add(buf.toString());
  }
  return layout;
}

List<Map<String, dynamic>> _generateGoals(
    int world, int id, List<String> layout) {
  final positionInWorld = id - _firstIdOfWorld(world);
  // Score skaluje się: świat 1 start 3000 → świat 14 ~ 200000.
  final baseScore = switch (world) {
    1 => 3000,
    2 => 8000,
    3 => 14000,
    4 => 22000,
    5 => 32000,
    6 => 46000,
    7 => 65000,
    8 => 80000,
    9 => 100000,
    10 => 125000,
    11 => 155000,
    12 => 180000,
    13 => 195000,
    14 => 220000,
    15 => 240000,
    16 => 280000,
    _ => 350000, // 17 wieczność
  };
  final scoreTarget = baseScore + positionInWorld * 500;

  final goals = <Map<String, dynamic>>[
    {'type': 'score', 'target': scoreTarget},
  ];

  switch (world) {
    case 2:
      final c = _countChar(layout, 'J');
      if (c > 0) goals.add({'type': 'clearJelly', 'target': c});
      break;
    case 3:
      final c = _countChar(layout, 'I');
      if (c > 0) goals.add({'type': 'clearObstacles', 'target': c});
      break;
    case 4:
      final c = _countChar(layout, 'K');
      if (c > 0) goals.add({'type': 'clearJelly', 'target': c});
      break;
    case 5:
      final c = _countChar(layout, 'C');
      if (c > 0) goals.add({'type': 'clearObstacles', 'target': c});
      break;
    case 6:
      goals.add({
        'type': 'collectIngredients',
        'target': 2 + positionInWorld ~/ 3,
      });
      break;
    case 7:
      final obstacles = _countChar(layout, 'K') +
          _countChar(layout, 'I') +
          _countChar(layout, 'C');
      if (obstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': obstacles});
      }
      break;
    case 8:
      final jelly = _countChar(layout, 'J');
      final ice = _countChar(layout, 'I');
      if (jelly > 0) goals.add({'type': 'clearJelly', 'target': jelly});
      if (ice > 0) goals.add({'type': 'clearObstacles', 'target': ice});
      break;
    case 9:
      final c = _countChar(layout, 'C');
      if (c > 0) goals.add({'type': 'clearObstacles', 'target': c});
      break;
    case 10:
      final k = _countChar(layout, 'K');
      if (k > 0) goals.add({'type': 'clearJelly', 'target': k});
      goals.add({
        'type': 'collectIngredients',
        'target': 3 + positionInWorld ~/ 3,
      });
      break;
    case 11:
      final obstacles = _countChar(layout, 'K') +
          _countChar(layout, 'I') +
          _countChar(layout, 'C') +
          _countChar(layout, 'J');
      if (obstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': obstacles ~/ 2});
      }
      break;
    case 12:
      final c = _countChar(layout, 'C');
      final i = _countChar(layout, 'I');
      if (c > 0) goals.add({'type': 'clearObstacles', 'target': c + i});
      break;
    case 13:
      final k = _countChar(layout, 'K');
      if (k > 0) goals.add({'type': 'clearJelly', 'target': k});
      goals.add({
        'type': 'collectIngredients',
        'target': 4 + positionInWorld ~/ 3,
      });
      break;
    case 14:
      // Bossowe poziomy 14: 3 cele jednocześnie
      final jelly =
          _countChar(layout, 'J') + _countChar(layout, 'K');
      final obstacles =
          _countChar(layout, 'I') + _countChar(layout, 'C');
      if (jelly > 0) goals.add({'type': 'clearJelly', 'target': jelly});
      if (obstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': obstacles});
      }
      goals.add({
        'type': 'collectIngredients',
        'target': 3 + positionInWorld,
      });
      break;
    case 15:
      // Zimowa Kraina — jelly 2-layer + lód
      final k = _countChar(layout, 'K');
      final i = _countChar(layout, 'I');
      if (k > 0) goals.add({'type': 'clearJelly', 'target': k});
      if (i > 0) goals.add({'type': 'clearObstacles', 'target': i});
      break;
    case 16:
      // Diamentowa Kopalnia — wszystkie obstacles
      final allObstacles = _countChar(layout, 'K') +
          _countChar(layout, 'I') +
          _countChar(layout, 'C') +
          _countChar(layout, 'J');
      if (allObstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': allObstacles ~/ 2});
      }
      goals.add({
        'type': 'collectIngredients',
        'target': 4 + positionInWorld ~/ 3,
      });
      break;
    case 17:
      // Wieczność — 4 cele jednocześnie, brutalne
      final jelly = _countChar(layout, 'K') + _countChar(layout, 'J');
      final obstacles =
          _countChar(layout, 'I') + _countChar(layout, 'C');
      if (jelly > 0) goals.add({'type': 'clearJelly', 'target': jelly});
      if (obstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': obstacles});
      }
      goals.add({
        'type': 'collectIngredients',
        'target': 5 + positionInWorld ~/ 2,
      });
      break;
  }
  return goals;
}

int _countChar(List<String> layout, String ch) {
  var n = 0;
  for (final row in layout) {
    for (var i = 0; i < row.length; i++) {
      if (row[i] == ch) n += 1;
    }
  }
  return n;
}
