# Gemy — sprite assety

Aktualnie gemy renderowane są **proceduralnie** w `gem_sprite.dart` (RadialGradient + kształt). To wystarcza do MVP i playtestu.

Aby podmienić na grafikę finalną:
1. Wrzuć tu PNG: `gem_red.png`, `gem_blue.png`, `gem_green.png`, `gem_yellow.png`, `gem_purple.png`, `gem_orange.png` (128×128)
2. Specjale: `gem_red_striped_h.png`, `gem_red_striped_v.png`, `gem_red_wrapped.png`, `color_bomb.png` (× kolory dla striped/wrapped)
3. Zaktualizuj `gem_sprite.dart` żeby ładował `Sprite.load(...)` zamiast `Canvas.drawCircle`.

**Polecane źródła**: Kenney "Puzzle Pack" (CC0), GameDevMarket, Itch.io.
