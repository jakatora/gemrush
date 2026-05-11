# 00 · START HERE — Instrukcje dla Claude'a w każdej sesji

> **Ten plik jest pierwszą rzeczą, którą czyta Claude w każdej nowej sesji.**
> Daje pełen kontekst projektu i wskazuje, co robić dalej.

## Projekt
**GemRush** (nazwa robocza) — match-3 puzzle game (à la Candy Crush, ale niezależna nazwa) na Android + iOS w Flutter + Flame. Monetyzacja: AdMob (interstitial co 2 poziomy + rewarded) + IAP. 100 poziomów, 7 światów. Cel: 12 tygodni do soft launchu w Polsce.

## Stack
- Flutter 3.24+ / Dart 3.5+
- Flame 1.18 (silnik 2D)
- Riverpod (state management)
- Hive (save state)
- Firebase: Analytics, Crashlytics, Remote Config
- google_mobile_ads, in_app_purchase

## Słowa kluczowe użytkownika (intencje)

| Słowo / fraza | Co robisz |
|---|---|
| `zaczynam` / `kontynuuj` / `dalej` | Otwórz `STATUS.md`, znajdź pierwszy niezakończony task w `TASKS.md`, wykonaj go i zaktualizuj STATUS. |
| `co teraz?` / `gdzie jesteśmy?` | Wyświetl skrót: tydzień X, faza Y, ostatnio ukończone Z, następny task W. |
| `zaktualizuj plan` | Otwórz odpowiedni doc/, zmień, zapisz. |
| `pomiń ten task` / `skip` | Oznacz task jako `[~]` (skipped) z notatką dlaczego. |
| `zatrzymaj się` / `stop` | Zapisz aktualny stan w STATUS.md, podsumuj co zrobione. |

## Co robisz przy **`zaczynam`** (pierwsza sesja praktyczna)

1. **Przeczytaj `STATUS.md`** — sprawdzisz, w jakim jesteś tygodniu/fazie.
2. **Przeczytaj `TASKS.md`** — znajdziesz pierwszy task `[ ]` (niewykonany).
3. **Wykonaj task** — od pojedynczego pliku po cały moduł. Granularność tasków jest dobrana tak, że jeden task = jedna sesja maksymalnie.
4. **Po zakończeniu**:
   - Oznacz task `[x]` w `TASKS.md`
   - Dopisz krótki commit log w `STATUS.md` (data + co zrobione + następny task)
   - Jeśli odkryłeś nowy podtask — dopisz go do `TASKS.md`
5. **Przejdź do następnego taska** jeśli kontekst pozwala (max 3-5 tasków per sesja, żeby nie zgubić jakości).

## Reguły pracy
- **Nigdy nie pytaj o pozwolenie** na rzeczy zaplanowane (jesteśmy w auto mode).
- **Pytaj** tylko gdy task wymaga decyzji niezadeklarowanej w docs (np. "preferujesz tę grafikę czy tamtą?", "który ID AdMob użyć — masz już konto?").
- **Nie twórz** plików których nie planujemy (sprawdź `docs/07-struktura-projektu.md`).
- **Edytuj istniejące pliki** zamiast tworzyć nowe duplikaty.
- **Aktualizuj `STATUS.md`** na końcu **każdej** sesji praktycznej (nawet 30-min).
- **Commituj często** (jeśli git zostanie zainicjalizowany w tygodniu 1) — po każdym tasku osobny commit.

## Co BARDZO ważne dla użytkownika
- **AdMob musi działać** — to główne źródło przychodu. Doc 04 jest święty.
- **Sklep i IAP** muszą być zaimplementowane, nawet jeśli soft launch zaczyna się głównie z reklamą.
- **100 poziomów** — nie 50, nie 75. Sto, w 7 światach.
- **Polska na start** — soft launch w PL, potem global. Stringi PL mają priorytet.

## Pliki bieżącego stanu (czytane na każdej sesji)
- [STATUS.md](STATUS.md) — gdzie jesteśmy w roadmapie
- [TASKS.md](TASKS.md) — lista 200+ zadań, oznaczona [ ]/[x]/[~]
- [README.md](README.md) — wysokopoziomowy overview
- [docs/](docs/) — pełen plan (12 dokumentów)

## Pliki referencyjne (czytane gdy task tego wymaga)
- `docs/01-architektura.md` — przy każdym nowym module
- `docs/02-gameplay.md` — przy implementacji mechaniki
- `docs/03-poziomy-design.md` — przy tworzeniu poziomów
- `docs/04-reklamy-admob.md` — **KLUCZOWY** przy całej integracji AdMob (tydzień 8)
- `docs/05-monetyzacja.md` — przy sklepie i IAP (tydzień 9)
- `docs/06-tech-stack.md` — gdy dodajesz nową zależność
- `docs/07-struktura-projektu.md` — gdy tworzysz nowy plik (sprawdź ścieżkę)
- `docs/08-roadmapa-12tyg.md` — gdy potrzebujesz kontekstu tygodnia
- `docs/09-assets-grafika.md` — gdy potrzebujesz assetu (placeholder vs final)
- `docs/10-testowanie-qa.md` — przy pisaniu testów
- `docs/11-publikacja-store.md` — w tygodniu 12
- `docs/12-checklist-launch.md` — w tygodniu 12

## Konwencja statusów tasków w `TASKS.md`
- `[ ]` — niewykonany
- `[x]` — wykonany
- `[/]` — w trakcie (jeśli zostawiłeś niedokończony — opisz w STATUS dlaczego)
- `[~]` — pominięty (z notatką dlaczego, np. "zlecone artystce", "nie potrzebne w MVP")
- `[!]` — zablokowany (czeka na user decision / external resource)
