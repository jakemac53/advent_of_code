extension StringUtils on String {
  List<int> readNumbers({String prefix = '', String separator = ' '}) => [
        for (var seed
            in substring(prefix.length).split(separator)
              ..removeWhere((s) => s.isEmpty))
          int.parse(seed),
      ];
}

typedef Point = (int x, int y);

extension PointHelpers on Point {
  int get x => $1;
  int get y => $2;

  Point operator +(Point other) => (x + other.x, y + other.y);

  bool isValid(List<String> input) =>
      x >= 0 && y >= 0 && x < input.first.length && y < input.length;
}
