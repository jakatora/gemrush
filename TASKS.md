# TASKS — Granularna lista zadań

> **Konwencja**: `[ ]` todo · `[x]` done · `[/]` in progress · `[~]` skipped · `[!]` blocked
> Każdy task ma ID `T<faza>.<numer>` aby łatwo go cytować w STATUS.md.

## Tydzień 1 · Setup
- [ ] T1.1 — `flutter create app` w folderze `gem-rush-game/app/` (z bundle id `com.gemrush.game` lub potwierdzonym alternatywnym)
- [ ] T1.2 — `pubspec.yaml` — dodaj wszystkie zależności z `docs/06-tech-stack.md`
- [ ] T1.3 — `analysis_options.yaml` — włącz `flutter_lints` + dodatkowe rules (`prefer_const_constructors`, `avoid_print`)
- [ ] T1.4 — utwórz `.gitignore` (build/, .env, .idea/, ios/Podfile.lock optional)
- [ ] T1.5 — utwórz `.env.example` ze wszystkimi kluczami (puste wartości)
- [ ] T1.6 — `lib/core/config/env_config.dart` z `String.fromEnvironment` dla flavor + AdMob IDs
- [ ] T1.7 — `lib/main.dart` — entrypoint, inicjalizacja Hive + Firebase
- [ ] T1.8 — `lib/app.dart` — `GemRushApp` z `MaterialApp.router`
- [ ] T1.9 — `lib/core/constants/routes.dart` + go_router setup (`/splash`, `/menu`, `/map`, `/game/:id`, `/shop`, `/settings`)
- [ ] T1.10 — `lib/core/theme/app_theme.dart` — kolory, typografia (Fredoka), button styles
- [ ] T1.11 — `lib/features/splash/splash_screen.dart` — placeholder z logo
- [ ] T1.12 — `lib/features/menu/menu_screen.dart` — szkielet z przyciskami: Play, Shop, Settings
- [ ] T1.13 — init Firebase (Android: `google-services.json`, iOS: `GoogleService-Info.plist`) → wymaga konta Firebase
- [ ] T1.14 — pierwsza inicjalizacja Hive (`Hive.initFlutter()` + register adapters)
- [ ] T1.15 — `git init`, pierwszy commit, push na GitHub private (jeśli userem zatwierdzone)

## Tydzień 2 · Plansza renderowa
- [ ] T2.1 — `lib/features/game/game_logic/gem.dart` — model Gem (color, type, position)
- [ ] T2.2 — `lib/features/game/game_logic/board.dart` — model Board (9×9, get/set gem, isValid)
- [ ] T2.3 — `lib/features/game/game_logic/board.dart` — `Board.shuffleNoMatches()` (generowanie startowego stanu)
- [ ] T2.4 — unit test `board_test.dart` — generowanie boardu nie produkuje matchy
- [ ] T2.5 — placeholder assety: pobierz Kenney Puzzle Pack (CC0), wrzuć do `assets/images/gems/` (6 kolorów)
- [ ] T2.6 — `lib/features/game/flame_components/gem_rush_game.dart` — `GemRushGame extends FlameGame`
- [ ] T2.7 — `lib/features/game/flame_components/gem_sprite.dart` — `GemSprite extends PositionComponent`
- [ ] T2.8 — `lib/features/game/flame_components/board_renderer.dart` — rysuje grid 9×9
- [ ] T2.9 — `lib/features/game/game_screen.dart` — `Scaffold` z `GameWidget(game: ...)`
- [ ] T2.10 — tap detection na gem (highlight)

## Tydzień 3 · Swap + matche
- [ ] T3.1 — `lib/features/game/flame_components/swap_controller.dart` — drag detection, sąsiedztwo
- [ ] T3.2 — animacja swap (150 ms, Tween)
- [ ] T3.3 — `lib/features/game/game_logic/match_finder.dart` — interface + horizontal/vertical 3
- [ ] T3.4 — `match_finder.dart` — wykrywanie 4, 5
- [ ] T3.5 — `match_finder.dart` — wykrywanie L/T
- [ ] T3.6 — `match_finder.dart` — merge nakładających się matchy
- [ ] T3.7 — unit testy `match_finder_test.dart` (15 case'ów z doc 10)
- [ ] T3.8 — logika cofania swapu jeśli brak matcha (z animacją back 300ms)
- [ ] T3.9 — integracja: swap → findMatches → cofnij/usuń

## Tydzień 4 · Cascade + scoring
- [ ] T4.1 — `lib/features/game/game_logic/gravity.dart` — gemy spadają w dół na puste pola
- [ ] T4.2 — `lib/features/game/game_logic/gravity.dart` — refill top row z losowych kolorów (z `allowedColors` poziomu)
- [ ] T4.3 — `lib/features/game/game_logic/cascade_engine.dart` — pipeline `removeMatches → gravity → refill → matchAgain`
- [ ] T4.4 — wizualne efekty usuwania (scale 0, fade out, 200ms)
- [ ] T4.5 — animacja spadania (ease-in-out 300ms)
- [ ] T4.6 — `lib/features/game/game_logic/score_engine.dart` — punktacja + mnożnik kaskady (max 5×)
- [ ] T4.7 — unit testy `cascade_engine_test.dart`, `score_engine_test.dart`
- [ ] T4.8 — HUD placeholder pokazujący score

## Tydzień 5 · Special gems + combo
- [ ] T5.1 — `lib/features/game/game_logic/special_gem_factory.dart` — match 4 → striped (horizontal/vertical)
- [ ] T5.2 — `special_gem_factory.dart` — L/T → wrapped (na narożniku)
- [ ] T5.3 — `special_gem_factory.dart` — match 5 → color bomb
- [ ] T5.4 — placeholder sprites: striped (paski), wrapped (otoczone), color bomb (tęczowa kula)
- [ ] T5.5 — `lib/features/game/game_logic/special_gem_effects.dart` — striped clear row/col
- [ ] T5.6 — `special_gem_effects.dart` — wrapped 3×3 explosion ×2 (z opóźnieniem)
- [ ] T5.7 — `special_gem_effects.dart` — color bomb remove all of color
- [ ] T5.8 — combo: striped + striped (krzyż)
- [ ] T5.9 — combo: striped + wrapped (3 rzędy + 3 kolumny)
- [ ] T5.10 — combo: wrapped + wrapped (5×5)
- [ ] T5.11 — combo: color bomb + striped/wrapped (zamiana wszystkich kolorów)
- [ ] T5.12 — combo: color bomb + color bomb (cała plansza)
- [ ] T5.13 — unit testy special gems + combo (20 case'ów z doc 10)
- [ ] T5.14 — **Milestone M2**: gra w pełni grywalna (nieskończona plansza, brak poziomów)

## Tydzień 6 · Poziomy + HUD
- [ ] T6.1 — `lib/features/game/models/level_data.dart` — model + json_serializable
- [ ] T6.2 — `lib/features/game/models/level_goal.dart` — typy: score, clearJelly, collectIngredients, clearObstacles
- [ ] T6.3 — `lib/data/repositories/level_repository.dart` — ładowanie JSON z `assets/data/levels/`
- [ ] T6.4 — utworzenie `assets/data/levels/level_001.json` do `level_010.json` (tutorial)
- [ ] T6.5 — `lib/features/game/widgets/hud.dart` — moves left, score, goals z ikonkami
- [ ] T6.6 — `lib/features/game/game_logic/goal_checker.dart` — sprawdza warunki wygranej
- [ ] T6.7 — `lib/features/game/widgets/win_dialog.dart` — gwiazdki + monety
- [ ] T6.8 — `lib/features/game/widgets/lose_dialog.dart` — przycisk retry + (placeholder) rewarded
- [ ] T6.9 — implementacja jelly (`clearJelly`) — 2 warstwy, usuwana przez match na polu
- [ ] T6.10 — implementacja crate (`clearObstacles`) — 1 i 2 HP
- [ ] T6.11 — implementacja ingredient drop (`collectIngredients`) — spada na dół planszy

## Tydzień 7 · Mapa świata + progresja
- [ ] T7.1 — `lib/features/map/map_screen.dart` — scrollowalna mapa 7 światów
- [ ] T7.2 — `lib/features/map/world_card.dart` — karta świata z gradient bg
- [ ] T7.3 — `lib/features/map/level_node.dart` — node poziomu z ★, locked/unlocked
- [ ] T7.4 — `lib/data/models/progress.dart` — Hive adapter (level_id → stars + bestScore)
- [ ] T7.5 — `lib/data/repositories/progress_repository.dart` — save/load progresji
- [ ] T7.6 — `lib/data/models/profile.dart` — Hive adapter (coins, lives, lastLifeRegen, removeAdsPurchased)
- [ ] T7.7 — `lib/data/repositories/profile_repository.dart` — save/load profilu
- [ ] T7.8 — system 5 żyć z regeneracją 30 min (timer obliczany przy aplikacji)
- [ ] T7.9 — animacja "podróży" po mapie po wygranej (camera pan do następnego node)
- [ ] T7.10 — dialog "Out of lives" gdy lives = 0

## Tydzień 8 · AdMob (KLUCZOWE)
- [ ] T8.1 — Założenie konta AdMob (lub potwierdzenie istniejącego) — wymaga user action
- [ ] T8.2 — Dodanie aplikacji Android w AdMob, kopia App ID
- [ ] T8.3 — Dodanie aplikacji iOS w AdMob, kopia App ID
- [ ] T8.4 — Utworzenie jednostek: `inter_post_level`, `reward_extra_life`, `reward_extra_moves`, `reward_hint`, `reward_double_coins` (× 2 platformy)
- [ ] T8.5 — `android/app/src/main/AndroidManifest.xml` — `<meta-data>` z `APPLICATION_ID`
- [ ] T8.6 — `ios/Runner/Info.plist` — `GADApplicationIdentifier`
- [ ] T8.7 — `Info.plist` — `SKAdNetworkItems` (pełna lista 60+ z AdMob docs)
- [ ] T8.8 — `Info.plist` — `NSUserTrackingUsageDescription`
- [ ] T8.9 — `lib/core/services/consent_service.dart` — UMP SDK GDPR consent flow
- [ ] T8.10 — `consent_service.dart` — iOS ATT prompt (po UMP, przed init Ads)
- [ ] T8.11 — `lib/core/services/ads_service.dart` — `init()`, `preloadInterstitial()`
- [ ] T8.12 — `ads_service.dart` — `maybeShowInterstitial()` z frequency capping (90s cooldown, 2 levels min)
- [ ] T8.13 — `ads_service.dart` — `preloadRewarded(placement)` + `showRewarded(placement)`
- [ ] T8.14 — integracja: trigger `maybeShowInterstitial()` po level end (Win i Lose)
- [ ] T8.15 — `lose_dialog.dart` — przycisk "Get +5 moves (watch ad)" → rewarded
- [ ] T8.16 — `out_of_lives_dialog.dart` — przycisk "Get 1 life (watch ad)" → rewarded
- [ ] T8.17 — `pre_game_dialog.dart` — przycisk "Hint (watch ad)" → rewarded
- [ ] T8.18 — `win_dialog.dart` — przycisk "Double coins (watch ad)" → rewarded
- [ ] T8.19 — analytics events: `ad_request`, `ad_loaded`, `ad_shown`, `ad_failed`, `rewarded_completed`
- [ ] T8.20 — test na realnym Android (test IDs ok)
- [ ] T8.21 — test na realnym iOS (test IDs ok)
- [ ] T8.22 — test offline (brak crashy gdy brak internetu)

## Tydzień 9 · IAP + sklep
- [ ] T9.1 — Założenie produktów IAP w Google Play Console (8 produktów z doc 05)
- [ ] T9.2 — Założenie produktów IAP w App Store Connect (8 produktów)
- [ ] T9.3 — `lib/core/services/iap_service.dart` — `init()`, `loadProducts()`, `purchase()`, `restorePurchases()`
- [ ] T9.4 — `iap_service.dart` — handlers `onPurchaseSuccess`, `onPurchaseError`, `onPurchaseCanceled`
- [ ] T9.5 — `iap_service.dart` — consumable confirm (consumePurchase po success)
- [ ] T9.6 — `lib/features/shop/shop_screen.dart` — sekcje: Coins, Life packs, Special offers, Remove ads
- [ ] T9.7 — `lib/features/shop/iap_card.dart` — karta produktu z ceną lokalną
- [ ] T9.8 — `removeAdsPurchased` flag synchronizowany z Hive
- [ ] T9.9 — booster sklep (in-game) — przycisk "buy 5 moves for 200 coins" jako alternatywa rewarded
- [ ] T9.10 — analytics: `iap_purchase`, `iap_failed`, `iap_restore`
- [ ] T9.11 — test sandbox Google Play (test card)
- [ ] T9.12 — test sandbox Apple (sandbox account)
- [ ] T9.13 — **Milestone M3**: pełna ekonomia działa

## Tydzień 10 · Poziomy 11-50 + polish
- [ ] T10.1 — design poziomy 11-20 (Świat 1+2)
- [ ] T10.2 — design poziomy 21-30 (Świat 2)
- [ ] T10.3 — design poziomy 31-40 (Świat 3)
- [ ] T10.4 — design poziomy 41-50 (Świat 4 początek)
- [ ] T10.5 — playtest poziomów 1-50 (każdy ~5 prób, notuj pass rate)
- [ ] T10.6 — finalna grafika gemów × 6 kolorów (kupna lub AI-generated + dopracowanie)
- [ ] T10.7 — finalna grafika specjali (striped h/v, wrapped, color bomb)
- [ ] T10.8 — particle effects: match explosion (Flame ParticleSystem)
- [ ] T10.9 — particle effects: cascade sparkle, win celebration
- [ ] T10.10 — Lottie animacje: win celebration, lose sad
- [ ] T10.11 — audio: 10 SFX (kupne z Mixkit / Freesound / kupiony pakiet)
- [ ] T10.12 — audio: 2 muzyka loop (menu + gameplay)
- [ ] T10.13 — `audio_service.dart` — mute toggle, ducking podczas SFX
- [ ] T10.14 — haptic feedback (lekki przy swap, mocny przy combo)

## Tydzień 11 · Poziomy 51-100 + Remote Config
- [ ] T11.1 — design poziomy 51-60 (Świat 4)
- [ ] T11.2 — design poziomy 61-70 (Świat 5)
- [ ] T11.3 — design poziomy 71-80 (Świat 5+6)
- [ ] T11.4 — design poziomy 81-90 (Świat 6)
- [ ] T11.5 — design poziomy 91-100 (Świat 7 — endgame)
- [ ] T11.6 — playtest poziomów 51-100
- [ ] T11.7 — `lib/core/config/feature_flags.dart` — Remote Config wrapper
- [ ] T11.8 — defaults: `interstitial_cooldown_seconds`, `interstitial_levels_between`, `interstitial_first_level_allowed`, `rewarded_daily_cap`
- [ ] T11.9 — A/B test variant (ad frequency)
- [ ] T11.10 — daily login reward (7-day cycle) — opcjonalne
- [ ] T11.11 — daily quest (3 zadania) — opcjonalne
- [ ] T11.12 — `lib/features/settings/settings_screen.dart` — privacy options, restore purchases, language
- [ ] T11.13 — l10n: PL + EN (`pl.arb`, `en.arb`)

## Tydzień 12 · Soft launch
- [ ] T12.1 — Production AdMob IDs (replace test IDs w `.env`)
- [ ] T12.2 — Crashlytics — test crash zarejestrowany
- [ ] T12.3 — Performance audit (DevTools, 60 FPS test)
- [ ] T12.4 — Memory leak check (30 min gry, monitorowanie)
- [ ] T12.5 — APK/IPA size analysis (`flutter build appbundle --analyze-size`)
- [ ] T12.6 — App icon 512×512 (Google Play) + 1024×1024 (App Store)
- [ ] T12.7 — Feature graphic 1024×500 (Google Play)
- [ ] T12.8 — Screenshots: 8 sztuk iPhone 6.7", 5.5"; 8 sztuk Android phone
- [ ] T12.9 — App preview video 30s (opcjonalne)
- [ ] T12.10 — Krótki + pełny opis sklepowy (PL + EN)
- [ ] T12.11 — ASO keywords (PL + EN)
- [ ] T12.12 — Privacy Policy — hosting + wszystkie sekcje z doc 11
- [ ] T12.13 — Terms of Service — hosting
- [ ] T12.14 — IARC questionnaire (Google Play) → rating PEGI 3
- [ ] T12.15 — App Store Age Rating questionnaire → rating 4+
- [ ] T12.16 — Data Safety (Google) + App Privacy (Apple) deklaracje
- [ ] T12.17 — Internal Testing track upload (AAB)
- [ ] T12.18 — TestFlight beta upload (IPA)
- [ ] T12.19 — Closed testing 20+ osób
- [ ] T12.20 — Bugfix rounda po feedbacku beta
- [ ] T12.21 — Soft launch Polska (Google Play Production, App Store)
- [ ] T12.22 — Monitoring D1, D7, crash-free, eCPM przez 7 dni
- [ ] T12.23 — **Milestone M4**: gra opublikowana w PL

## Post-launch (poza 12 tyg.)
- [ ] PL1 — Battle pass / sezony
- [ ] PL2 — Eventy świąteczne
- [ ] PL3 — Leaderboard online (Firestore)
- [ ] PL4 — Social: Facebook login, friends, life gifting
- [ ] PL5 — Lokalizacje: DE, ES, FR
- [ ] PL6 — Cloud save
- [ ] PL7 — Global launch
