# 03 · Design 100 poziomów

## Krzywa trudności (zatwierdzenie graczy ≥ 70%)
| Zakres | Trudność | Charakter |
|---|---|---|
| 1–10 | Tutorial | Wprowadzanie po jednej mechanice. Wszystkie wygrywalne w ≤3 próbach. |
| 11–30 | Easy | Wprowadzenie galarety, skrzyń, ingredientów. ~85% pass rate. |
| 31–50 | Medium | Mix celów, mniej ruchów, czekolada (rozrasta się). ~70% pass rate. |
| 51–75 | Hard | Ograniczone planowanie, lód 2-warstwowy, taśmociągi. ~55% pass rate. |
| 76–95 | Expert | Wszystkie mechaniki, krótkie limity ruchów. ~40% pass rate. |
| 96–100 | Boss / Endgame | Zaprojektowane jako wyzwanie. Często wymagają boosterów. ~25% pass rate. |

## Poziomy specjalne (co N poziomów)
- **Co 10**: poziom "świata" — nowe tło + nowa mechanika
- **Co 25**: mini-boss (większa plansza, podwójny cel)
- **Co 50**: gate progresji — wymagane pokonanie X gwiazdek wstecz

## Świat (mapa)
- **Świat 1**: Tutorial Plaża (1–15)
- **Świat 2**: Las Kryształów (16–30)
- **Świat 3**: Lodowe Jaskinie (31–45)
- **Świat 4**: Pustynia Złota (46–60)
- **Świat 5**: Wulkaniczne Klify (61–75)
- **Świat 6**: Niebiańskie Wyspy (76–90)
- **Świat 7**: Kosmiczna Forteca (91–100)

## Format danych poziomu (JSON)
```json
{
  "id": 23,
  "world": 2,
  "boardSize": [9, 9],
  "moves": 22,
  "goals": [
    { "type": "score", "target": 25000 },
    { "type": "clearJelly", "count": 14 }
  ],
  "starThresholds": [25000, 37500, 62500],
  "layout": [
    "GGGGGGGGG",
    "GGGJJJGGG",
    "GGJJJJJGG",
    "GGGGGGGGG",
    "..."
  ],
  "allowedColors": ["red","blue","green","yellow","purple"],
  "preplacedSpecials": [],
  "obstacles": { "ice": [[2,3],[2,4]] }
}
```

Legenda layoutu: `G`=zwykła komórka, `J`=galareta, `I`=lód, `C`=czekolada, `X`=zablokowana, `.`=brak.

## Edytor poziomów (wewnętrzny, opcjonalny)
Prosty Flutter desktop app — grid clickable, eksport JSON. **Decyzja**: do poziomu 30 ręcznie w JSON; jeśli proces będzie wolny, zbuduj edytor (tydzień 7).

## Balans i playtest
- **Min. 3 osoby** playtest per poziom
- Metryki przez Firebase Analytics: `level_start`, `level_complete`, `level_fail`, `moves_left`, `boosters_used`, `attempts`
- Próg do rebalansu: pass rate < 30% przez 7 dni → łatwiejsze; > 95% przez 7 dni → trudniejsze
- Remote Config umożliwi zmianę `moves` per level bez update'u aplikacji
