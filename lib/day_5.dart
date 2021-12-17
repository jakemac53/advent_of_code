import 'dart:io';
import 'dart:math' as math;

final lines = [
  for (var line in File('lib/day_5_input.txt').readAsLinesSync())
    if (line.isNotEmpty) Line.parse(line),
];

final maxR = () {
  var max = 0;
  for (var line in lines) {
    max = math.max(math.max(line.start.r, line.end.r), max);
  }
  return max + 1;
}();

final maxC = () {
  var max = 0;
  for (var line in lines) {
    max = math.max(math.max(line.start.c, line.end.c), max);
  }
  return max + 1;
}();

void main() {
  print('Day 5: Part 1: ${day5Part1()} - Part 2: ${day5Part2()}');
}

int day5Part1() {
  var grid = List.generate(maxR, (_) => List.filled(maxC, 0));
  for (var line in lines) {
    if (line.start.r == line.end.r) {
      var start = math.min(line.start.c, line.end.c);
      var end = math.max(line.start.c, line.end.c);
      for (var c = start; c <= end; c++) {
        grid[line.start.r][c]++;
      }
    } else if (line.start.c == line.end.c) {
      var start = math.min(line.start.r, line.end.r);
      var end = math.max(line.start.r, line.end.r);
      for (var r = start; r <= end; r++) {
        grid[r][line.start.c]++;
      }
    }
  }
  var overlapCount = 0;
  for (var r = 0; r < maxR; r++) {
    for (var c = 0; c < maxC; c++) {
      if (grid[r][c] >= 2) overlapCount++;
    }
  }
  return overlapCount;
}

int day5Part2() {
  var grid = List.generate(maxR, (_) => List.filled(maxC, 0));
  for (var line in lines) {
    var length = math.max((line.start.r - line.end.r).abs(),
            (line.start.c - line.end.c).abs()) +
        1;
    var rInc = line.start.r == line.end.r
        ? 0
        : line.start.r < line.end.r
            ? 1
            : -1;
    var cInc = line.start.c == line.end.c
        ? 0
        : line.start.c < line.end.c
            ? 1
            : -1;
    for (var i = 0; i < length; i++) {
      grid[line.start.r + i * rInc][line.start.c + i * cInc]++;
    }
  }
  var overlapCount = 0;
  for (var r = 0; r < maxR; r++) {
    for (var c = 0; c < maxC; c++) {
      if (grid[r][c] >= 2) overlapCount++;
    }
  }
  return overlapCount;
}

class Line {
  final Coord start;
  final Coord end;

  Line(this.start, this.end);

  factory Line.parse(String line) {
    var parts = line.split(' -> ');
    return Line(Coord.parse(parts[0]), Coord.parse(parts[1]));
  }

  String toString() => '$start -> $end';
}

class Coord {
  final int r;
  final int c;

  Coord(this.r, this.c);

  factory Coord.parse(String coord) {
    var parts = coord.split(',');
    return Coord(int.parse(parts[1]), int.parse(parts[0]));
  }

  String toString() => '($r, $c)';
}
