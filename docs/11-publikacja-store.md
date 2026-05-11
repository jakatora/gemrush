# 11 · Publikacja w sklepach

## Google Play

### Wymagania konta
- **Google Play Developer Account**: $25 (jednorazowo)
- Weryfikacja tożsamości (paszport / dowód) — może zająć kilka dni
- Konto bankowe + rejestracja podatkowa dla Merchant Account (IAP)

### Tworzenie aplikacji
1. https://play.google.com/console → "Create app"
2. Nazwa: "GemRush" (lub finalna)
3. Default language: Polish (lub English)
4. Type: Game
5. Free/Paid: Free (z IAP)

### Wymagane sekcje przed publikacją
- [ ] **App Content**:
  - Privacy Policy URL (wymagane jeśli używasz reklam/IAP)
  - Ads declaration: "Yes, app contains ads"
  - App access: "All functionality available without restrictions"
  - Content rating: pass questionnaire IARC → uzyskaj rating (Match-3 = PEGI 3 / ESRB E)
  - Target audience: 13+ (nie targetuj dzieci poniżej 13, inaczej polityka rodziny)
  - News app: No
  - COVID-19: No
  - Data safety: zadeklaruj zbieranie (Device ID, Approximate location przez AdMob, Diagnostics przez Crashlytics)
  - Financial features: No (chyba że pełna giełda)
  - Government apps: No
- [ ] **Main store listing** (PL):
  - App name (30 chars)
  - Short description (80 chars)
  - Full description (4000 chars) — opisz mechanikę, poziomy, świat
  - App icon: 512×512 PNG
  - Feature graphic: 1024×500 PNG (BEZ tekstu w środku — kawałki ucinane na różnych ekranach)
  - Phone screenshots: 2-8 sztuk, JPEG/PNG, 16:9 lub 9:16
  - 7-inch tablet screenshots (opcjonalne)
  - 10-inch tablet screenshots (opcjonalne)
  - Video (opcjonalne ale +konwersja) — YouTube link, 30s
- [ ] **Store listing** (EN) — drugi język dla globalnego launch
- [ ] **Pricing & distribution**:
  - Free
  - Kraje: początkowo Polska (soft launch), potem global
- [ ] **In-app products**: zdefiniuj wszystkie 8 produktów z doc 05
- [ ] **App releases**:
  - Internal testing track → Closed testing → Open/Production
  - AAB upload (App Bundle, nie APK!)
  - Release notes per build

### Polityki Google Play do przestrzegania
- **Families Policy** (jeśli targetujesz dzieci) — my targetujemy 13+, więc nie wchodzimy w tę kategorię
- **Ads Policy**: brak ads na ekranach loading, brak ads zakrywających UI gry, brak reklam alkohol/hazard
- **In-app purchases**: muszą używać Google Play Billing (Apple's IAP na iOS)
- **Data Safety**: wymagana deklaracja zgodna z rzeczywistym zbieraniem
- **Target API**: musi być max 1 rok wstecz (na 2026 — API 34)

## App Store (iOS)

### Wymagania konta
- **Apple Developer Program**: $99/rok
- Apple ID + weryfikacja
- D-U-N-S number (firma) lub osobiście (Individual)
- Bank account dla Paid Apps Agreement (IAP)

### App Store Connect
1. https://appstoreconnect.apple.com → My Apps → New App
2. Bundle ID: `com.gemrush.game` (zarejestrowany w Developer Portal)
3. SKU: `GEMRUSH001`
4. Primary language: Polish (lub English)

### Wymagane sekcje
- [ ] **App Information**:
  - Name
  - Subtitle (30 chars)
  - Privacy Policy URL
  - Category: Games > Puzzle
- [ ] **Pricing**: Free
- [ ] **App Privacy** (App Privacy Manifest):
  - Data Used to Track You: Device ID, User Identifiers (AdMob)
  - Data Linked to You: Purchase History, Identifiers
  - Data Not Linked to You: Diagnostics, Usage Data
- [ ] **Version Information**:
  - Description (4000 chars)
  - Keywords (100 chars, oddzielone przecinkami)
  - Support URL
  - Marketing URL (opcjonalne)
  - Screenshots:
    - 6.7" (iPhone 15 Pro Max): 1290×2796 — wymagane, min 3
    - 6.5" (iPhone 11 Pro Max): 1242×2688 — wymagane, min 3
    - 5.5" (iPhone 8 Plus): 1242×2208 — wymagane, min 3
    - 12.9" iPad Pro: 2048×2732 — jeśli supportujesz iPad
    - 13" iPad Pro M4: 2064×2752
  - App Previews (video, opcjonalne, max 30s)
  - Promotional Text (170 chars, zmieniane bez review)
- [ ] **Age Rating**: questionnaire → 4+ (match-3 nie ma przemocy/etc.)
- [ ] **App Review Information**:
  - Demo account (jeśli wymagany)
  - Notes for reviewer
  - Contact info
- [ ] **In-App Purchases**: każdy produkt = osobne entry, każde przechodzi review (~24h)

### iOS-specific compliance
- **App Tracking Transparency (ATT)**: prompt + `NSUserTrackingUsageDescription` w Info.plist — wymagane przed użyciem IDFA
- **SKAdNetwork**: pełna lista 60+ identyfikatorów w Info.plist
- **App Privacy Manifest** (`PrivacyInfo.xcprivacy`): od iOS 17+ wymagane — deklaracja `NSPrivacyAccessedAPITypes`, `NSPrivacyTracking`, etc.
- **Symbol upload** (.dSYM) dla Crashlytics

### Apple Review — typowe powody odrzuceń
- Crash przy starcie (testuj na realnym urządzeniu!)
- Privacy policy URL niedziała / 404
- Brak Restore Purchases buttona (wymagane przy IAP non-consumable)
- IAP nie używa Apple's billing (np. własny PayPal — odrzucone)
- Zbieranie danych nieujawnione w nutrition labels
- Reklamy zakrywające zamknij-button
- "Spam" / klon znanej gry (zwróć uwagę na nazwę i ikonę — nie kopiuj Candy Crush!)

## Soft launch strategy
1. **Polska only** (tydzień 12)
2. Monitor 7 dni:
   - Crash-free > 99%
   - D1 retention > 30%
   - Brak negatywnych recenzji o reklamach (sprawdź czy frequency capping dobry)
3. Jeśli OK → dodaj CZ, SK, HU (tydzień 13)
4. Jeśli nadal OK → rozszerz na DE, FR, ES (tydzień 14)
5. Global launch (tydzień 15+) — wymaga przygotowania ASO w lokalnych językach

## Privacy Policy — wymagane sekcje
Hostuj na własnej domenie lub Notion public page. Wymagane:
1. Kto jest administratorem danych (Ty / firma)
2. Jakie dane zbieramy (technical: device ID, OS, language; ads: IDFA/AAID; analytics: events; IAP: purchase)
3. Dlaczego (analityka, personalizacja reklam, rozliczenia)
4. Z kim dzielimy (Google AdMob, Firebase, Google/Apple billing)
5. Prawa użytkownika (RODO: dostęp, sprostowanie, usunięcie, przeniesienie)
6. Cookies / tracking (IDFA opt-out, AAID reset)
7. Wiek minimalny (13+)
8. Kontakt do administratora (email)
9. Data ostatniej aktualizacji
