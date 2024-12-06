extension StringUtils on String {
  List<int> readNumbers({String prefix = '', String separator = ' '}) => [
        for (var seed
            in substring(prefix.length).split(separator)
              ..removeWhere((s) => s.isEmpty))
          int.parse(seed),
      ];
}

extension LineInputHelper on List<String> {
  String lookup(Point point) => this[point.y][point.x];

  bool isValid(Point p) =>
      p.x >= 0 && p.y >= 0 && p.x < first.length && p.y < length;

  String prettyString() {
    var buffer = StringBuffer();
    for (var line in this) {
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  Iterable<Point> get points sync* {
    for (var y = 0; y < length; y++) {
      var line = this[y];
      for (var x = 0; x < line.length; x++) {
        yield (x, y);
      }
    }
  }
}

extension GridInputHelper on List<List<String>> {
  String lookup(Point point) => this[point.y][point.x];

  bool isValid(Point p) =>
      p.x >= 0 && p.y >= 0 && p.x < first.length && p.y < length;

  String prettyString() {
    var buffer = StringBuffer();
    for (var line in this) {
      buffer.writeln(line.join(''));
    }
    return buffer.toString();
  }

  Iterable<Point> get points sync* {
    for (var y = 0; y < length; y++) {
      var line = this[y];
      for (var x = 0; x < line.length; x++) {
        yield (x, y);
      }
    }
  }
}

typedef Point = (int x, int y);

extension PointHelpers on Point {
  int get x => $1;
  int get y => $2;

  Point operator +(Point other) => (x + other.x, y + other.y);
  Point operator -(Point other) => (x - other.x, y - other.y);

  bool isValid(List<String> input) =>
      x >= 0 && y >= 0 && x < input.first.length && y < input.length;
}

const left = (-1, 0);
const right = (1, 0);
const up = (0, -1);
const down = (0, 1);
const upLeft = (-1, -1);
const upRight = (1, -1);
const downLeft = (-1, 1);
const downRight = (1, 1);
