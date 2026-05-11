# 10 · Testowanie i QA

## Piramida testów

```
          ▲
         ╱ ╲       Manual playtest (każdy poziom)
        ╱E2E╲      Integration tests (krytyczne flow)
       ╱─────╲     Widget tests (ekrany)
      ╱ Unit  ╲    Unit tests (logika domenowa) ← większość
     ╱─────────╲
```

## Unit tests (`test/unit/`)
Cel: pokrycie **>80%** logiki w `game_logic/`.

### Match finder
```dart
test('detects horizontal match 3', () { ... });
test('detects vertical match 3', () { ... });
test('detects match 4 → striped trigger', () { ... });
test('detects match 5 → color bomb trigger', () { ... });
test('detects L-shape match → wrapped trigger', () { ... });
test('detects T-shape match → wrapped trigger', () { ... });
test('no match returned for adjacent different colors', () { ... });
test('overlapping matches merged correctly', () { ... });
test('color bomb does not trigger random matches', () { ... });
```

### Cascade engine
```dart
test('removed gems fall down by gravity', () { ... });
test('top row refilled with new random gems', () { ... });
test('chain triggers second match after refill', () { ... });
test('chain multiplier increments per cascade', () { ... });
test('chain multiplier caps at 5x', () { ... });
```

### Score engine
```dart
test('match 3 = 60 points', () { ... });
test('match 4 = 120 points', () { ... });
test('cascade x2 doubles next match', () { ... });
test('bonus moves convert to striped', () { ... });
```

### Goal checker
```dart
test('score goal completes when target reached', () { ... });
test('clear jelly completes when last jelly removed', () { ... });
test('ingredients goal counts only those reaching bottom row', () { ... });
test('lose triggers when moves = 0 and goal incomplete', () { ... });
```

### Special gem factory + effects
```dart
test('match 4 horizontal spawns striped horizontal', () { ... });
test('match 4 vertical spawns striped vertical', () { ... });
test('L-shape spawns wrapped at corner', () { ... });
test('match 5 line spawns color bomb', () { ... });
test('striped horizontal clears entire row', () { ... });
test('wrapped explodes 3x3 twice with delay', () { ... });
test('color bomb removes all of swapped color', () { ... });
test('color bomb + striped converts all of color to striped', () { ... });
test('color bomb + color bomb clears entire board', () { ... });
```

## Widget tests (`test/widget/`)
- HUD wyświetla score / moves / goals zgodnie ze stanem
- Win dialog pokazuje gwiazdki + nagrody
- Lose dialog pokazuje przycisk rewarded
- Shop screen pokazuje produkty z mock IapService
- Settings screen toggle'uje sound/music

## Integration tests (`integration_test/`)
- Pełny flow: menu → mapa → wybór poziomu 1 → swap dwa razy → match → cascade → win → wróć na mapę
- Out of lives flow: przegraj 5 razy → dialog "Życie za reklamę" → mock rewarded callback → +1 życie
- Remove ads flow: kup `remove_ads` (mock) → po level end brak interstitial

## Manual QA — checklist per poziom (100 poziomów × ~5 min = 8h pracy)
Przy każdym poziomie sprawdź:
- [ ] Cel jest osiągalny w deklarowanej liczbie ruchów (przy idealnej grze)
- [ ] Cel jest "wyzwaniem" (nie wygrywasz przy pierwszej próbie po 30+ poziomie)
- [ ] Brak deadlocków — gdy brak ruchów, shuffle działa
- [ ] Wszystkie obstacles renderują się poprawnie
- [ ] Gwiazdki 2★ i 3★ są osiągalne (nie tylko 1★)

## Performance audit
- **Target**: 60 FPS na średnim Android (Snapdragon 7-series, 2022)
- Narzędzia: Flutter DevTools Performance, Flame `debugMode = true`
- Sprawdź:
  - [ ] Brak jank > 16 ms
  - [ ] Pamięć stabilna (brak leaków przez 30 min gry)
  - [ ] APK/IPA size < 100 MB (asset compression)
  - [ ] Cold start < 3 s
  - [ ] Hot reload < 1 s

## Compatibility matrix
**Android**:
- Min SDK: 21 (Android 5.0 — pokrycie 99.5%)
- Target SDK: 34 (Android 14)
- Testowane na: API 21, 28, 30, 33, 34

**iOS**:
- Min iOS: 12.0
- Target iOS: 17.0
- Testowane na: iPhone 8, iPhone 12, iPhone 15, iPad

## Beta testing
- **Tydzień 11**: Google Play Internal Testing (do 100 testerów)
- **Tydzień 11.5**: Closed Testing (do 1000)
- **Tydzień 12**: TestFlight (do 10 000)
- Feedback channel: Google Form / Discord serwer

## Crashlytics monitoring (post-launch)
- Crash-free users target: **> 99.5%**
- Codzienne sprawdzenie top 3 crashy
- Alerty Slack/email przy crash rate > 1% w ciągu godziny

## Analytics events do walidacji
- [ ] `level_start` ma `level_id`, `attempt_number`
- [ ] `level_complete` ma `level_id`, `stars`, `moves_used`, `time_spent`
- [ ] `level_fail` ma `level_id`, `goal_progress`
- [ ] `iap_purchase` ma `product_id`, `value`, `currency`
- [ ] `ad_revenue` (jeśli dostępne z mediacji)
- [ ] `funnel`: menu → first_level_start → first_level_complete (D1)
