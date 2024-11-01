extension Chars on String {
  List<String> get chars => [
        for (var c = 0; c < length; c++) this[c],
      ];
}

class Coord {
  final int row;
  final int col;
  const Coord(this.row, this.col);

  String toString() => '($row,$col)';

  bool operator ==(other) =>
      other is Coord && other.row == row && other.col == col;

  int get hashCode => Object.hash(row, col);
}

extension DeepCopy on List {
  List deepCopy() => [
        for (var item in this) item is List ? item.deepCopy() : item,
      ];
}
