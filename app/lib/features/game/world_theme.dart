import 'package:flutter/material.dart';

import '../../data/repositories/level_repository.dart';

/// Wizualny motyw świata używany w GameScreen i innych miejscach
/// pokazujących level/world (tło, akcent, ikona).
class WorldTheme {
  final String name;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const WorldTheme({
    required this.name,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  static const _themes = <int, WorldTheme>{
    1: WorldTheme(
      name: 'Tutorial Plaża',
      icon: Icons.beach_access,
      gradient: [Color(0xFF1E3A8A), Color(0xFFE0A726)],
      accent: Color(0xFFFFD23F),
    ),
    2: WorldTheme(
      name: 'Las Kryształów',
      icon: Icons.forest,
      gradient: [Color(0xFF1E3A2C), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    3: WorldTheme(
      name: 'Lodowe Jaskinie',
      icon: Icons.ac_unit,
      gradient: [Color(0xFF0F2F5E), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    4: WorldTheme(
      name: 'Pustynia Złota',
      icon: Icons.wb_sunny,
      gradient: [Color(0xFF5C2D0E), Color(0xFFFFB627)],
      accent: Color(0xFFFFB627),
    ),
    5: WorldTheme(
      name: 'Wulkaniczne Klify',
      icon: Icons.local_fire_department,
      gradient: [Color(0xFF3B0F0F), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    6: WorldTheme(
      name: 'Niebiańskie Wyspy',
      icon: Icons.cloud,
      gradient: [Color(0xFF1F1B5C), Color(0xFFB04CFF)],
      accent: Color(0xFFB04CFF),
    ),
    7: WorldTheme(
      name: 'Kosmiczna Forteca',
      icon: Icons.rocket_launch,
      gradient: [Color(0xFF0A0420), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    8: WorldTheme(
      name: 'Podwodne Głębiny',
      icon: Icons.water,
      gradient: [Color(0xFF002F4A), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    9: WorldTheme(
      name: 'Magiczna Wieża',
      icon: Icons.castle,
      gradient: [Color(0xFF3B0F4A), Color(0xFFFFB627)],
      accent: Color(0xFFFFB627),
    ),
    10: WorldTheme(
      name: 'Mroczny Las',
      icon: Icons.park,
      gradient: [Color(0xFF0E1F0E), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    11: WorldTheme(
      name: 'Cyberprzestrzeń',
      icon: Icons.developer_board,
      gradient: [Color(0xFF001F2E), Color(0xFFB04CFF)],
      accent: Color(0xFF00FFEA),
    ),
    12: WorldTheme(
      name: 'Smoczy Tron',
      icon: Icons.whatshot,
      gradient: [Color(0xFF4A0000), Color(0xFFFFD23F)],
      accent: Color(0xFFFFD23F),
    ),
    13: WorldTheme(
      name: 'Mglista Wyspa',
      icon: Icons.foggy,
      gradient: [Color(0xFF1F1F1F), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    14: WorldTheme(
      name: 'Pradawne Ruiny',
      icon: Icons.account_balance,
      gradient: [Color(0xFF1B0F0A), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    15: WorldTheme(
      name: 'Zimowa Kraina',
      icon: Icons.severe_cold,
      gradient: [Color(0xFF0A1F3A), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    16: WorldTheme(
      name: 'Diamentowa Kopalnia',
      icon: Icons.diamond,
      gradient: [Color(0xFF1A0A2E), Color(0xFFB04CFF)],
      accent: Color(0xFFB04CFF),
    ),
    17: WorldTheme(
      name: 'Wieczność',
      icon: Icons.all_inclusive,
      gradient: [Color(0xFF000000), Color(0xFFFFD23F)],
      accent: Color(0xFFFFD23F),
    ),
  };

  static WorldTheme forLevel(int levelId) {
    final world = worldForLevel(levelId);
    return _themes[world] ?? _themes[1]!;
  }

  static WorldTheme forWorld(int worldId) =>
      _themes[worldId] ?? _themes[1]!;
}
