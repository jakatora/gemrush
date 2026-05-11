# 09 · Assets — grafika i dźwięk

## Filozofia stylu
- **Cartoon, kolorowy, czytelny** — szybka identyfikacja gemu w ułamku sekundy
- **Wysoki kontrast** — gemy odróżniają się także dla daltonistów (dodatkowo kształt, nie tylko kolor)
- **Glossy / 3D-light** — typowy match-3 look (Candy Crush, Royal Match, Toon Blast)

## Lista assetów — grafika

### Gemy podstawowe (6 kolorów × 1 sprite + warianty)
| ID | Kolor | Kształt (dla a11y) |
|---|---|---|
| `gem_red` | czerwony | romb |
| `gem_blue` | niebieski | kropla |
| `gem_green` | zielony | okrąg |
| `gem_yellow` | żółty | gwiazda |
| `gem_purple` | fioletowy | sześciokąt |
| `gem_orange` | pomarańczowy | kwadrat |

**Rozmiar bazowy**: 128×128 px (rendering @ ~80px na ekranie, zapas dla retina)
**Format**: PNG, transparent

### Specjalne warianty (per kolor lub uniwersalne)
- `gem_<color>_striped_h.png` — z poziomymi paskami (czyści rząd)
- `gem_<color>_striped_v.png` — z pionowymi paskami (czyści kolumnę)
- `gem_<color>_wrapped.png` — w kapsule (eksplozja 3×3)
- `color_bomb.png` — czarna kula z tęczowymi iskrami (uniwersalna)

### UI
- `btn_play.png`, `btn_settings.png`, `btn_shop.png`, `btn_close.png`, `btn_pause.png`
- `panel_dialog.png`, `panel_hud.png`
- `ico_coin.png`, `ico_heart.png`, `ico_star.png`, `ico_move.png`, `ico_clock.png`
- `bar_progress.png`, `bar_progress_fill.png`

### Tła per świat
- `bg_world_1.png` ... `bg_world_7.png` (1080×1920 portrait)
- Każdy świat: tło + tile do planszy + kolorystyka HUD

### Przeszkody
- `jelly.png` (warstwa 1 + 2)
- `ice_1.png`, `ice_2.png` (2 grubości)
- `chocolate.png` (rozrasta się)
- `crate.png` (1 i 2 HP)
- `ingredient_nut.png` (zrzut na dół)

### Partikle / VFX
- `sparkle.png` (small)
- `explosion_ring.png`
- `confetti_*.png` (× 6 kolorów)
- `star_burst.png`

### Lottie (gotowe animacje)
- `lottie_win_celebration.json`
- `lottie_lose_sad.json`
- `lottie_loading_spinner.json`
- `lottie_3_stars.json` (sekwencja gwiazdek)

## Lista assetów — audio

### SFX (krótkie, .ogg lub .wav, mono, 22-44 kHz)
- `swap.ogg` — szybki "shing"
- `match3.ogg` — krótki sparkle
- `match4.ogg` — głośniejszy, z echo
- `match5.ogg` — magiczny
- `cascade_1.ogg`, `cascade_2.ogg`, `cascade_3.ogg` — rosnący ton (chain bonus)
- `special_strip.ogg`, `special_wrap.ogg`, `special_bomb.ogg`
- `win.ogg` — fanfar (~2 s)
- `lose.ogg` — przegrana (~1 s)
- `button_tap.ogg`, `button_back.ogg`
- `coin_collect.ogg`, `star_collect.ogg`
- `life_refill.ogg`
- `booster_select.ogg`

### Muzyka (loopowalna, .mp3 lub .ogg)
- `music_menu.mp3` (2–3 min loop, spokojna)
- `music_game_1.mp3` (świat 1–3, optymistyczna)
- `music_game_2.mp3` (świat 4–5, dynamiczna)
- `music_game_3.mp3` (świat 6–7, epicka)
- `music_event.mp3` (na eventy, opcjonalnie)

## Źródła assetów (priorytet wg kosztu)

### Bezpłatne (CC0 / CC-BY)
- **Kenney.nl** — gotowe pakiety puzzle/UI (CC0)
- **OpenGameArt.org** — różne licencje
- **Freesound.org** — SFX (sprawdź licencję każdego)
- **Pixabay** / **Mixkit** — muzyka i SFX (royalty-free)

### Płatne (recommended dla finalnego look)
- **Unity Asset Store** (działa dla Flame też — kupujesz pliki PNG/atlas)
  - Pakiety match-3 ~$30-80
- **GameDevMarket** — assety od artystów
- **Itch.io asset packs** — niskie ceny ($5-30)
- **AudioJungle** (Envato) — muzyka i SFX

### Custom AI-generated (pierwszy draft)
- **Midjourney** / **Leonardo.ai** — koncepty teł, gemów
- **Adobe Firefly** — UI elements
- Po wygenerowaniu: doczyść w **GIMP** / **Photoshop** / **Affinity**
- Wektory: **Adobe Illustrator** / **Inkscape**
- **Pixel art**: Aseprite

### Custom workflow (jeśli budżet pozwala)
- Zlecenie ilustratorowi przez **99designs** / **Fiverr** / **Upwork**
- Koszt pakietu match-3 (gemy + UI + tła): $300-2000

## Sprite atlasy
Dla wydajności użyj `TexturePacker` → `assets/images/atlases/gems.png` + `gems.json`.
Flame ma `SpriteSheet` class — łatwe load atlasów.

## Naming convention
- `lowercase_snake_case.png`
- Prefix: typ + obiekt + wariant (`gem_red_striped_h.png`)
- Wersjonowanie: jeśli zmiana, dodaj `_v2` w nazwie (i zaktualizuj wszystkie referencje)

## Lista do zrobienia (Tydz. 1-4: placeholdery, Tydz. 10: final)
Placeholdery na MVP można wziąć z **Kenney "Puzzle Pack"** (CC0). Final wymaga albo zakupu pakietu, albo zlecenia artystki/ego.
