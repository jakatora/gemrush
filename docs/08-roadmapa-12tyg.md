# 08 · Roadmapa 12 tygodni

> **Punkt orientacyjny dla każdej sesji.** Jeśli STATUS.md mówi "tydzień X", zacznij od zadań tego tygodnia.

## Faza 1 · Fundament (Tygodnie 1–2)

### Tydzień 1: Setup
- [ ] `flutter create app` w folderze `app/`
- [ ] Konfiguracja `pubspec.yaml` (wszystkie zależności z doc 06)
- [ ] Setup analysis_options.yaml + flutter_lints
- [ ] Inicjalizacja Hive (boxy: profile, progress, settings)
- [ ] Inicjalizacja Firebase (Core, Analytics, Crashlytics)
- [ ] `EnvConfig` z `--dart-define`
- [ ] Splash screen + Menu screen szkielet
- [ ] `go_router` setup (5 rout)
- [ ] Theme + Google Fonts
- [ ] Pierwszy commit, repo na GitHub (private)

### Tydzień 2: Plansza renderowa
- [ ] `GemRushGame extends FlameGame`
- [ ] `Board` (9×9, czysty Dart)
- [ ] `Gem` (6 kolorów, sprite assets) — placeholder grafika
- [ ] `BoardRenderer` (rysuje grid + gemy)
- [ ] Tap detection (jedno-tap → highlight)
- [ ] Generowanie startowego stanu bez matchy (brute force shuffle)

## Faza 2 · Mechanika match-3 (Tygodnie 3–5)

### Tydzień 3: Swap + matche
- [ ] Drag/swipe → swap dwóch sąsiednich
- [ ] Animacja swap (150 ms)
- [ ] `MatchFinder` — wykrywa horizontal/vertical 3, 4, 5, L/T
- [ ] Cofnięcie swapu jeśli brak matcha
- [ ] Unit testy `match_finder_test.dart` (min. 15 case'ów)

### Tydzień 4: Cascade + scoring
- [ ] `GravityEngine` — gemy spadają w dół
- [ ] `RefillEngine` — generowanie nowych na górze
- [ ] Pipeline: remove → gravity → refill → matchAgain (kaskada)
- [ ] `ScoreEngine` — punkty + mnożnik kaskady
- [ ] Wizualne efekty: scaleDown przed usunięciem (200ms), spadanie (300ms)
- [ ] Unit testy `cascade_engine_test.dart`, `score_engine_test.dart`

### Tydzień 5: Special gems + combo
- [ ] `SpecialGemFactory` — striped/wrapped/color bomb przy match 4, L/T, 5
- [ ] Spriting specjalnych (placeholder, finalna grafika tydz. 10)
- [ ] `SpecialGemEffects` — striped clear row/col, wrapped 3×3 (×2), color bomb (remove all of color)
- [ ] Combo system (striped+striped, wrapped+wrapped, color bomb+X)
- [ ] Unit testy special gems + combo (min. 20 case'ów)
- [ ] **Milestone**: gra w pełni grywalna, brak poziomów (nieskończona plansza)

## Faza 3 · System poziomów (Tygodnie 6–7)

### Tydzień 6: Poziomy + HUD
- [ ] Model `LevelData` + json_serializable
- [ ] `LevelRepository` — ładuje JSON z assets
- [ ] 10 testowych poziomów (level_001 do level_010 JSON)
- [ ] HUD: moves left, score, goals (z ikonkami)
- [ ] `GoalChecker` — sprawdza warunki (score, jelly cleared, ingredients collected)
- [ ] Win dialog + Lose dialog (placeholder)
- [ ] Goal types: `score`, `clearJelly`, `clearObstacles`

### Tydzień 7: Mapa świata + progresja
- [ ] `MapScreen` z 7 światami (scrollowalne)
- [ ] `LevelNode` — gwiazdki, locked/unlocked
- [ ] `ProgressRepository` (Hive) — zapis ★ best score
- [ ] Save state: monety, życia, lastLifeRegen
- [ ] System 5 żyć z regeneracją 30 min (timer w tle)
- [ ] Animacja "podróży" po mapie po wygranej

## Faza 4 · Monetyzacja (Tygodnie 8–9)

### Tydzień 8: AdMob
- [ ] Założenie konta AdMob, dodanie 2 aplikacji (Android, iOS)
- [ ] Konfiguracja `AndroidManifest.xml` (App ID)
- [ ] Konfiguracja `Info.plist` (App ID + SKAdNetwork + ATT)
- [ ] `ConsentService` — UMP SDK GDPR consent flow
- [ ] iOS ATT prompt (po consent, przed init AdMob)
- [ ] `AdsService.preloadInterstitial()` + cooldown logic
- [ ] Pokazanie interstitial po level end (z respektem `removeAdsPurchased`)
- [ ] `AdsService.showRewarded()` dla 4 placementów
- [ ] Lose dialog: "+5 ruchów za reklamę" przycisk
- [ ] Out of lives dialog: "Życie za reklamę"
- [ ] Pre-game dialog: "Hint za reklamę"
- [ ] Win dialog: "Podwój monety za reklamę"
- [ ] Test na realnym urządzeniu Android + iOS

### Tydzień 9: IAP + sklep
- [ ] Założenie produktów IAP w Google Play Console + App Store Connect
- [ ] `IapService` z `in_app_purchase`
- [ ] `ShopScreen` — pakiety monet, remove ads, starter pack
- [ ] Purchase flow + restore purchases
- [ ] Boostery (pre-game + in-game)
- [ ] Coin transactions logging (Firebase Analytics)
- [ ] **Milestone**: pełna ekonomia działa, mock IAP w sandbox

## Faza 5 · Treść i polish (Tygodnie 10–11)

### Tydzień 10: Poziomy 1-50 + polish
- [ ] Design poziomów 11–50 (40 poziomów, ~5 dziennie)
- [ ] Playtest każdego (~5 prób, pass rate notowane)
- [ ] Finalna grafika gemów (6 kolorów + specjale)
- [ ] Particle effects: match explosion, cascade sparkle
- [ ] Animacje win/lose (Lottie albo flame particles)
- [ ] Audio: 10 SFX + 2 muzyka loop
- [ ] Haptic feedback (lekki przy swap, mocny przy combo)

### Tydzień 11: Poziomy 51-100 + Remote Config
- [ ] Design poziomów 51–100 (50 poziomów, ~7 dziennie)
- [ ] Playtest
- [ ] Firebase Remote Config: `ad_cooldown`, `levels_between_ads`, `level_moves_override`
- [ ] A/B test variants (ad frequency)
- [ ] Daily quest system (opcjonalnie, jeśli czas)
- [ ] Daily login reward
- [ ] Settings: privacy options, restore purchases, lang switch

## Faza 6 · Release (Tydzień 12)

### Tydzień 12: Soft launch
- [ ] Production AdMob IDs (replace test IDs)
- [ ] Crashlytics events tested
- [ ] Performance audit (60 FPS na średnim Android, dev tools)
- [ ] Memory leaks check
- [ ] Store assets:
  - [ ] Ikona 512×512
  - [ ] Feature graphic 1024×500 (Google Play)
  - [ ] Screenshots: 8 sztuk per platforma (telefon + tablet)
  - [ ] Video preview 30s
  - [ ] Opis (PL + EN), keywords ASO
- [ ] Privacy Policy + ToS — opublikowane na własnej domenie / Notion public
- [ ] Google Play Internal Testing → Closed Testing
- [ ] TestFlight beta
- [ ] Soft launch: Polska (lub PL+CZ+SK)
- [ ] Monitoring D1 retention, crash-free rate, ARPDAU przez 7 dni
- [ ] **Milestone**: gra opublikowana, soft launch monitorowany

## Po launch (poza scope 12 tyg.)
- Battle pass / sezony
- Eventy świąteczne
- Leaderboard online (Firebase Firestore)
- Social: Facebook login, friends, life gifting
- Lokalizacje (EN, DE, ES, FR)
- Cloud save
- Global launch (po pozytywnych KPI z soft launch)
