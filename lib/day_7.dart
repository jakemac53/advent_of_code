import 'dart:io';
import 'dart:math' as math;

const day = 7;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync();

final positions = [
  for (var num in lines.first.split(',')) int.parse(num),
]..sort((a, b) => a - b);

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  /// It's just the median
  var pos = positions[(positions.length / 2).floor()];
  return cost(pos);
}

int part2() {
  // start at the median, work outwards while its cheaper.
  var pos = positions[(positions.length / 2).floor()];
  var min = costExp(pos);
  var dir = 0;
  if (costExp(pos - 1) < min) {
    dir = -1;
  } else if (costExp(pos + 1) < min) {
    dir = 1;
  } else {
    return costExp(pos);
  }
  int next;
  while (min > (next = costExp(pos + dir))) {
    min = next;
    pos = pos + dir;
  }
  return costExp(pos);
}

int cost(int position) =>
    positions.fold(0, (prev, next) => prev + (position - next).abs());

int costExp(int position) => positions.fold(0, (prev, next) {
      var dist = (position - next).abs();
      var nextCost = (dist * ((dist + 1) / 2)).toInt();
      return prev + nextCost;
    });
