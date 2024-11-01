import 'dart:io';
import 'dart:math' as math;

const day = 17;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final targetArea = TargetArea.parse(lines.single);

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  int maxVelocity;
  if (targetArea.minY < 0 && targetArea.maxY > 0) {
    throw StateError('Infinity!');
  } else if (targetArea.minY > 0) {
    maxVelocity = targetArea.maxY;
  } else {
    assert(targetArea.minY < 0);
    maxVelocity = (targetArea.minY + 1).abs();
  }
  // Technically might not be a valid `x` for all these velocities? But probably
  // can ignore that.
  return (maxVelocity * ((maxVelocity + 1) / 2)).toInt();
}

int part2() {
  int maxYVelocity;
  if (targetArea.minY < 0 && targetArea.maxY > 0) {
    throw StateError('Infinity!');
  } else if (targetArea.minY > 0) {
    maxYVelocity = targetArea.maxY;
  } else {
    assert(targetArea.minY < 0);
    maxYVelocity = (targetArea.minY + 1).abs();
  }

  int minYVelocity;
  if (targetArea.minY < 0) {
    minYVelocity = targetArea.minY;
  } else {
    minYVelocity = solveQuadratic(0.5, 0.5, -targetArea.minY).ceil();
  }

  var maxXVelocity = targetArea.maxX;
  var minXVelocity = solveQuadratic(0.5, 0.5, -targetArea.minX).ceil();

  var countVelocities = 0;
  // Brute force, but works for our input.
  for (var yVelocity = minYVelocity; yVelocity <= maxYVelocity; yVelocity++) {
    var yOverlaps =
        overlapSteps(yVelocity, targetArea.minY, targetArea.maxY, true);
    if (yOverlaps.isNotEmpty) {
      for (var xVelocity = minXVelocity;
          xVelocity <= maxXVelocity;
          xVelocity++) {
        var xOverlaps =
            overlapSteps(xVelocity, targetArea.minX, targetArea.maxX, false);
        if (yOverlaps.intersection(xOverlaps).isNotEmpty ||
            (xOverlaps.contains(xVelocity) &&
                yOverlaps.any((day) => day >= xVelocity))) {
          countVelocities++;
        }
      }
    }
  }

  return countVelocities;
}

/// For a given velocity, all the steps in which it falls between the range
/// [min]..[max] inclusive.
Set<int> overlapSteps(int velocity, int min, int max, bool allowNegativeVel) {
  var step = 0;
  var pos = 0;
  var result = <int>{};
  while (allowNegativeVel
      ? (velocity >= 0 || pos >= min)
      : pos <= max && velocity >= 0) {
    if (pos >= min && pos <= max) {
      result.add(step);
    }
    pos += velocity;
    step++;
    velocity--;
  }
  return result;
}

double solveQuadratic(num a, num b, num c) {
  return ((-b) + math.sqrt(math.pow(b, 2) - 4 * a * c)) / (2 * a);
}

class TargetArea {
  final int minX;
  final int maxX;
  final int minY;
  final int maxY;

  TargetArea({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  factory TargetArea.parse(String line) {
    line = line.substring(line.indexOf('x='));
    var parts = line.split(', ');
    var x = parts[0].substring('x='.length);
    var y = parts[1].substring('y='.length);
    var xParts = x.split('..');
    var yParts = y.split('..');
    return TargetArea(
      minX: int.parse(xParts[0]),
      maxX: int.parse(xParts[1]),
      minY: int.parse(yParts[0]),
      maxY: int.parse(yParts[1]),
    );
  }
}
