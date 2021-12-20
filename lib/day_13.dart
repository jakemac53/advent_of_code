import 'dart:io';
import 'dart:math' as math;

import 'util.dart';

const day = 13;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<Coord> readCoords() => [
      for (var line in lines)
        if (!line.startsWith('fold along '))
          Coord(int.parse(line.split(',')[1]), int.parse(line.split(',')[0])),
    ];

final folds = [
  for (var line in lines)
    if (line.startsWith('fold along '))
      Fold(
        line.substring(11).split('=')[0] == 'x' ? Direction.x : Direction.y,
        int.parse(line.substring(11).split('=')[1]),
      ),
];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var dots = readCoords().toSet();
  var fold = folds.first;
  performFold(fold, dots);

  return dots.length;
}

int part2() {
  var dots = readCoords().toSet();
  for (var fold in folds) {
    performFold(fold, dots);
  }

  var minCol =
      dots.fold<int>(999999999, (prev, next) => math.min(prev, next.col));
  var maxCol =
      dots.fold<int>(-999999999, (prev, next) => math.max(prev, next.col));
  var minRow =
      dots.fold<int>(999999999, (prev, next) => math.min(prev, next.row));
  var maxRow =
      dots.fold<int>(-999999999, (prev, next) => math.max(prev, next.row));
  var page = List.generate(
      maxRow - minRow + 1, (_) => List.filled(maxCol - minCol + 1, '.'));
  for (var dot in dots) {
    page[dot.row + minRow][dot.col + minCol] = '#';
  }
  for (var row in page) {
    print(row.join());
  }
  // Actual answer is visualized, but we also return the number of remaining
  // dots for the lulz.
  return dots.length;
}

void performFold(Fold fold, Set<Coord> dots) {
  switch (fold.direction) {
    case Direction.x:
      for (var dot in dots.toList()) {
        if (dot.col > fold.amount) {
          var col = fold.amount - (dot.col - fold.amount);
          dots.remove(dot);
          dots.add(Coord(dot.row, col));
        }
      }
      break;
    case Direction.y:
      for (var dot in dots.toList()) {
        if (dot.row > fold.amount) {
          var row = fold.amount - (dot.row - fold.amount);
          dots.remove(dot);
          dots.add(Coord(row, dot.col));
        }
      }
      break;
  }
}

class Fold {
  final Direction direction;
  final int amount;

  Fold(this.direction, this.amount);
}

enum Direction {
  x,
  y,
}
