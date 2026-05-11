# 02 · Gameplay — mechaniki rdzeniowe

## Plansza
- Rozmiar: **9 × 9** (możliwe per-level 7×7 do 9×9)
- 6 typów klejnotów (kolory): czerwony, niebieski, zielony, żółty, fioletowy, pomarańczowy
- Komórka: pusta / klejnot / przeszkoda / cel

## Ruch gracza
1. Drag/swipe lub tap-tap dwóch sąsiednich klejnotów
2. Swap animuje się 150 ms
3. Sprawdzenie czy powstał match ≥3 → jeśli **nie**, cofnij swap (300 ms back)
4. Jeśli **tak**, uruchom pipeline matchowania

## Pipeline match → cascade
```
swap → findMatches → markForRemoval → spawnSpecials →
removeGems (anim 200ms) → applyGravity (300ms) →
refillTop (300ms) → findMatches (kaskada) → ...
```
Pętla aż `findMatches` zwróci pusty wynik.

## Special gems (tworzone z matcha)
| Trigger | Tworzy | Efekt |
|---|---|---|
| 4 w linii poziomo | **Striped horizontal** | Czyści cały rząd |
| 4 w linii pionowo | **Striped vertical** | Czyści całą kolumnę |
| L / T (5 klejnotów, narożnik) | **Wrapped** | 2× eksplozja 3×3 (z opóźnieniem 250 ms) |
| 5 w linii | **Color Bomb** | Po swapie z dowolnym kolorem usuwa wszystkie tego koloru |

## Combo (swap dwóch specjali)
| Combo | Efekt |
|---|---|
| Striped + Striped | Krzyż (cały rząd + cała kolumna) |
| Striped + Wrapped | 3 rzędy + 3 kolumny |
| Wrapped + Wrapped | Wielka eksplozja 5×5 |
| Color Bomb + zwykły | Usuwa wszystkie tego koloru (jak normalnie) |
| Color Bomb + Striped | Wszystkie kolejne tego koloru → Striped |
| Color Bomb + Wrapped | Wszystkie kolejne tego koloru → Wrapped |
| Color Bomb + Color Bomb | Czyści całą planszę |

## Cele poziomu (typy)
1. **Score target** — uzbieraj X pkt w Y ruchach
2. **Clear jelly** — usuń wszystkie pola galarety (2 warstwy)
3. **Collect ingredients** — zrzuć N orzeszków na dół planszy
4. **Clear obstacles** — rozbij N skrzyń / lodu / czekolady
5. **Mixed** — kombinacje powyższych

## Limity
- **Moves** — domyślny limit (15-40 ruchów per poziom)
- **Time** (rzadko, dla poziomów speed-run) — 60-120 s

## Scoring
- Match 3: 60 pkt
- Match 4: 120 pkt + striped
- Match 5: 200 pkt + color bomb
- L/T: 200 pkt + wrapped
- Kaskada: każde kolejne usunięcie ×1.5 mnożnik (max ×5)
- Bonus na koniec: każdy pozostały ruch × 1000 (zamienia się w striped → cascade)

## Gwiazdki (ranking poziomu)
- 1★ — wykonany cel
- 2★ — cel + 1.5× progu punktowego
- 3★ — cel + 2.5× progu punktowego

## System życ
- 5 serc max
- 1 serce regeneruje się co **30 min** (timer zapisany w Hive)
- Przegrana = -1 życie
- Rewarded ad = +1 życie
- IAP = paczki życ (10 / 50 / unlimited 24h)

## Boostery (pre-game)
- **Extra moves +5** — 100 monet
- **Color bomb start** — 150 monet (wstaw color bomb na start)
- **Hammer** — 75 monet (rozbij dowolny klejnot)
- **Shuffle** — 75 monet

## Boostery (in-game)
- **+5 moves** — gdy zabraknie ruchów (200 monet **albo rewarded ad**)
- **Hint** — pokaż możliwy ruch (rewarded ad **lub** 50 monet)
