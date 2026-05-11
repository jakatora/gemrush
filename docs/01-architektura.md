# 01 · Architektura techniczna

## Stack
- **Flutter 3.x** (Dart 3.x) — UI, routing, ekrany menu/sklepu/ustawień
- **Flame 1.x** — silnik 2D do renderowania planszy, animacji, gestów w grze
- **Riverpod** — state management (gra, profil, sklep, ads)
- **Hive** — lokalna baza (postęp, monety, życia, ustawienia)
- **Firebase** — Analytics, Crashlytics, Remote Config (A/B częstotliwości reklam)

## Warstwy

```
┌─────────────────────────────────────────────────┐
│  Presentation (Flutter widgets + Flame game)    │
│  · Ekrany menu/mapa/sklep/ustawienia (Flutter)  │
│  · GameWidget(Flame) → renderuje planszę        │
├─────────────────────────────────────────────────┤
│  Application / State (Riverpod providers)       │
│  · gameStateProvider, livesProvider,            │
│    coinsProvider, adsProvider, levelProvider    │
├─────────────────────────────────────────────────┤
│  Domain (czysty Dart, testowalny)               │
│  · Board, Gem, MatchFinder, Cascade,            │
│    SpecialGemFactory, LevelGoals, ScoreEngine   │
├─────────────────────────────────────────────────┤
│  Data / Services                                │
│  · HiveStorage, AdsService (AdMob),             │
│    IapService, AnalyticsService,                │
│    LevelRepository (JSON loader),               │
│    AudioService                                 │
└─────────────────────────────────────────────────┘
```

## Kluczowa zasada
**Domain** (logika match-3) jest czystym Dartem — bez Flame, bez Flutter. Dzięki temu pokrywamy ją unit testami. Flame dostaje gotowe stany i tylko renderuje.

## Routing
`go_router` — ekrany: `/splash`, `/menu`, `/map`, `/game/:levelId`, `/shop`, `/settings`, `/leaderboard`.

## Save state (Hive)
Boxy:
- `profile` — coins, lives, lastLifeRegenAt, removeAdsPurchased, lastSeenLevel
- `progress` — `Map<levelId, {stars, bestScore, completed}>`
- `settings` — sound, music, vibration, lang
- `ads` — lastInterstitialShownAt, sessionAdCount (dla frequency capping)

## Dependency injection
Riverpod providers (`Provider`, `StateNotifierProvider`) zamiast osobnego DI. `ads_service.dart` jest singletonem przez `Provider`.

## Wątki / async
- Match detection w main isolate (zoptymalizowane, ~9×9 = trywialne)
- Hive — asynchroniczne zapisy, ale dane w pamięci
- AdMob — async load, listenery przez Future/Stream
- Firebase Analytics — fire-and-forget

## Wersjonowanie
Semantic versioning w `pubspec.yaml`. Schemat: `MAJOR.MINOR.PATCH+BUILD` (np. `1.0.0+1`). BUILD inkrementowany przy każdym uploadzie do storeów.
