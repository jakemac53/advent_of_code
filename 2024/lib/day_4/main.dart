import 'dart:io';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((line) => line.isEmpty);

const xmas = ['X', 'M', 'A', 'S'];

void main() {
  // Part 1
  {
    print('part 1: ${countWord(xmas)}');
  }

  // Part 2
  {
    print('part 2: ${countXWord(xmas.sublist(1))}');
  }
}

int countWord(List<String> word) {
  var total = 0;
  for (var y = 0; y < input.length; y++) {
    var line = input[y];
    for (var x = 0; x < line.length; x++) {
      var start = (x, y);
      if (input.find(start) != word[0]) continue;

      for (var dir in allDirs) {
        if (matchesWord(start, dir, word)) {
          total++;
        }
      }
    }
  }
  return total;
}

int countXWord(List<String> word) {
  var matches = <(Point a, Point aDir, Point b, Point bDir)>{};
  for (var y = 0; y < input.length; y++) {
    var line = input[y];
    for (var x = 0; x < line.length; x++) {
      var start = (x, y);
      if (input.find(start) != word[0]) continue;

      for (var dir in diagonalDirs) {
        if (!matchesWord(start, dir, word)) continue;
        // Found one possible part of an X, check for 2nd half.
        // Note: Would be easier to just start from the `A` letters LOL.

        // Move in the x dir an extra space, check for word in the negative x dir from original.
        if (matchesWord(start + (dir.x * 2, 0), (-dir.x, dir.y), word)) {
          matches.add((start, dir, start + (dir.x * 2, 0), (-dir.x, dir.y)));
        }
        // Move in the y dir an extra space, check for word in the negative y dir from original.
        if (matchesWord(start + (0, dir.y * 2), (dir.x, -dir.y), word)) {
          matches.add((start, dir, start + (0, dir.y * 2), (dir.x, -dir.y)));
        }
      }
    }
  }
  // We double count each answer, just divide by two.
  return (matches.length / 2).toInt();
}

bool matchesWord(Point start, Point dir, List<String> word) {
  if (input.find(start) != word[0]) return false;
  var current = start;
  for (var c = 1; c < word.length; c++) {
    current += dir;
    if (!current.isValid || input.find(current) != word[c]) {
      return false;
    }
  }
  return true;
}

typedef Point = (int x, int y);

extension on Point {
  int get x => $1;
  int get y => $2;

  Point operator +(Point other) => (x + other.x, y + other.y);

  bool get isValid =>
      x >= 0 && y >= 0 && x < input.first.length && y < input.length;
}

extension on List<String> {
  String find(Point point) => this[point.y][point.x];
}

final allDirs = [
  (1, 0),
  (-1, 0),
  (0, 1),
  (0, -1),
  ...diagonalDirs,
];

final diagonalDirs = [
  (1, -1),
  (-1, 1),
  (1, 1),
  (-1, -1),
];
