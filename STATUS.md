# STATUS — Bieżący stan prac

> **Aktualizowany na końcu każdej sesji praktycznej.**

## Aktualny etap

- **Faza**: 1 · Implementation (kod gotowy, oczekuje testów na urządzeniu)
- **Tygodnie roadmapy zaimplementowane (kodowo)**: 1, 2, 3, 4, 5, 6, 7, 8, 9, część 10/11
- **Następna faza**: integracja końcowa — wymaga akcji użytkownika (konta zewnętrzne, urządzenia)
- **Tests**: ✅ 24/24 unit tests pass · ✅ `flutter analyze` clean (tylko 9 stylowych info)

## Sesja 2 — 2026-05-11 (pełna autonomiczna implementacja MVP)

**Wykonane (w jednej sesji)**:

- ✅ GitHub repo: `jakatora/gemrush` (private) utworzone i połączone jako remote
- ✅ Flutter project utworzony: `app/` z bundle id `com.gemrush.gemrush`
- ✅ `pubspec.yaml` z pełną listą zależności (flame, riverpod, hive, ads, iap, audio, fonts)
- ✅ **Domain logic w czystym Darcie** (testowalna, 24 testy):
  - `gem.dart` — GemColor (6), GemKind (normal + 4 specjale), Pos, Cell
  - `board.dart` — Board 9×9, swap, fillRandomNoMatches, shuffleUntilPlayable, hasAnyValidMove
  - `match_finder.dart` — horizontal/vertical 3/4/5, L-shape (merge horiz+vert)
  - `special_gem_factory.dart` — match 4 → striped, L → wrapped, match 5 → color bomb
  - `special_gem_effects.dart` — eksplozje + chainowanie + **wszystkie 5 typów combo**
  - `gravity_engine.dart` — grawitacja + refill top
  - `cascade_engine.dart` — pełna pętla match → spawn → remove → gravity → refill → repeat (max 50 iter safety)
  - `score_engine.dart` — punktacja + mnożnik kaskady (max 5×)
  - `goal_checker.dart` — 4 typy celów (score, jelly, ingredients, obstacles)
- ✅ **Core services**:
  - `ads_service.dart` — pełna AdMob: preload interstitial + rewarded × 4 placementów, frequency capping (90s + 2 levels), `removeAdsPurchased` respect, daily cap rewarded
  - `iap_service.dart` — 8 produktów (IapProducts), `in_app_purchase` integration, restore, consumable handling
  - `consent_service.dart` — UMP SDK GDPR + ATT stub
  - `audio_service.dart` — SFX + music loop, mute toggle
  - `haptics_service.dart` — light/medium/heavy
  - `analytics_service.dart` — print-stub (czeka na Firebase setup); 9 typów eventów gotowych
  - `env_config.dart` — test/prod IDs z `--dart-define`
- ✅ **Hive data layer** (z wygenerowanymi `.g.dart` adapterami):
  - `Profile` (coins, lives, lastLifeRegenAt, removeAdsPurchased, unlimitedLives)
  - `LevelProgress` (stars, bestScore, attempts)
  - `AppSettings` (sound, music, haptics, language, consent)
  - 3 repositories z metodami biznesowymi (regeneracja żyć co 30 min, spend/add coins, restore purchase)
- ✅ **App shell**:
  - `main.dart` — Hive init, Firebase placeholder, ConsentService + AdMob init, IAP init
  - `app.dart` — go_router z 6 ekranami
  - `app_theme.dart` — dark theme, GoogleFonts.fredoka
  - `app_providers.dart` — Riverpod DI
  - Ekrany: Splash, Menu (z badge życ + monet), Map (7 światów × 15/10 poziomów, locked/unlocked, gwiazdki), Shop (8 produktów IAP), Settings (sound, music, haptics, privacy options, restore)
- ✅ **Flame game**:
  - `gem_rush_game.dart` — FlameGame z DragCallbacks: pełen flow swap → match/combo → cascade → win/lose check
  - `gem_sprite.dart` — proceduralna grafika 6 kolorów + kształty a11y + warianty specjalne (paski, otoczenie, color bomb tęcza)
  - `board_renderer.dart` — siatka, jelly (1-2 warstwy), ice, chocolate, blocked, swap+cascade animacje (MoveEffect)
- ✅ **HUD + dialogi**:
  - `hud.dart` — score, moves, goals (icon per type)
  - `result_dialogs.dart` — WinDialog (gwiazdki + rewarded "Podwój monety"), LoseDialog (rewarded "+5 ruchów")
  - `game_screen.dart` — pełen flow z interstitial po level end, rewarded callbacks, save progress, deduct life
- ✅ **100 poziomów JSON** wygenerowane proceduralnie (seed 42 → deterministyczne):
  - Świat 1 (1-15) Tutorial Plaża · 8x8 · score only · 28 ruchów
  - Świat 2 (16-30) Las Kryształów · 9x9 · score + clearJelly
  - Świat 3 (31-45) Lodowe Jaskinie · score + clearObstacles (ice)
  - Świat 4 (46-60) Pustynia Złota · score + clearJelly (2 warstwy)
  - Świat 5 (61-75) Wulkaniczne Klify · score + chocolate
  - Świat 6 (76-90) Niebiańskie Wyspy · ingredients
  - Świat 7 (91-100) Kosmiczna Forteca · mixed hard
- ✅ **Platformy skonfigurowane**:
  - Android: `AndroidManifest.xml` z permissions INTERNET + BILLING + AdMob APPLICATION_ID
  - iOS: `Info.plist` z `GADApplicationIdentifier` + `NSUserTrackingUsageDescription` + 10 `SKAdNetworkItems` (próbka)
- ✅ **Testy unit** (24/24 ✅):
  - match_finder (7), cascade_engine (2), score_engine (3), goal_checker (3), special_gem_effects (6), board (3)
- ✅ `flutter analyze`: tylko 9 stylowych info (`unnecessary_underscores`, `curly_braces_in_flow_control`)
- ✅ Generator poziomów w `app/tool/generate_levels.dart` (do regeneracji po rebalance)

**Stan plikowy**:

- 30+ plików Dart w `lib/`
- 100 plików JSON w `assets/data/levels/`
- 7 plików testowych w `test/unit/`
- Wszystko skompiluje się; gra uruchomi się na emulatorze / urządzeniu

## ⚠️ BLOCKERY wymagające akcji użytkownika

Posortowane wg priorytetu i typu interwencji:

### A. Konta i płatne usługi (wymagają **Twoich** credentiali)

- **[B-ADMOB-01]** ⚠️ Utwórz konto AdMob na admob.google.com (free)
  - Dodaj 2 aplikacje (Android + iOS)
  - Skopiuj produkcyjne App IDs
  - Utwórz jednostki: interstitial, rewarded (× 4 placementów), banner
  - Wstaw IDs w `app/.env` (skopiuj z `.env.example`)
  - Zastąp w `AndroidManifest.xml` (linia ~10) i `Info.plist` (klucz `GADApplicationIdentifier`)
  - **Bez tego**: gra używa testowych slotów Google → nie zarabia
- **[B-FIREBASE-01]** ⚠️ Utwórz projekt Firebase (free Spark)
  - Uruchom `dart pub global activate flutterfire_cli` → `flutterfire configure`
  - Automatycznie wygeneruje `firebase_options.dart` + `google-services.json` + `GoogleService-Info.plist`
  - Włącz Analytics + Crashlytics + Remote Config
  - Dodaj `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config` do `pubspec.yaml`
  - Podmień stub w `analytics_service.dart` na realne `FirebaseAnalytics.instance.logEvent(...)`
  - **Bez tego**: brak telemetrii i monitoringu crashy
- **[B-GP-01]** Google Play Developer Console ($25 jednorazowo)
  - Wymagane do publikacji + skonfigurowania produktów IAP
  - Utwórz 8 produktów z ID z `IapProducts` (`remove_ads`, `coins_100`, ..., `unlimited_lives_24h`)
- **[B-APPLE-01]** Apple Developer Program ($99/rok)
  - Weryfikacja tożsamości może zająć kilka dni — kup wcześnie
  - Utwórz aplikację w App Store Connect, dodaj te same 8 produktów IAP
- **[B-ATT-01]** Dodaj `app_tracking_transparency` do `pubspec.yaml` i odkomentuj wywołanie w `consent_service.dart`
  - Wymagane tylko dla iOS przed pierwszą reklamą

### B. Zawartość i grafika

- **[B-ART-01]** Grafika finalna (opcjonalne — placeholdery proceduralne działają)
  - Aktualnie: `gem_sprite.dart` rysuje gemy przez `Canvas.drawCircle` + kształty a11y
  - Najtaniej: Kenney "Puzzle Pack" (CC0) → wrzuć PNG do `assets/images/gems/`
  - Płatnie: GameDevMarket, Itch.io ($5-80) albo zlecenie artystce ($300-2000)
- **[B-AUDIO-01]** SFX i muzyka (gra działa bez audio — `audio_service` przykrywa wyjątki)
  - 13 SFX + 4 utwory: Mixkit / Freesound (free CC) lub kupne (AudioJungle)
  - Wrzuć do `assets/audio/sfx/` i `assets/audio/music/`

### C. SKAdNetwork (przed iOS launch)

- **[B-SKAN-01]** `Info.plist` zawiera próbkę 10 identyfikatorów. Wklej pełną listę 60+ z https://developers.google.com/admob/ios/ios14 (Google ją aktualizuje co kilka miesięcy)

### D. Walidacja IAP (faza 2)

- **[B-IAP-RECEIPT]** Lokalna walidacja działa, ale dla bezpieczeństwa przed mass-scale → Cloud Function backend, który weryfikuje receipty z Google + Apple endpoint

### E. Soft launch (tydzień 12 z roadmapy)

- Sprzedaży nie ma do momentu Google Play Console + App Store Connect submission
- Screenshots, video preview, opis, ASO keywords — Ty robisz po pierwszym uruchomieniu na urządzeniu

## Co zostało zaplanowane lecz nie zaimplementowane w tej sesji

- ❌ Firebase integration (czeka na konto — task B-FIREBASE-01)
- ❌ Daily login / daily quest (opcjonalne, post-MVP)
- ❌ Leaderboard online (post-MVP)
- ❌ Lokalizacja EN (struktura przygotowana — `generate: true` w pubspec, `flutter_localizations` zaimportowane; brakuje plików `.arb`)
- ❌ Realne playtesty 100 poziomów (poziomy wygenerowane proceduralnie, balans wymaga playtest na urządzeniu)
- ❌ Particle effects (Flame ma `ParticleSystem` — placeholder w board_renderer)
- ❌ Lottie celebration animations

## Następne kroki

### Co zrób Ty (1-2 godziny):

1. Załóż konto AdMob → skopiuj App IDs i Ad Unit IDs do `.env`
2. `flutterfire configure` → wygeneruje pliki Firebase
3. Uruchom na emulatorze Android: `cd app && flutter run --dart-define-from-file=.env`
4. Sprawdź czy gra startuje, czy menu działa, czy plansza się renderuje, czy swap działa

### Co zrobię ja (kolejna sesja, gdy będziesz miał konta):

1. Podłączyć Firebase Analytics właściwie (zastąpić stub)
2. Wkleić produkcyjne IDs reklam
3. Dodać Crashlytics symbol upload
4. Performance audit (gdy będzie urządzenie)
5. Pisać brakujące widget testy + integration tests
6. Pomóc z screenshotami sklepowymi
7. Hotfixy po pierwszym playtest

---

## Sesja 1 — 2026-05-11 (planowanie)

[Zwinięte — szczegóły w docs/ + commit history]
- 12 dokumentów planu w `docs/`
- System kontynuacji: `00-START-HERE.md` + `STATUS.md` + `TASKS.md`
- Zatwierdzone decyzje: nazwa GemRush, repo GitHub `jakatora/gemrush` (private), pełna gra 100 poziomów

---

## Szablon kolejnej sesji (skopiuj przed dodaniem)

```text
## Sesja N — YYYY-MM-DD (krótki opis)
**Wykonane**:
- T?.? — co dokładnie zrobione

**Decyzje podjęte podczas sesji**:
- ...

**Napotkane problemy / blockers**:
- ...

**Następny task**:
> T?.? — pełna nazwa
```
