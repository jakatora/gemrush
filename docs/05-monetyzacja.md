# 05 · Monetyzacja — ads + IAP

## Filozofia
- **Free-to-play, ad-supported**.
- Reklamy = **70-80%** przychodu (interstitial co 2 poziomy, rewarded dla zaangażowanych).
- IAP = **20-30%** przychodu (gracze, którzy chcą szybciej / bez reklam).
- Nigdy "pay-to-win" — IAP daje wygodę i ozdoby, nie blokuje progresu.

## Produkty IAP

| Produkt ID | Cena PLN | Typ | Zawartość |
|---|---|---|---|
| `remove_ads` | 14,99 | non-consumable | Wyłącza interstitial i banner. Rewarded zostaje (gracz wybiera). |
| `coins_100` | 4,99 | consumable | 100 monet |
| `coins_500` | 19,99 | consumable | 500 + 100 bonus (600) |
| `coins_1200` | 39,99 | consumable | 1200 + 400 bonus (1600) |
| `coins_3000` | 79,99 | consumable | 3000 + 1500 bonus (4500) |
| `starter_pack` | 9,99 | non-consumable (1-time) | 200 monet + 10 życ + 3 boostery |
| `weekend_pack` | 14,99 | consumable | Limit czasowy (48h) — 500 monet + unlim. życia 24h |
| `unlimited_lives_24h` | 9,99 | consumable | 24h bez limitu żyć |

## Ekonomia monet

### Zarabianie
- Ukończenie poziomu: 10 monet
- 2★: +5, 3★: +10 (bonus)
- Codzienne logowanie (7-day cycle): 10/20/30/50/75/100/200
- Daily quest (3 zadania): 25 + 25 + 50 monet
- Achievement: 50-500 jednorazowo
- Rewarded `double_coins`: 2× nagroda z poziomu

### Wydawanie
- **Życia**: 5 monet (gdy zabraknie i nie chcesz czekać)
- **+5 ruchów** (in-game po porażce): 200 monet
- **Booster pre-game**: 75-150 monet
- **Shuffle**: 75 monet
- **Hint**: 50 monet
- **Odblokowanie kolejnego "świata"** (poziom 30, 60, 90): 500 monet **albo** ukończ poprzedni z 2★ średnio

## Pakiet Flutter
```yaml
dependencies:
  in_app_purchase: ^3.2.0
```
Inicjalizacja: `IapService` ładuje produkty z Google Play / App Store przy starcie, cachuje SKU.

## Wymagania konfiguracyjne
- **Google Play Console**: utworzyć produkty `Managed products` + subscription (jeśli battle pass v2)
- **App Store Connect**: utworzyć produkty IAP, czekać na review (każdy nowy produkt = review!)
- Receipt validation: na start lokalna (in_app_purchase library); docelowo backend (Cloud Function + Apple/Google verify)

## KPI monetyzacji (cele post-launch month 3)
| KPI | Cel |
|---|---|
| DAU | 5 000+ |
| D1 retention | > 35% |
| D7 retention | > 15% |
| D30 retention | > 5% |
| ARPDAU (total) | $0.10–0.25 |
| Conversion to paying (D7) | > 1.5% |
| ARPPU | $5–15 |
| % graczy z rewarded ad / dzień | > 25% |

## Anty-paywall / fair-play
- Pierwsze 30 poziomów playable bez ani jednego IAP/booster (potwierdzone playtestami)
- Po porażce **zawsze** opcja "obejrzyj reklamę za +5 ruchów" (rewarded) — nie tylko monety
- Brak "energy paywall" za solo content — system 5 żyć z regeneracją 30 min jest standardem branżowym

## Disclosure (Privacy Policy)
Privacy policy musi zawierać:
1. Zbieranie danych przez AdMob (IDFA/AAID, location coarse)
2. Firebase Analytics
3. IAP processor (Google Play / Apple)
4. Kontakt do żądania usunięcia danych (RODO/GDPR)
5. Wiek minimalny: 13 (PL/EU) / 16 (zależy od kraju)
