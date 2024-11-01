import 'dart:io';

import 'util.dart';

const day = 9;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final heatMap = [
  for (var line in lines)
    [
      for (var char in line.chars) int.parse(char),
    ],
];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var lowPoints = [
    for (var r = 0; r < heatMap.length; r++)
      for (var c = 0; c < heatMap[r].length; c++)
        if (isLowPoint(r, c)) Coord(r, c),
  ];
  var sum = 0;
  for (var point in lowPoints) {
    sum += heatMap[point.row][point.col] + 1;
  }
  return sum;
}

int part2() {
  var lowPoints = [
    for (var r = 0; r < heatMap.length; r++)
      for (var c = 0; c < heatMap[r].length; c++)
        if (isLowPoint(r, c)) Coord(r, c),
  ];
  var basins = [0, 0, 0];
  var visited = <Coord>{};
  for (var start in lowPoints) {
    var size = 0;
    void expand(Coord from) {
      var surrounding = <Coord>[];
      if (visited.contains(from)) return;
      var val = heatMap[from.row][from.col];
      if (val == 9) {
        visited.add(from);
        return;
      }
      for (var dir in dirs) {
        var row = from.row + dir.row;
        if (row >= heatMap.length || row < 0) continue;
        var col = from.col + dir.col;
        if (col >= heatMap[0].length || col < 0) continue;
        var next = Coord(row, col);
        if (visited.contains(next)) continue;
        var nextVal = heatMap[next.row][next.col];
        // Completely bail if anything surrounding is lower.
        if (nextVal < heatMap[from.row][from.col]) {
          return;
        }
        surrounding.add(next);
      }
      visited.add(from);
      size += 1;
      for (var next in surrounding) expand(next);
    }

    expand(start);

    if (size > basins[0]) {
      basins[0] = size;
      basins.sort((a, b) => a - b);
    }
  }
  return basins[0] * basins[1] * basins[2];
}

const dirs = [Coord(1, 0), Coord(-1, 0), Coord(0, 1), Coord(0, -1)];

bool isLowPoint(int r, int c) {
  var val = heatMap[r][c];
  for (var dir in dirs) {
    var row = r + dir.row;
    if (row >= heatMap.length || row < 0) continue;
    var col = c + dir.col;
    if (col >= heatMap[0].length || col < 0) continue;
    if (val >= heatMap[row][col]) return false;
  }
  return true;
}
