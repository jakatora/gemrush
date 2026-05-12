import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Generator 100 poziomów z proceduralnym balansem.
///
/// Krzywa trudności:
///  Świat 1 (1-15)   Tutorial Plaża    — score only, 25+ ruchów, plansza 8x8
///  Świat 2 (16-30)  Las Kryształów    — score + clearJelly (1 warstwa), 22 ruchy
///  Świat 3 (31-45)  Lodowe Jaskinie   — score + clearObstacles (ice), 20 ruchów
///  Świat 4 (46-60)  Pustynia Złota    — score + clearJelly (2 warstwy), 20 ruchów
///  Świat 5 (61-75)  Wulkaniczne Klify — score + clearObstacles (chocolate), 18 ruchów
///  Świat 6 (76-90)  Niebiańskie Wyspy — score + collectIngredients, 18 ruchów
///  Świat 7 (91-100) Kosmiczna Forteca — mixed, hard, 16 ruchów
///
/// Uruchom: `dart run tool/generate_levels.dart`
void main(List<String> args) {
  final outDir = Directory('assets/data/levels');
  outDir.createSync(recursive: true);
  final rng = Random(42); // deterministic seed → reproducible levels
  for (var id = 1; id <= 100; id++) {
    final level = _generateLevel(id, rng);
    final filename =
        'assets/data/levels/level_${id.toString().padLeft(3, '0')}.json';
    File(filename).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(level));
  }
  stdout.writeln('Wygenerowano 100 poziomów do ${outDir.path}/');
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
  return 7;
}

int _movesForLevel(int id, int world) {
  // Bazowo: świat 1 = 28, świat 7 = 16. Wewnątrz świata: -1 ruch co kilka poziomów.
  final base = switch (world) {
    1 => 28,
    2 => 24,
    3 => 22,
    4 => 22,
    5 => 20,
    6 => 20,
    _ => 18,
  };
  final positionInWorld = id - _firstIdOfWorld(world);
  final difficultyOffset = -(positionInWorld ~/ 4);
  return (base + difficultyOffset).clamp(14, 35);
}

int _firstIdOfWorld(int world) {
  var sum = 0;
  for (var w = 1; w < world; w++) {
    sum += _worldLevelCount(w);
  }
  return sum + 1;
}

int _worldLevelCount(int world) {
  if (world <= 6) return 15;
  return 10;
}

List<String> _colorsForLevel(int world) {
  if (world <= 2) return _named([0, 1, 2, 3, 4]);
  return _named([0, 1, 2, 3, 4, 5]);
}

List<String> _named(List<int> idx) {
  const names = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
  return idx.map((i) => names[i]).toList();
}

List<String> _generateLayout(int rows, int cols, int world, int id, Random rng) {
  // Strategia:
  // - Świat 1: pełne G (puste pole grywalne)
  // - Świat 2: G + jelly (J) na losowych komórkach (~25%)
  // - Świat 3: G + ice (I) na ~20%
  // - Świat 4: G + jelly 2-warstwy (K) na ~30%
  // - Świat 5: G + chocolate (C) na ~15%, rosnące
  // - Świat 6: G + niedostępne komórki (X) jako narożniki "kanałów" dla ingredientów
  // - Świat 7: mix wszystkich
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
  // Score skaluje się: świat 1 start 3000 → świat 7 ~ 80000.
  final baseScore = switch (world) {
    1 => 3000,
    2 => 8000,
    3 => 14000,
    4 => 22000,
    5 => 32000,
    6 => 46000,
    _ => 65000,
  };
  final scoreTarget = baseScore + positionInWorld * 500;

  final goals = <Map<String, dynamic>>[
    {'type': 'score', 'target': scoreTarget},
  ];

  switch (world) {
    case 2:
      final jellyCount = _countChar(layout, 'J');
      if (jellyCount > 0) {
        goals.add({'type': 'clearJelly', 'target': jellyCount});
      }
      break;
    case 3:
      final iceCount = _countChar(layout, 'I');
      if (iceCount > 0) {
        goals.add({'type': 'clearObstacles', 'target': iceCount});
      }
      break;
    case 4:
      final jellyCount = _countChar(layout, 'K');
      if (jellyCount > 0) {
        goals.add({'type': 'clearJelly', 'target': jellyCount});
      }
      break;
    case 5:
      final chocoCount = _countChar(layout, 'C');
      if (chocoCount > 0) {
        goals.add({'type': 'clearObstacles', 'target': chocoCount});
      }
      break;
    case 6:
      goals.add({'type': 'collectIngredients', 'target': 2 + positionInWorld ~/ 3});
      break;
    case 7:
      final obstacles = _countChar(layout, 'K') +
          _countChar(layout, 'I') +
          _countChar(layout, 'C');
      if (obstacles > 0) {
        goals.add({'type': 'clearObstacles', 'target': obstacles});
      }
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
