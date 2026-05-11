# 06 · Tech stack

## Wymagania środowiska
- **Flutter SDK**: 3.24+ (kanał stable)
- **Dart SDK**: 3.5+
- **Android Studio**: Hedgehog+ (emulatory, debug)
- **Xcode**: 15+ (tylko na Mac; do builda iOS)
- **VS Code**: + extension Flutter, Dart
- **Konto Apple Developer** ($99/rok) — wymagane do iOS release
- **Konto Google Play Console** ($25 jednorazowo)
- **Konto AdMob** (free)
- **Konto Firebase** (free Spark plan starczy na start)

## `pubspec.yaml` — kluczowe zależności

```yaml
name: gemrush
description: Match-3 puzzle game
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Game engine
  flame: ^1.18.0
  flame_audio: ^2.10.0
  flame_bloc: ^1.11.0  # opcjonalnie zamiast riverpod

  # State management
  flutter_riverpod: ^2.5.0

  # Routing
  go_router: ^14.0.0

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.3.0
  path_provider: ^2.1.0

  # Ads
  google_mobile_ads: ^5.1.0
  app_tracking_transparency: ^2.0.5

  # IAP
  in_app_purchase: ^3.2.0

  # Firebase
  firebase_core: ^3.3.0
  firebase_analytics: ^11.2.0
  firebase_crashlytics: ^4.0.4
  firebase_remote_config: ^5.0.4

  # UI
  google_fonts: ^6.2.0
  flutter_animate: ^4.5.0
  lottie: ^3.1.0

  # Audio
  audioplayers: ^6.0.0

  # Util
  intl: ^0.19.0
  url_launcher: ^6.3.0
  package_info_plus: ^8.0.0
  device_info_plus: ^10.1.0
  connectivity_plus: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  hive_generator: ^2.0.1
  mocktail: ^1.0.0
  golden_toolkit: ^0.15.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/gems/
    - assets/images/ui/
    - assets/images/backgrounds/
    - assets/audio/sfx/
    - assets/audio/music/
    - assets/data/levels/
  fonts:
    - family: GemRushFont
      fonts:
        - asset: assets/fonts/Fredoka-Bold.ttf
          weight: 700
```

## Narzędzia developerskie
- **VS Code** (preferowane) lub **Android Studio**
- **Flutter DevTools** — performance, memory, widget inspector
- **Flame DevTools** — debug overlay (FPS, hitboxes)
- **adb** (Android debug) i **ios-deploy** (jeśli na Macu)

## Narzędzia grafika/audio (osobno opisane w 09)
- Aseprite / Figma / Affinity Designer
- TexturePacker (sprite atlasy)
- Audacity / Logic Pro / GarageBand

## Konfiguracja środowisk (dev/staging/prod)
Trzy flavory:
- `dev` — test AdMob IDs, debug logs, Firebase dev project
- `staging` — production-like, własna grupa testowa
- `prod` — production IDs, release signing

Plik `lib/core/config/env_config.dart` ładuje z `--dart-define` lub `.env`:
```dart
class EnvConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const admobInterstitialId = String.fromEnvironment('ADMOB_INTERSTITIAL');
  // ...
}
```

Build commands:
```
flutter run --dart-define=FLAVOR=dev
flutter build appbundle --dart-define=FLAVOR=prod --release
```

## CI/CD (faza 2, po MVP)
- **GitHub Actions** — lint + test na PR
- **Codemagic** lub **Fastlane** — build i deploy do storeów
- **Firebase App Distribution** — beta builds dla testerów
