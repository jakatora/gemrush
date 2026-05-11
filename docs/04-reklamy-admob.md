# 04 · Reklamy AdMob — pełna konfiguracja

> **Dokument krytyczny dla monetyzacji.** Czytaj zanim zaczniesz integrację.

## Konto i jednostki reklamowe

### Krok 1: Konto AdMob
1. Załóż konto na https://admob.google.com (wymaga konta Google + AdSense)
2. Dodaj **aplikację Android** (placeholder package: `com.gemrush.game`)
3. Dodaj **aplikację iOS** (bundle: `com.gemrush.game`)
4. Skopiuj **App ID** dla Android: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
5. Skopiuj **App ID** dla iOS

### Krok 2: Jednostki reklamowe (Ad Units)
Utwórz dla każdej platformy:

| Typ | Nazwa | Użycie |
|---|---|---|
| Interstitial | `inter_post_level` | Po wygranym/przegranym poziomie |
| Rewarded | `reward_extra_life` | "Obejrzyj reklamę za życie" |
| Rewarded | `reward_extra_moves` | "+5 ruchów" |
| Rewarded | `reward_hint` | "Pokaż podpowiedź" |
| Rewarded | `reward_double_coins` | "Podwój nagrodę za poziom" |
| Banner (opc.) | `banner_menu` | Dolny banner w menu (rozważyć) |
| App Open (opc.) | `app_open_cold` | Cold start (po pierwszej sesji) |

### Test IDs (używaj w developmencie!)
```
Android Interstitial: ca-app-pub-3940256099942544/1033173712
Android Rewarded:     ca-app-pub-3940256099942544/5224354917
Android Banner:       ca-app-pub-3940256099942544/6300978111
iOS Interstitial:     ca-app-pub-3940256099942544/4411468910
iOS Rewarded:         ca-app-pub-3940256099942544/1712485313
iOS Banner:           ca-app-pub-3940256099942544/2934735716
```
**Production IDs idą wyłącznie przez `.env` / Remote Config / dart-define — NIGDY zahardkodowane w kodzie commitowanym do gita.**

## Konfiguracja platformy

### Android — `android/app/src/main/AndroidManifest.xml`
```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
  </application>
</manifest>
```

### iOS — `ios/Runner/Info.plist`
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

<key>SKAdNetworkItems</key>
<array>
  <!-- 50+ pozycji SKAdNetworkIdentifier z dokumentacji AdMob -->
</array>

<key>NSUserTrackingUsageDescription</key>
<string>Pozwól nam dostarczać trafniejsze reklamy, dzięki czemu możemy utrzymać darmową grę.</string>
```
**SKAdNetworkItems**: pełna lista (60+ pozycji) z https://developers.google.com/admob/ios/quick-start

## Pakiet Flutter
```yaml
dependencies:
  google_mobile_ads: ^5.1.0
```

## AdsService — architektura

```dart
// lib/core/services/ads_service.dart  (szkic, NIE implementacja)
class AdsService {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  DateTime? _lastInterstitialAt;
  int _levelsSinceLastInterstitial = 0;
  bool removeAdsPurchased = false;

  Future<void> init();
  Future<void> preloadInterstitial();
  Future<void> preloadRewarded(String placement);

  /// Wywoływane po zakończeniu poziomu.
  /// Zwraca true jeśli reklama została pokazana.
  Future<bool> maybeShowInterstitial({required String placement});

  /// placement: 'extra_life' | 'extra_moves' | 'hint' | 'double_coins'
  Future<RewardedResult> showRewarded(String placement);
}
```

## Reguły pokazywania **Interstitial**
1. **Nie pokazuj** jeśli `removeAdsPurchased == true`
2. **Nie pokazuj** w pierwszych 3 poziomach gry (pierwsze wrażenie)
3. **Cooldown**: minimum **90 sekund** między dwoma interstitialami
4. **Cadence**: co **2 poziomy** (ale nie częściej niż cooldown pozwala)
5. **Nie pokazuj** bezpośrednio po starcie aplikacji (najpierw min. 1 gameplay)
6. **Preload** kolejny natychmiast po pokazaniu

Pseudokod:
```
onLevelEnd():
  _levelsSinceLastInterstitial += 1
  if removeAdsPurchased: return
  if currentLevel < 4: return
  if (now - _lastInterstitialAt) < 90s: return
  if _levelsSinceLastInterstitial < 2: return
  showInterstitial()
  _lastInterstitialAt = now
  _levelsSinceLastInterstitial = 0
  preloadNext()
```

## Reguły **Rewarded**
- Zawsze user-triggered (przycisk z ikoną video)
- Pokaż dialog potwierdzenia: "Obejrzyj reklamę (~30s), aby otrzymać X"
- Nagroda **tylko** gdy callback `onUserEarnedReward` zwróci sukces
- Dziennie max **5 rewardów na jednego użytkownika** per placement (anti-fraud)
- Preload przed pokazaniem ekranu, gdzie przycisk jest widoczny

## GDPR Consent (UMP SDK)
**Wymóg prawny UE** — bez consenta nie wolno serwować spersonalizowanych reklam.

```yaml
dependencies:
  google_mobile_ads: ^5.1.0  # zawiera UMP
```

Flow przy pierwszym uruchomieniu:
1. `ConsentInformation.instance.requestConsentInfoUpdate(...)`
2. Jeśli `isConsentFormAvailable()` → `loadAndShowConsentFormIfRequired()`
3. Po consent → `MobileAds.instance.initialize()`
4. Settings: ekran "Privacy options" — pozwala zmienić consent (`showPrivacyOptionsForm`)

## iOS ATT (App Tracking Transparency)
Pokaż **po** consent formularzu UMP, **przed** `MobileAds.initialize()`:
```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// w runtime tylko iOS:
final status = await AppTrackingTransparency.requestTrackingAuthorization();
```

## COPPA / Family
Gra ma być **dla wszystkich (3+)** — w AdMob ustaw:
- `TagForChildDirectedTreatment = false` (gra nie jest skierowana wyłącznie do dzieci)
- `TagForUnderAgeOfConsent = false`
- W Google Play Console: target audience 13+

## Frequency capping przez Remote Config
Steruj bez update'u aplikacji:
```json
{
  "interstitial_cooldown_seconds": 90,
  "interstitial_levels_between": 2,
  "interstitial_first_level_allowed": 4,
  "rewarded_daily_cap": 5
}
```

## A/B testing
- Wariant A: interstitial co 2 poziomy
- Wariant B: interstitial co 3 poziomy
- Wariant C: interstitial co 2 + banner w menu
- Cel: maksymalizować **ARPDAU** przy retencji D1/D7 nie gorszej o >5%

## Monitoring i KPI
Tabela w analytics:
| Metryka | Cel post-launch |
|---|---|
| Fill rate (interstitial) | > 95% |
| Show rate / requests | > 90% |
| eCPM (interstitial) | $5–15 (PL ~$2–5, US ~$10–20) |
| eCPM (rewarded) | $15–30 |
| Reward completion rate | > 70% |
| Ad ARPDAU | $0.05–0.15 |

## Eventy do logowania (Firebase Analytics)
```
ad_request          { ad_type, placement }
ad_loaded           { ad_type, placement, load_time_ms }
ad_failed           { ad_type, placement, error_code }
ad_shown            { ad_type, placement }
ad_clicked          { ad_type, placement }
ad_revenue          { ad_type, value, currency }  // gdy dostępne
rewarded_completed  { placement, reward_amount }
rewarded_skipped    { placement }
```

## Checklist przed produkcją
- [ ] Production App IDs w `AndroidManifest.xml` i `Info.plist`
- [ ] Production Ad Unit IDs w `.env` (NIE w kodzie commitowanym)
- [ ] Test IDs usunięte z prod buildu
- [ ] UMP consent działa w UE
- [ ] iOS ATT prompt pojawia się raz, przed pierwszą reklamą
- [ ] `SKAdNetworkItems` w Info.plist (pełna lista)
- [ ] Privacy Policy URL zawiera AdMob disclosure
- [ ] AdMob konto połączone z bankiem (płatności)
- [ ] Ad Mediation skonfigurowane (opcjonalnie)
- [ ] Test na realnym urządzeniu (Android + iOS), nie emulator
- [ ] Test na trybie samolotowym → graceful degradation (brak crashy)
