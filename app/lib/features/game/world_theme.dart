import 'package:flutter/material.dart';

import '../../core/i18n/app_locale.dart';
import '../../data/repositories/level_repository.dart';

/// Wizualny motyw świata używany w GameScreen i innych miejscach
/// pokazujących level/world (tło, akcent, ikona).
class WorldTheme {
  /// PL name (zachowane dla wstecznej kompatybilności).
  final String name;
  final String nameEn;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const WorldTheme({
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  String localizedName(BuildContext context) {
    return LocaleScope.of(context) == AppLocale.pl ? name : nameEn;
  }

  static const _themes = <int, WorldTheme>{
    1: WorldTheme(
      name: 'Tutorial Plaża',
      nameEn: 'Tutorial Beach',
      icon: Icons.beach_access,
      gradient: [Color(0xFF1E3A8A), Color(0xFFE0A726)],
      accent: Color(0xFFFFD23F),
    ),
    2: WorldTheme(
      name: 'Las Kryształów',
      nameEn: 'Crystal Forest',
      icon: Icons.forest,
      gradient: [Color(0xFF1E3A2C), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    3: WorldTheme(
      name: 'Lodowe Jaskinie',
      nameEn: 'Ice Caves',
      icon: Icons.ac_unit,
      gradient: [Color(0xFF0F2F5E), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    4: WorldTheme(
      name: 'Pustynia Złota',
      nameEn: 'Golden Desert',
      icon: Icons.wb_sunny,
      gradient: [Color(0xFF5C2D0E), Color(0xFFFFB627)],
      accent: Color(0xFFFFB627),
    ),
    5: WorldTheme(
      name: 'Wulkaniczne Klify',
      nameEn: 'Volcanic Cliffs',
      icon: Icons.local_fire_department,
      gradient: [Color(0xFF3B0F0F), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    6: WorldTheme(
      name: 'Niebiańskie Wyspy',
      nameEn: 'Sky Islands',
      icon: Icons.cloud,
      gradient: [Color(0xFF1F1B5C), Color(0xFFB04CFF)],
      accent: Color(0xFFB04CFF),
    ),
    7: WorldTheme(
      name: 'Kosmiczna Forteca',
      nameEn: 'Cosmic Fortress',
      icon: Icons.rocket_launch,
      gradient: [Color(0xFF0A0420), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    8: WorldTheme(
      name: 'Podwodne Głębiny',
      nameEn: 'Deep Sea',
      icon: Icons.water,
      gradient: [Color(0xFF002F4A), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    9: WorldTheme(
      name: 'Magiczna Wieża',
      nameEn: 'Wizard Tower',
      icon: Icons.castle,
      gradient: [Color(0xFF3B0F4A), Color(0xFFFFB627)],
      accent: Color(0xFFFFB627),
    ),
    10: WorldTheme(
      name: 'Mroczny Las',
      nameEn: 'Dark Woods',
      icon: Icons.park,
      gradient: [Color(0xFF0E1F0E), Color(0xFF49D88B)],
      accent: Color(0xFF49D88B),
    ),
    11: WorldTheme(
      name: 'Cyberprzestrzeń',
      nameEn: 'Cyberspace',
      icon: Icons.developer_board,
      gradient: [Color(0xFF001F2E), Color(0xFFB04CFF)],
      accent: Color(0xFF00FFEA),
    ),
    12: WorldTheme(
      name: 'Smoczy Tron',
      nameEn: 'Dragon Throne',
      icon: Icons.whatshot,
      gradient: [Color(0xFF4A0000), Color(0xFFFFD23F)],
      accent: Color(0xFFFFD23F),
    ),
    13: WorldTheme(
      name: 'Mglista Wyspa',
      nameEn: 'Misty Isle',
      icon: Icons.foggy,
      gradient: [Color(0xFF1F1F1F), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    14: WorldTheme(
      name: 'Pradawne Ruiny',
      nameEn: 'Ancient Ruins',
      icon: Icons.account_balance,
      gradient: [Color(0xFF1B0F0A), Color(0xFFFF4757)],
      accent: Color(0xFFFF4757),
    ),
    15: WorldTheme(
      name: 'Zimowa Kraina',
      nameEn: 'Winter Realm',
      icon: Icons.severe_cold,
      gradient: [Color(0xFF0A1F3A), Color(0xFFB7D3FF)],
      accent: Color(0xFFB7D3FF),
    ),
    16: WorldTheme(
      name: 'Diamentowa Kopalnia',
      nameEn: 'Diamond Mine',
      icon: Icons.diamond,
      gradient: [Color(0xFF1A0A2E), Color(0xFFB04CFF)],
      accent: Color(0xFFB04CFF),
    ),
    17: WorldTheme(
      name: 'Wieczność',
      nameEn: 'Eternity',
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

  /// Asset path do tla swiata (1080x1920 PNG wygenerowane przez Canva).
  /// Zwraca format `assets/images/backgrounds/world_NN.png` z zero-paddingiem.
  static String backgroundPathForWorld(int worldId) {
    final clamped = worldId.clamp(1, _themes.length);
    return 'assets/images/backgrounds/world_${clamped.toString().padLeft(2, '0')}.png';
  }

  static String backgroundPathForLevel(int levelId) =>
      backgroundPathForWorld(worldForLevel(levelId));
}
