# GemRush (nazwa robocza)

Match-3 mobile na Flutter + Flame z monetyzacją AdMob (interstitial + rewarded) i 100 poziomami.

## Kluczowe decyzje
- **Stack**: Flutter 3.x + Flame 1.x (silnik 2D)
- **Platformy**: Android + iOS (jeden kod)
- **Monetyzacja**: AdMob (interstitial co 2 poziomy, rewarded za życia/ruchy/podpowiedzi) + IAP (remove ads, monety, paczki życ)
- **Zakres MVP → release**: 100 poziomów, mapa świata, system 5 żyć z regeneracją 30 min, boostery, leaderboard
- **Timeline**: 12 tygodni

## Alternatywne nazwy do rozważenia
GemRush, GemBlast, JewelStorm, PixelPop, MozaikaMagia, Klejnoty Królestwa, FruitFiesta, ColorCrash, SparkSaga

## Struktura dokumentacji

| # | Plik | Co opisuje |
|---|------|------------|
| 01 | [docs/01-architektura.md](docs/01-architektura.md) | Architektura techniczna, warstwy, state management |
| 02 | [docs/02-gameplay.md](docs/02-gameplay.md) | Mechaniki: plansza, match-3, kaskady, special gems, cele |
| 03 | [docs/03-poziomy-design.md](docs/03-poziomy-design.md) | Design 100 poziomów: krzywa trudności, typy, przeszkody |
| 04 | [docs/04-reklamy-admob.md](docs/04-reklamy-admob.md) | **AdMob: setup, jednostki, frequency capping, GDPR/ATT** |
| 05 | [docs/05-monetyzacja.md](docs/05-monetyzacja.md) | IAP, ekonomia monet, paywally, KPI |
| 06 | [docs/06-tech-stack.md](docs/06-tech-stack.md) | Pakiety, wersje, biblioteki, narzędzia |
| 07 | [docs/07-struktura-projektu.md](docs/07-struktura-projektu.md) | Drzewo plików, organizacja kodu |
| 08 | [docs/08-roadmapa-12tyg.md](docs/08-roadmapa-12tyg.md) | Plan 12 tygodni, kamienie milowe, deliverables |
| 09 | [docs/09-assets-grafika.md](docs/09-assets-grafika.md) | Grafika, dźwięk, źródła, lista assetów |
| 10 | [docs/10-testowanie-qa.md](docs/10-testowanie-qa.md) | Testy: unit, widget, integration, gameplay QA |
| 11 | [docs/11-publikacja-store.md](docs/11-publikacja-store.md) | Google Play + App Store: wymagania, polityki, soft launch |
| 12 | [docs/12-checklist-launch.md](docs/12-checklist-launch.md) | Lista kontrolna przed publikacją |

## System kontynuacji (czytane na każdej sesji Claude'a)
- [00-START-HERE.md](00-START-HERE.md) — **PIERWSZE czytanie** na każdej nowej sesji: kontekst, reguły pracy, słowa-kluczowe
- [STATUS.md](STATUS.md) — bieżący stan (sesja N, tydzień X, następny task), aktualizowany po każdej sesji
- [TASKS.md](TASKS.md) — granularna lista ~200 zadań z ID `T1.1 → T12.23`, checkboxy `[ ]/[x]/[/]/[~]/[!]`

## Jak wznowić pracę w nowej sesji
W kolejnej rozmowie z Claude'em napisz po prostu **`zaczynam`** (lub `kontynuuj` / `dalej`). Claude:
1. Otworzy `00-START-HERE.md` → kontekst projektu
2. Otworzy `STATUS.md` → zobaczy gdzie skończyliśmy
3. Otworzy `TASKS.md` → znajdzie pierwszy task `[ ]`
4. Wykona task → zaktualizuje status → przejdzie do następnego

## Kolejność czytania (przy pierwszym przeglądaniu planu)
Najpierw `08-roadmapa-12tyg.md` (co kiedy), potem `04-reklamy-admob.md` (kluczowy dla monetyzacji), potem reszta tematycznie.
