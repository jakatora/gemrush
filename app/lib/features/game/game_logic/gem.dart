/// Typ wizualny klejnotu — wymiar koloru.
enum GemColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange;

  static const all = [red, blue, green, yellow, purple, orange];
}

/// Typ specjalny gemu (jeśli powstał z matcha 4/5/L/T).
enum GemKind {
  normal,
  stripedHorizontal,
  stripedVertical,
  wrapped,
  colorBomb;

  bool get isSpecial => this != normal;
}

/// Pojedynczy klejnot na planszy.
class Gem {
  final GemColor color;
  final GemKind kind;

  /// Unikalny ID — używany do śledzenia w animacjach (kiedy gem zmienia pozycję).
  final int id;

  const Gem({
    required this.id,
    required this.color,
    this.kind = GemKind.normal,
  });

  Gem copyWith({GemColor? color, GemKind? kind, int? id}) => Gem(
        id: id ?? this.id,
        color: color ?? this.color,
        kind: kind ?? this.kind,
      );

  /// Color bomb nie ma "koloru" w tradycyjnym sensie.
  bool get isColorBomb => kind == GemKind.colorBomb;

  @override
  String toString() => 'Gem(id:$id,${color.name},${kind.name})';
}

/// Pole planszy: gem, blocker, jelly layer, ingredient.
class Cell {
  Gem? gem;
  int jellyLayers;
  int iceLayers;
  bool blocked;
  bool hasIngredient;
  bool chocolate;

  Cell({
    this.gem,
    this.jellyLayers = 0,
    this.iceLayers = 0,
    this.blocked = false,
    this.hasIngredient = false,
    this.chocolate = false,
  });

  bool get isPlayable => !blocked && iceLayers == 0;
  bool get isEmpty => gem == null;

  Cell clone() => Cell(
        gem: gem,
        jellyLayers: jellyLayers,
        iceLayers: iceLayers,
        blocked: blocked,
        hasIngredient: hasIngredient,
        chocolate: chocolate,
      );
}

/// Współrzędna na planszy. `row` 0 jest na górze, `col` 0 na lewo.
class Pos {
  final int row;
  final int col;
  const Pos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pos && other.row == row && other.col == col);

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';

  Pos get up => Pos(row - 1, col);
  Pos get down => Pos(row + 1, col);
  Pos get left => Pos(row, col - 1);
  Pos get right => Pos(row, col + 1);

  bool isAdjacentTo(Pos other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return (dr + dc) == 1;
  }
}
