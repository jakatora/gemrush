# Google Play — Data Safety Declaration

> Wypełniany w Play Console → All apps → Gem Rush Saga → App content → Data safety.
> Status aplikacji **WERSJA 1.0.0+2** (po usunięciu AdMob + IAP).

## Data collection & sharing

**Does your app collect or share any of the required user data types?**
→ **No**

Po usunięciu `google_mobile_ads` i `in_app_purchase` aplikacja **nie zbiera ani nie udostępnia** żadnych danych użytkownika.

## Data security

**Is all of the user data collected by your app encrypted in transit?**
→ **N/A** (nic nie zbieramy)

**Do you provide a way for users to request that their data be deleted?**
→ **Yes** — odinstalowanie aplikacji usuwa wszystkie dane lokalne (Hive).

## Data types — pełna deklaracja "no"

Wszystkie kategorie poniżej zaznacz **NIE zbieramy**:

| Kategoria | Status |
|---|---|
| Location (Approximate/Precise) | NIE |
| Personal info (Name, Email, User IDs, Address, Phone) | NIE |
| Financial info (Payments, Purchase history) | NIE |
| Health & fitness | NIE |
| Messages | NIE |
| Photos & videos | NIE |
| Audio | NIE |
| Files & docs | NIE |
| Calendar | NIE |
| Contacts | NIE |
| App activity (interactions, search history, downloads) | NIE |
| Web browsing | NIE |
| App info & performance (Crash logs, Diagnostics, Other) | NIE |
| Device or other IDs | NIE |

Note: gdy w przyszłości dodamy AdMob + Firebase Analytics, zaktualizuj formularz:

- **App activity → Other actions** = TAK (pogląd o eventach gameplay)
- **App info & performance → Crash logs + Diagnostics** = TAK
- **Device or other IDs** = TAK (IDFA/AAID dla reklam)

## Permissions deklarowane w manifest

Tylko:
- `android.permission.INTERNET` — zarezerwowane, obecnie nieużywane runtime
- `android.permission.ACCESS_NETWORK_STATE` — sprawdzanie sieci

**Nie** wymagamy: location, camera, microphone, storage, contacts, sensors.
