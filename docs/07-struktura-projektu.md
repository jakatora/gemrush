# 07 · Struktura projektu

```
gem-rush-game/
├── README.md
├── STATUS.md              ← bieżący stan prac (uzupełniany przy każdej sesji)
├── TASKS.md               ← granularny TODO 200+ zadań
├── docs/                  ← cała dokumentacja planu
├── memory/                ← pliki notatek per-feature (decyzje techniczne)
└── app/                   ← właściwy projekt Flutter (utworzony przez `flutter create`)
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── .env.example
    ├── .gitignore
    ├── android/
    │   └── app/src/main/AndroidManifest.xml   ← AdMob APP_ID
    ├── ios/
    │   └── Runner/Info.plist                  ← AdMob, ATT, SKAdNetwork
    ├── assets/
    │   ├── images/
    │   │   ├── gems/      (gem_red.png, gem_blue.png, ...,
    │   │   │              gem_red_striped_h.png, gem_red_striped_v.png,
    │   │   │              gem_red_wrapped.png, color_bomb.png)
    │   │   ├── ui/        (buttons, panels, icons)
    │   │   ├── backgrounds/  (per świat: world1.png ... world7.png)
    │   │   ├── obstacles/    (jelly.png, ice_1.png, ice_2.png, choco.png)
    │   │   └── particles/    (sparkle.png, explosion.png)
    │   ├── audio/
    │   │   ├── sfx/       (swap.ogg, match3.ogg, match4.ogg, cascade.ogg,
    │   │   │              win.ogg, lose.ogg, button.ogg, special_explode.ogg)
    │   │   └── music/     (menu_loop.mp3, game_loop_1.mp3, game_loop_2.mp3)
    │   ├── fonts/         (Fredoka-Bold.ttf)
    │   └── data/
    │       └── levels/    (level_001.json ... level_100.json)
    ├── lib/
    │   ├── main.dart                    (entry: init Firebase, Hive, Ads, runApp)
    │   ├── app.dart                     (GemRushApp: MaterialApp.router)
    │   ├── l10n/                        (intl: pl.arb, en.arb)
    │   ├── core/
    │   │   ├── config/
    │   │   │   ├── env_config.dart
    │   │   │   └── feature_flags.dart    (RemoteConfig wrapper)
    │   │   ├── constants/
    │   │   │   ├── colors.dart
    │   │   │   ├── dimensions.dart
    │   │   │   └── routes.dart
    │   │   ├── theme/
    │   │   │   └── app_theme.dart
    │   │   ├── utils/
    │   │   │   ├── extensions.dart
    │   │   │   └── result.dart           (Result<T> dla error handling)
    │   │   └── services/
    │   │       ├── ads_service.dart      ← KLUCZOWY (AdMob)
    │   │       ├── audio_service.dart
    │   │       ├── storage_service.dart  (Hive wrapper)
    │   │       ├── iap_service.dart
    │   │       ├── analytics_service.dart
    │   │       ├── consent_service.dart  (UMP + ATT)
    │   │       └── haptics_service.dart
    │   ├── features/
    │   │   ├── splash/
    │   │   │   └── splash_screen.dart
    │   │   ├── menu/
    │   │   │   ├── menu_screen.dart
    │   │   │   └── widgets/
    │   │   ├── map/
    │   │   │   ├── map_screen.dart
    │   │   │   ├── world_card.dart
    │   │   │   └── level_node.dart
    │   │   ├── game/
    │   │   │   ├── game_screen.dart           (Flutter wrapper)
    │   │   │   ├── game_logic/               ← czysty Dart (testowalne)
    │   │   │   │   ├── board.dart
    │   │   │   │   ├── gem.dart
    │   │   │   │   ├── match_finder.dart
    │   │   │   │   ├── cascade_engine.dart
    │   │   │   │   ├── special_gem_factory.dart
    │   │   │   │   ├── special_gem_effects.dart
    │   │   │   │   ├── score_engine.dart
    │   │   │   │   ├── goal_checker.dart
    │   │   │   │   └── gravity.dart
    │   │   │   ├── flame_components/         ← Flame (rendering)
    │   │   │   │   ├── gem_rush_game.dart
    │   │   │   │   ├── gem_sprite.dart
    │   │   │   │   ├── board_renderer.dart
    │   │   │   │   ├── swap_controller.dart  (input)
    │   │   │   │   ├── animation_helper.dart
    │   │   │   │   └── particle_helper.dart
    │   │   │   ├── models/
    │   │   │   │   ├── level_data.dart       (json_serializable)
    │   │   │   │   ├── level_goal.dart
    │   │   │   │   └── level_result.dart
    │   │   │   └── widgets/
    │   │   │       ├── hud.dart              (moves, score, goals)
    │   │   │       ├── booster_bar.dart
    │   │   │       ├── pre_game_dialog.dart
    │   │   │       ├── win_dialog.dart
    │   │   │       ├── lose_dialog.dart      (← rewarded ad button)
    │   │   │       └── pause_dialog.dart
    │   │   ├── shop/
    │   │   │   ├── shop_screen.dart
    │   │   │   └── iap_card.dart
    │   │   ├── settings/
    │   │   │   └── settings_screen.dart      (privacy options, lang, sound)
    │   │   └── leaderboard/
    │   │       └── leaderboard_screen.dart
    │   ├── data/
    │   │   ├── repositories/
    │   │   │   ├── level_repository.dart     (loaduje JSONy)
    │   │   │   ├── profile_repository.dart   (Hive)
    │   │   │   └── progress_repository.dart  (Hive)
    │   │   └── models/
    │   │       ├── profile.dart              (Hive adapter)
    │   │       ├── progress.dart
    │   │       └── settings.dart
    │   └── providers/                        ← Riverpod
    │       ├── game_providers.dart
    │       ├── profile_providers.dart
    │       ├── ads_providers.dart
    │       └── shop_providers.dart
    └── test/
        ├── unit/
        │   ├── match_finder_test.dart
        │   ├── cascade_engine_test.dart
        │   ├── score_engine_test.dart
        │   ├── goal_checker_test.dart
        │   └── special_gem_factory_test.dart
        ├── widget/
        │   ├── hud_test.dart
        │   └── shop_screen_test.dart
        ├── integration/
        │   └── level_complete_flow_test.dart
        └── golden/
            └── menu_screen_golden_test.dart
```

## Konwencje
- **Plik = 1 publiczna klasa/widget**, max ~300 linii
- **Snake_case** dla nazw plików
- **PascalCase** dla klas, **camelCase** dla zmiennych
- Każdy serwis (`*_service.dart`) ma test
- Logika domenowa w `game_logic/` jest **czystym Dartem** (zero importów Flame/Flutter)
- Stałe magiczne (np. cooldowny) idą do `core/constants/` lub Remote Config
