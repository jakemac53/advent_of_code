import 'dart:io';

import 'package:collection/collection.dart';

import 'util.dart';

const day = 15;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<List<int>> readRiskLevels() => [
      for (var line in lines)
        [
          for (var char in line.chars) int.parse(char),
        ]
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  return lowestCost(readRiskLevels());
}

int part2() {
  var originalRiskLevels = readRiskLevels();
  return lowestCost(List.generate(
      originalRiskLevels.length * 5,
      (r) => List.generate(originalRiskLevels.first.length * 5, (c) {
            var risk = originalRiskLevels[r % originalRiskLevels.length]
                    [c % originalRiskLevels.first.length] +
                (r / originalRiskLevels.length).floor() +
                (c / originalRiskLevels.first.length).floor();
            return risk > 9 ? risk - 9 : risk;
          })));
}

int lowestCost(List<List<int>> riskLevels) {
  var costs = List.generate(riskLevels.length,
      (_) => List<int?>.filled(riskLevels.first.length, null));
  var pathsQueue = PriorityQueue<Coord>(
      (a, b) => costs[a.row][a.col]! - costs[b.row][b.col]!);
  var start = Coord(0, 0);
  var end = Coord(riskLevels.length - 1, riskLevels.first.length - 1);
  costs[0][0] = 0;
  pathsQueue.add(start);
  while (pathsQueue.isNotEmpty) {
    var curr = pathsQueue.removeFirst();
    var currCost = costs[curr.row][curr.col]!;
    for (var dir in dirs) {
      var row = dir.row + curr.row;
      var col = dir.col + curr.col;
      if (row >= riskLevels.length || row < 0) continue;
      if (col >= riskLevels.first.length || col < 0) continue;
      var newCost = currCost + riskLevels[row][col];
      var newCoord = Coord(row, col);
      // Found the end!
      if (newCoord == end) return newCost;

      // We can't by definition find a cheaper route since we use a priority
      // queue to crawl coords, and so we only care about null entries.
      if (costs[row][col] == null) {
        costs[row][col] = newCost;
        pathsQueue.add(newCoord);
      }
    }
  }
  throw StateError('Couldn\'t find the end!');
}

final dirs = [
  Coord(-1, 0),
  Coord(1, 0),
  Coord(0, -1),
  Coord(0, 1),
];
