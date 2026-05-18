import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/game/game_screen.dart';
import 'features/map/map_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/quests/quests_screen.dart';
import 'features/stats/stats_screen.dart';

class GemRushApp extends StatelessWidget {
  const GemRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: Routes.splash,
      routes: [
        GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
        GoRoute(path: Routes.menu, builder: (_, _) => const MenuScreen()),
        GoRoute(path: Routes.map, builder: (_, _) => const MapScreen()),
        GoRoute(
          path: '${Routes.game}/:id',
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            return GameScreen(levelId: id);
          },
        ),
        GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
        GoRoute(
          path: Routes.settings,
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.achievements,
          builder: (_, _) => const AchievementsScreen(),
        ),
        GoRoute(
          path: Routes.stats,
          builder: (_, _) => const StatsScreen(),
        ),
        GoRoute(
          path: Routes.quests,
          builder: (_, _) => const QuestsScreen(),
        ),
        GoRoute(
          path: Routes.onboarding,
          builder: (_, _) => const OnboardingScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'GemRush',
      theme: AppTheme.buildDark(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
