# 12 · Checklist przed publikacją

## Tech
- [ ] Wersja `pubspec.yaml` bumped (1.0.0+1)
- [ ] Debug logi wyłączone w prod (`kReleaseMode` guard)
- [ ] Wszystkie `print()` zamienione na proper logger albo usunięte
- [ ] Brak hardcoded URLi/tokenów (wszystko w `.env` / `--dart-define`)
- [ ] Prod build sygnowany właściwym keystorem (Android) / cert (iOS)
- [ ] AAB / IPA mniejsze niż 100 MB (sprawdź `flutter build appbundle --analyze-size`)
- [ ] Cold start < 3 s na realnym Android (test na średnim urządzeniu)
- [ ] 60 FPS na średnim Android podczas gameplay
- [ ] Brak memory leaków przez 30 min ciągłej gry

## Reklamy
- [ ] Production AdMob App ID w `AndroidManifest.xml`
- [ ] Production AdMob App ID w `Info.plist`
- [ ] Production Ad Unit IDs w `.env` (NIE test IDs!)
- [ ] UMP consent flow działa w UE (test z VPN)
- [ ] iOS ATT prompt pojawia się raz, przed pierwszą reklamą
- [ ] `SKAdNetworkItems` complete w `Info.plist`
- [ ] Frequency capping respektowany (90s cooldown, 2 levels between)
- [ ] `remove_ads` purchase rzeczywiście wyłącza interstitial (test sandbox)
- [ ] Rewarded callback poprawnie przyznaje nagrodę (test każdego placementu)
- [ ] Wszystkie placementy mają `ad_request`, `ad_loaded`, `ad_shown`, `ad_failed` logowanie

## IAP
- [ ] Wszystkie 8 produktów dodane w Google Play Console
- [ ] Wszystkie 8 produktów dodane w App Store Connect
- [ ] Każdy produkt przeszedł review w App Store (status: "Ready to Submit" lub "Approved")
- [ ] Sandbox test: kupno każdego produktu kończy się sukcesem
- [ ] Restore Purchases przywraca `remove_ads` na nowym urządzeniu
- [ ] Consumable produkty (coins) po kupnie znikają z koszyka (consume call)
- [ ] Receipt validation działa (na MVP lokalna, post-launch backend)

## GDPR / Privacy
- [ ] Privacy Policy URL działa (HTTP 200, nie 404)
- [ ] Privacy Policy zawiera wszystkie wymagane sekcje (lista w doc 11)
- [ ] Terms of Service URL działa
- [ ] App nie zbiera danych do których nie ma zadeklarowanego zgodnie z Data Safety / App Privacy
- [ ] User może zmienić consent w Settings ("Privacy options")
- [ ] User może zażądać usunięcia danych (link do email contact)

## Gameplay
- [ ] Wszystkie 100 poziomów playtested przynajmniej 3 razy
- [ ] Każdy poziom rozwiązywalny w deklarowanej liczbie ruchów (idealnym grze)
- [ ] Pass rate per poziom mieści się w deklarowanej krzywej trudności (doc 03)
- [ ] Brak deadlocków — shuffle działa przy braku ruchów
- [ ] Win/Lose dialogi działają poprawnie
- [ ] Star thresholds osiągalne (2★ i 3★, nie tylko 1★)
- [ ] Wszystkie boostery działają (pre-game + in-game)
- [ ] System 5 żyć z regeneracją 30 min — działa offline (timer)
- [ ] Save state przeżywa zamknięcie i restart aplikacji

## Audio / Visual
- [ ] Wszystkie sprite assety obecne (brak różowych kwadratów)
- [ ] Wszystkie SFX odgrywają się
- [ ] Muzyka tła loopuje bez pauzy
- [ ] Mute toggle wyłącza całe audio
- [ ] Animacje płynne (60 FPS, brak jitterów)
- [ ] Haptic feedback działa na obu platformach
- [ ] Brak placeholderów typu "lorem ipsum"

## Lokalizacja
- [ ] PL wszystkie stringi (UI, dialogi, store listing)
- [ ] EN wszystkie stringi (jeśli launch global)
- [ ] Daty/liczby formatowane lokalnie (`intl`)
- [ ] Waluta IAP wyświetlana lokalnie (Google/Apple robi auto)

## Store assets
**Google Play**:
- [ ] App icon 512×512 PNG (transparent OK)
- [ ] Feature graphic 1024×500 PNG (bez tekstu w skrajach)
- [ ] Phone screenshots 8 sztuk (min 2)
- [ ] Tablet screenshots (opcjonalne)
- [ ] Promo video (opcjonalne, ale +konwersja)
- [ ] Krótki opis (80 chars)
- [ ] Pełny opis (4000 chars, z keywords ASO)
- [ ] Pełna lista tagów

**App Store**:
- [ ] App icon 1024×1024 PNG (bez transparency!)
- [ ] iPhone 6.7" screenshots min 3
- [ ] iPhone 6.5" screenshots min 3
- [ ] iPhone 5.5" screenshots min 3
- [ ] App Preview video (opcjonalne)
- [ ] Subtitle (30 chars)
- [ ] Keywords (100 chars)
- [ ] Description (4000 chars)
- [ ] Promotional Text (170 chars)

## Analytics / Monitoring
- [ ] Firebase Analytics events: `level_start`, `level_complete`, `level_fail`, `iap_purchase`, `ad_shown`, `ad_clicked`
- [ ] Crashlytics zintegrowany, test crash zarejestrowany
- [ ] Remote Config defaults skonfigurowane (`interstitial_cooldown_seconds`, etc.)
- [ ] A/B test experiment utworzony (ad frequency)
- [ ] DebugView Analytics pokazuje eventy w realtime

## Klasyfikacja wiekowa
- [ ] Google Play: IARC questionnaire passed, rating PEGI 3 / ESRB E
- [ ] App Store: Age Rating questionnaire passed, rating 4+

## Compatibility
- [ ] Test na Android 5.0 (min SDK)
- [ ] Test na Android 14 (target SDK)
- [ ] Test na iOS 12 (min iOS)
- [ ] Test na iOS 17 (target iOS)
- [ ] Test na małym ekranie (iPhone SE, 320×568)
- [ ] Test na dużym ekranie (iPad Pro 12.9")
- [ ] Test w landscape (jeśli supportujesz)
- [ ] Test offline (graceful degradation, brak crashy)
- [ ] Test z VPN przez UE (UMP consent)

## Final review
- [ ] Wszystkie powyższe checklisty zhakowane
- [ ] Build manualnie zainstalowany na 3+ urządzeniach i przegrany od 1 do 10 poziomu
- [ ] Nikt z zespołu / testerów nie złosił krytycznego buga w ciągu 48h
- [ ] Plan komunikacji po launchu (social media post, ASO update plan)
- [ ] Crashlytics dashboard otwarty w dniu launchu (monitoring)

## Po publikacji (Day 1-7)
- [ ] Sprawdź wszystkie analytics events spływają
- [ ] Sprawdź eCPM i fill rate
- [ ] Sprawdź D1 retention (cel >30%)
- [ ] Reaguj na recenzje (odpowiadaj na 1-stars)
- [ ] Przygotuj pierwszy hotfix release (jeśli wymagany)
