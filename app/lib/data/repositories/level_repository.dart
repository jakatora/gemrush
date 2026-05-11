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

/// 7 światów × 15 / 15 / 15 / 15 / 15 / 15 / 10 = 100.
const Map<int, int> worldRanges = {
  1: 15, // 1-15
  2: 15, // 16-30
  3: 15, // 31-45
  4: 15, // 46-60
  5: 15, // 61-75
  6: 15, // 76-90
  7: 10, // 91-100
};

int worldForLevel(int levelId) {
  var sum = 0;
  for (final entry in worldRanges.entries) {
    sum += entry.value;
    if (levelId <= sum) return entry.key;
  }
  return worldRanges.length;
}
