import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/game/models/level_data.dart';

class LevelRepository {
  final Map<int, LevelData> _cache = {};

  Future<LevelData> load(int id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    final path =
        'assets/data/levels/level_${id.toString().padLeft(3, '0')}.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final data = LevelData.fromJson(json);
    _cache[id] = data;
    return data;
  }

  Future<LevelData?> tryLoad(int id) async {
    try {
      return await load(id);
    } catch (_) {
      return null;
    }
  }
}

/// 14 światów × 15 (lub 10 dla bossowych 7 i 14) = 200.
const Map<int, int> worldRanges = {
  1: 15,  // 1-15
  2: 15,  // 16-30
  3: 15,  // 31-45
  4: 15,  // 46-60
  5: 15,  // 61-75
  6: 15,  // 76-90
  7: 10,  // 91-100
  8: 15,  // 101-115
  9: 15,  // 116-130
  10: 15, // 131-145
  11: 15, // 146-160
  12: 15, // 161-175
  13: 15, // 176-190
  14: 10, // 191-200
};

int worldForLevel(int levelId) {
  var sum = 0;
  for (final entry in worldRanges.entries) {
    sum += entry.value;
    if (levelId <= sum) return entry.key;
  }
  return worldRanges.length;
}

const int totalLevels = 200;
