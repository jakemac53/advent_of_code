import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'util.dart';

const day = 18;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<List> readSnailFishNums() => [
      for (var line in lines) jsonDecode(line) as List,
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var snailFishNums = readSnailFishNums();
  var current = snailFishNums.first;
  reduceNum(current);
  for (var next in snailFishNums.skip(1)) {
    current = [current, next];
    reduceNum(current);
  }
  return magnitude(current);
}

int part2() {
  var snailFishNums = readSnailFishNums();
  var reducedNums = [
    for (var num in snailFishNums) reduceNum(num),
  ];
  var max = 0;
  for (var i = 0; i < reducedNums.length; i++) {
    for (var j = 0; j < reducedNums.length; j++) {
      if (i == j) continue;
      var left = reducedNums[i].deepCopy();
      var right = reducedNums[j].deepCopy();
      var reduced = reduceNum([left, right]);
      max = math.max(max, magnitude(reduced));
    }
  }
  return max;
}

List reduceNum(List snailfishNum) {
  var result = explode(snailfishNum, const [], 0, 0);
  if (!result.reduced) {
    result = split(snailfishNum, [], 0);
  }
  while (result.reduced) {
    result = explode(snailfishNum, const [], 0, 0);
    if (!result.reduced) {
      result = split(snailfishNum, [], 0);
    }
  }
  return snailfishNum;
}

ReduceResult explode(List pair, List parent, int depth, int index) {
  if (depth >= 4) {
    parent[index] = 0;
    return ReduceResult(true,
        addLeft: pair[0] as int, addRight: pair[1] as int);
  }

  // First do explodes
  for (var i = 0; i < pair.length; i++) {
    var entry = pair[i];
    if (entry is! List) continue;
    var result = explode(entry, pair, depth + 1, i);
    if (result.addLeft != null) {
      if (i == 1) {
        if (pair[0] is int) {
          pair[0] += result.addLeft!;
          result.addLeft = null;
        } else {
          bool addLeft(List next) {
            if (next[1] is int) {
              next[1] += result.addLeft!;
              result.addLeft = null;
              return true;
            } else {
              if (addLeft(next[1] as List)) return true;
            }
            if (next[0] is int) {
              next[0] += result.addLeft!;
              result.addLeft = null;
              return true;
            } else {
              return addLeft(next[0] as List);
            }
          }

          addLeft(pair[0] as List);
        }
      }
    }
    if (result.addRight != null) {
      if (i == 0) {
        if (pair[1] is int) {
          pair[1] += result.addRight!;
          result.addRight = null;
        } else {
          bool addRight(List next) {
            if (next[0] is int) {
              next[0] += result.addRight!;
              result.addRight = null;
              return true;
            } else {
              if (addRight(next[0] as List)) return true;
            }
            if (next[1] is int) {
              next[1] += result.addRight!;
              result.addRight = null;
              return true;
            } else {
              return addRight(next[1] as List);
            }
          }

          addRight(pair[1] as List);
        }
      }
    }
    if (result.reduced) return result;
  }

  return ReduceResult(false);
}

// Performs splits
ReduceResult split(List pair, List parent, int index) {
  for (var i = 0; i < pair.length; i++) {
    var entry = pair[i];
    if (entry is! int) {
      var result = split(entry, pair, i);
      if (result.reduced) return result;
    } else if (entry >= 10) {
      pair[i] = <Object>[
        (entry / 2).floor(),
        (entry / 2).ceil(),
      ];
      return ReduceResult(true);
    }
  }
  return ReduceResult(false);
}

int magnitude(List pair) {
  var left = pair[0];
  var right = pair[1];
  var leftMagnitude = left is List ? magnitude(left) : left as int;
  var rightMagnitude = right is List ? magnitude(right) : right as int;
  return 3 * leftMagnitude + 2 * rightMagnitude;
}

class ReduceResult {
  int? addLeft;
  int? addRight;
  final bool reduced;

  ReduceResult(this.reduced, {this.addLeft, this.addRight});
}
