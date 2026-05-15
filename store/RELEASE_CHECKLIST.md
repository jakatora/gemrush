# Release Checklist — GemRush

> **TY robisz** wszystkie kroki ❌. Ja (Claude) **nie mam dostępu** do
> Twoich kont w Apple/Google/AdMob/Firebase — wymagają osobistych
> credentiali. Po każdym kroku napisz mi, że gotowe, dorzucę co trzeba
> w kodzie.

---

## A. KONTA I PŁATNOŚCI (~150-200 USD jednorazowo)

- [ ] **Apple Developer Program** — $99/rok
      https://developer.apple.com/programs
      ⏱️ weryfikacja tożsamości może zająć 1-7 dni, kup wcześniej!
- [ ] **Google Play Console** — $25 jednorazowo
      https://play.google.com/console/signup
- [ ] **AdMob konto** — darmowe
      https://admob.google.com → Sign up
- [ ] **Firebase projekt** — darmowy plan Spark
      https://console.firebase.google.com → Add project
- [ ] **Codemagic** — darmowe 500 min/miesiąc (wystarczy na początek)
      https://codemagic.io → Sign up GitHub

## B. HOSTING PRIVACY POLICY (wymagany URL publiczny)

Privacy Policy jest w `store/PRIVACY_POLICY.md`. Hostuj gdzie chcesz:

**Opcja 1 (najprościej): Notion public page**
- Załóż notion.so
- Wklej zawartość PRIVACY_POLICY.md jako stronę
- Share → "Publish to web" → kopiuj URL

**Opcja 2: GitHub Pages**
- W tym samym repo: utwórz folder `docs/`
- Wrzuć `index.md` z zawartością privacy policy
- Settings → Pages → enable
- URL: `https://jakatora.github.io/gemrush/`

URL trzymaj — będzie potrzebny w obu sklepach.

- [ ] Hostuję Privacy Policy: ___________________ (URL)

## C. APP STORE CONNECT (iOS)

1. **App Store Connect → My Apps → "+"**
   - Platforms: iOS
   - Name: **GemRush**
   - Primary Language: Polish
   - Bundle ID: **com.gemrush.gemrush** (musisz najpierw zarejestrować
     w Developer Portal → Certificates, Identifiers & Profiles → +)
   - SKU: **GEMRUSH001**

2. **Skopiuj numeryczne Apple ID aplikacji** (~10 cyfr, widoczne w
   App Information). Wstaw je w `codemagic.yaml` → `APP_STORE_APP_ID`.

3. **App Information → App Privacy:**
   - Privacy Policy URL: [z punktu B]
   - Data Collection:
     - Identifiers → Device ID → Tracking
     - Usage Data → Product Interaction (anonimowe)
     - Diagnostics → Crash Data + Performance Data (anonimowe)

4. **App Store Connect API Key:**
   - Users and Access → Integrations → "App Store Connect API"
   - Generate key, rola: **App Manager** (minimum)
   - Pobierz `.p8`, zapisz **Key ID** + **Issuer ID**

5. **W Codemagic:**
   - Teams → Integrations → "App Store Connect"
   - Wklej `.p8`, Key ID, Issuer ID
   - Nazwa integracji: **`codemagic_app_store`** (tak jest w yaml,
     jak inna nazwa — powiedz mi, zaktualizuję)

6. **Produkty IAP** (osobny review każdego, ~24-48h):
   - `remove_ads` — Non-Consumable — 14.99 PLN
   - `coins_100` — Consumable — 4.99 PLN
   - `coins_500` — Consumable — 19.99 PLN
   - `coins_1200` — Consumable — 39.99 PLN
   - `coins_3000` — Consumable — 79.99 PLN
   - `starter_pack` — Non-Consumable — 9.99 PLN
   - `weekend_pack` — Consumable — 14.99 PLN
   - `unlimited_lives_24h` — Consumable — 9.99 PLN

7. **Screenshots** (musisz wziąć na realnym iPhone):
   - 6.7" (1290×2796) — min 3
   - 6.5" (1242×2688) — min 3
   - 5.5" (1242×2208) — min 3
   - Idea: menu, mapa świata, plansza w trakcie matcha, win dialog,
     osiągnięcia

8. **App Information / Version 1.0:**
   - Skopiuj z `store/listing_pl.md` (name, subtitle, opis, keywords)
   - Age Rating: 4+ (przejdź questionnaire)

## D. GOOGLE PLAY CONSOLE (Android)

1. **Google Play Console → Create app**
   - App name: **GemRush**
   - Default language: Polski (Polska)
   - Type: Game
   - Free / Paid: Free

2. **App content:**
   - Privacy Policy URL: [z B]
   - Ads declaration: **Yes**, contains ads
   - Target audience: 13+
   - Content rating: pass IARC questionnaire → PEGI 3
   - Data Safety: zadeklaruj (Device ID, Approximate location przez
     AdMob, Diagnostics przez Crashlytics)

3. **Main store listing** (PL):
   - Z `store/listing_pl.md`
   - **App icon**: `app/assets/branding/icon_1024.png`
     (przekonwertuj na 512×512 jeśli wymagane — Play akceptuje 512)
   - **Feature graphic**: `app/assets/branding/feature_1024x500.png`
   - **Phone screenshots**: min 2 (też z realnego telefonu)

4. **Pricing & distribution:**
   - Free, kraje: Polska + EU (na start)

5. **In-app products** — utwórz te same 8 SKU co w App Store
   (Google nie wymaga osobnego review jak Apple)

6. **App Bundle:**
   - Build AAB w Codemagic (workflow `android-internal`) lub lokalnie:
     `cd app && flutter build appbundle --release`
   - Upload do "Internal testing track" → potem "Closed testing" →
     potem "Production"

## E. ADMOB — produkcyjne ID

1. **AdMob console → Apps → Add app**
   - Wybierz "Yes, my app is published" (najpierw musi być w sklepie!)
     LUB "No" — jeśli jeszcze nie opublikowane (wybierz to teraz)
   - Nazwa: GemRush, platforma: Android / iOS (osobno)
   - Po opublikowaniu w sklepie połącz z prawdziwym ID

2. **Stwórz Ad Units:**
   - Interstitial: `inter_post_level`
   - Rewarded × 4: `reward_extra_life`, `reward_extra_moves`,
     `reward_hint`, `reward_double_coins`
   - Banner (opcjonalnie): `banner_menu`

3. **Skopiuj IDs** i wstaw w `app/.env`:
   ```
   ADMOB_APP_ID_ANDROID=ca-app-pub-XXX~YYY
   ADMOB_APP_ID_IOS=ca-app-pub-XXX~ZZZ
   ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-XXX/AAA
   ADMOB_INTERSTITIAL_IOS=ca-app-pub-XXX/BBB
   ADMOB_REWARDED_ANDROID=ca-app-pub-XXX/CCC
   ADMOB_REWARDED_IOS=ca-app-pub-XXX/DDD
   ```

4. **Zaktualizuj `AndroidManifest.xml` i `Info.plist`** z prod IDs
   (powiedz mi gdy będziesz miał — podstawię).

## F. FIREBASE (analytics + crashlytics)

```bash
# Na Twojej maszynie:
dart pub global activate flutterfire_cli
cd c:\Users\Startklaar\Documents\gem-rush-game\app
flutterfire configure
```

Wybierz utworzony projekt → automatycznie wygeneruje:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

W Firebase Console włącz Analytics + Crashlytics + Remote Config.

Powiedz mi gdy zrobione — zastąpię `analytics_service.dart` stub realnym
`FirebaseAnalytics`.

## G. CO ROBIĘ JA (po Twoich akcjach)

Gdy ukończysz powyższe, daj znać które fragmenty są zrobione. Wtedy:
- [ ] Podstawiam produkcyjne AdMob ID
- [ ] Podłączam realny Firebase Analytics + Crashlytics
- [ ] Aktualizuję `codemagic.yaml` z prawdziwym `APP_STORE_APP_ID`
- [ ] Bumping version w `pubspec.yaml` (1.0.0+1 → 1.0.0+2 etc.)
- [ ] Push do main → Codemagic auto-build → TestFlight

## H. KOLEJNOŚĆ DZIAŁAŃ (rekomendacja)

1. ✅ Google Play (Android) — szybciej i taniej, można w 100% z Windows
2. Apple Developer Program — kup TERAZ (1-7 dni weryfikacji)
3. Hostuj Privacy Policy → URL
4. AdMob account + ad units
5. Firebase configure
6. Daj mi URL Privacy + AdMob IDs → wstawiam do kodu
7. Build AAB → Google Play Internal Testing → test → Closed → Production
8. Po weryfikacji Apple Developer: App Store Connect setup
9. Codemagic API key → workflow ios-testflight → TestFlight beta
10. Soft launch w Polsce, monitor metryki, potem global

## I. KOSZTY ŁĄCZNE

| Pozycja | Koszt | Częstotliwość |
|---|---|---|
| Apple Developer | $99 | rocznie |
| Google Play | $25 | jednorazowo |
| AdMob | $0 | — |
| Firebase Spark | $0 | — |
| Codemagic | $0 (500 min/mc) | — |
| **Razem rok 1** | **~$124** | |

Plus opcjonalnie: hosting Privacy Policy (Notion / GitHub Pages = $0).
