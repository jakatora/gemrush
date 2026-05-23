# Google Play Console — Release Checklist (Gem Rush Saga v1.0.0+2)

> Krok-po-kroku co zrobić w Play Console żeby wypuścić Internal Testing →
> Closed → Production.

## 1. Założenie aplikacji (jeśli nie utworzona)

Play Console → **All apps → Create app**:
- App name: **`Gem Rush Saga`**
- Default language: **Polish (Poland)**
- App or game: **Game**
- Free or paid: **Free**
- Declarations: zaznacz wszystkie (Developer Program Policies, US export laws)

## 2. App content (lewy panel)

### Privacy Policy
URL: **`https://jakatora.github.io/gemrush/`**
(po włączeniu GitHub Pages — patrz § 6 poniżej)

### App access
- **All functionality is available without any access restrictions** ✓
- (gra single-player, brak loginu)

### Ads
- **No, my app does not contain ads** ✓
- (po dodaniu AdMob w przyszłości: zmień na "Yes")

### Content rating
Wypełnij **IARC questionnaire**:
- Czy zawiera przemoc? → **Nie**
- Czy zawiera nagość? → **Nie**
- Czy hazard? → **Nie**
- Czy zachęca do zakupów? → **Nie** (brak IAP)
- Result: **PEGI 3 / ESRB Everyone**

### Target audience and content
- **Target age groups**: 13+
- **Appeals to children**: Nie
- **Mixed audience appeal**: Nie

### News app
- **No** (to gra, nie aplikacja newsowa)

### COVID-19 contact tracing
- **No**

### Data safety
Wypełnij zgodnie z **`PLAY_CONSOLE_DATA_SAFETY.md`** (na razie wszystko "no — nic nie zbieramy").

### Government apps
- **No**

### Financial features
- **No** (gra)

### Health
- **No**

## 3. Main store listing

### Polish (default)
Z pliku **`store/listing_pl.md`**:

**App name**: `Gem Rush Saga` (max 30 chars)
**Short description** (max 80): "Łącz klejnoty, twórz spektakularne kaskady i odkryj 300 poziomów przygody!"
**Full description** (4000): patrz pełny tekst w `store/listing_pl.md`

### Graphics

| Asset | Plik | Rozmiar |
|---|---|---|
| **App icon** | `app/assets/branding/icon_512.png` | 512×512 PNG |
| **Feature graphic** | `app/assets/branding/feature_1024x500.png` | 1024×500 PNG |
| **Phone screenshots** | (zrób z telefonu, min 2) | 16:9 lub 9:16 |
| **Tablet screenshots** | opcjonalne | - |
| **App preview video** | opcjonalne | YouTube link |

### Categorization
- **App category**: Games → **Puzzle**
- **Tags**: dodaj 5 tagów: match-3, puzzle, brain, casual, jewels

## 4. Pricing & distribution

- **Free**
- Countries: Polska na start (potem ewentualnie EU/global)
- **Contains ads**: NO (obecnie)
- **In-app products**: NIE (obecnie)

## 5. Internal Testing track

Po wypełnieniu wszystkich powyższych sekcji:

1. **Testing → Internal testing → Create new release**
2. **Upload App bundle**: `app/build/app/outputs/bundle/release/app-release.aab`
3. **Release name**: `1.0.0 (build 2)`
4. **Release notes** (PL):
   ```
   Pierwsza wersja Gem Rush Saga!
   - 300 ręcznie zaprojektowanych poziomów
   - 17 magicznych światów
   - 14 osiągnięć
   - Codzienne wyzwania i questy
   - Tryb dla daltonistów
   ```
5. **Save** → **Review release** → **Start rollout to Internal testing**

### Internal Testing setup

- **Internal testing → Testers** → dodaj listę emaili (do 100 osób)
- Po publikacji wyśle invitation link
- Testerzy instalują z linka (Play Store oznacza jako "Internal test")

## 6. Hostowanie Privacy Policy

Privacy Policy jest w **`docs/index.md`** w repo. Włącz GitHub Pages:

1. **github.com/jakatora/gemrush** → **Settings → Pages**
2. **Source**: `Deploy from a branch`
3. **Branch**: `main`, folder `/docs`
4. **Save**
5. Po ~1 min URL: **`https://jakatora.github.io/gemrush/`**
6. Wstaw ten URL w Play Console → App content → Privacy Policy

## 7. Po Internal Testing — Closed → Production

Gdy Internal Testing przejdzie OK (kilku testerów potwierdza że gra działa):

1. **Closed testing → Create release** → kopiuj AAB z Internal
2. Dodaj **Track name**: `Closed Beta`, dodaj większą grupę testerów (do 1000)
3. Po feedbacku → **Production → Create release**
4. Apple-style review (Google szybsza: zazwyczaj 1-7 dni)
5. Po approve → gra w sklepie

## 8. App signing

Twój keystore: **`app/upload-keystore.jks`** (gitignored)
- Alias: **`upload`**
- Password: **`GemRush2026!`** (zmień jeśli chcesz, ale zapisz!)

⚠️ **NIGDY nie commituj keystore'a**. Jest w `.gitignore`. Trzymaj backup w bezpiecznym miejscu (bez tego pliku stracisz możliwość uploadu kolejnych buildów).

Po pierwszym uploadzie Google włączy **Play App Signing**:
- Twój keystore = **upload key**
- Google generuje osobny **app signing key** w chmurze
- Wszystkie przyszłe buildy podpisujesz upload key, Google re-signuje app signing key

## 9. Build number per kolejny upload

Każdy nowy AAB musi mieć WYŻSZY `versionCode` niż poprzedni. W pubspec:
```yaml
version: 1.0.0+2  # 1.0.0 = versionName, +2 = versionCode
```

Po opublikowaniu wersji 1.0.0+2, kolejny build:
```yaml
version: 1.0.0+3  # poprawka bugu, ten sam versionName
# albo
version: 1.0.1+3  # patch
# albo
version: 1.1.0+4  # minor (np. dodanie AdMob z powrotem)
```

## 10. Co RAZ-EM ze mną pójdzie do production (długoterminowo)

Te elementy NIE są w pierwszym Internal build, ale dodamy w kolejnych:

- **AdMob** ↩️ przywrócić plugin + prod IDs (gdy zarejestrujesz w AdMob)
- **In-app purchases** ↩️ utwór produkty w Play Console + przywróć plugin
- **Firebase** ↩️ Analytics + Crashlytics
- **Pełne screenshoty** wysokiej jakości
- **Promo video** 30s
- **Lokalizacja EN** (i opcjonalnie DE/ES/FR)
