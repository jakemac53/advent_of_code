import 'dart:io';
import 'dart:math' as math;

const day = 22;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<Instruction> readInstructions() => [
      for (var line in lines) Instruction.parse(line),
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var normalizedInstructions = [
    for (var i in readInstructions())
      Instruction(
          i.state,
          Range(math.max(i.x.start, -50) + 50, math.min(i.x.end, 50) + 50),
          Range(math.max(i.y.start, -50) + 50, math.min(i.y.end, 50) + 50),
          Range(math.max(i.z.start, -50) + 50, math.min(i.z.end, 50) + 50)),
  ];
  var cube = List.generate(
      101, (x) => List.generate(101, (y) => List.filled(101, State.off)));
  for (var instruction in normalizedInstructions) {
    for (var x = instruction.x.start; x <= instruction.x.end; x++) {
      for (var y = instruction.y.start; y <= instruction.y.end; y++) {
        for (var z = instruction.z.start; z <= instruction.z.end; z++) {
          cube[x][y][z] = instruction.state;
        }
      }
    }
  }
  var count = 0;
  for (var x in cube) {
    for (var y in x) {
      for (var z in y) {
        if (z == State.on) count++;
      }
    }
  }
  return count;
}

int part2() {
  // Split up instructions so they don't overlap
  var instructions = readInstructions();
  for (var i = 0; i < instructions.length; i++) {
    var curr = instructions[i];
    var hadOverlap = false;
    for (var j = i - 1; j >= 0; j--) {
      var prev = instructions[j];
      var overlap = curr.computeOverlap(prev);
      if (overlap == null) continue;
      hadOverlap = true;

      var newCurr = curr
          .remove(overlap)
          .map((cube) => Instruction.fromCube(curr.state, cube))
          .followedBy([Instruction.fromCube(curr.state, overlap)]);
      instructions.replaceRange(i, i + 1, newCurr);
      i--; // may need to keep splitting, revist this one

      var newPrev = prev
          .remove(overlap)
          .map((cube) => Instruction.fromCube(prev.state, cube));
      instructions.replaceRange(j, j + 1, newPrev);
      i += newPrev.length - 1;
      break;
    }
    // Remove all off states.
    if (!hadOverlap && curr.state == State.off) {
      instructions.removeAt(i);
      i--;
    }
  }

  var total = 0;
  for (var i in instructions) {
    if (i.state == State.off) throw StateError('shouldnt happen!');
    total += (i.x.end - i.x.start + 1) *
        (i.y.end - i.y.start + 1) *
        (i.z.end - i.z.start + 1);
  }
  return total;
}

class Instruction extends Cube {
  final State state;

  Instruction(this.state, Range x, Range y, Range z) : super(x, y, z);
  Instruction.fromCube(this.state, Cube cube) : super(cube.x, cube.y, cube.z);

  factory Instruction.parse(String line) {
    var parts = line.split(' ');
    var action = parts.first == 'on' ? State.on : State.off;
    var rangeParts = parts[1].split(',');
    var x = Range.parse(rangeParts[0].substring(2));
    var y = Range.parse(rangeParts[1].substring(2));
    var z = Range.parse(rangeParts[2].substring(2));
    return Instruction(action, x, y, z);
  }

  String toString() =>
      '${state == State.on ? 'on' : 'off'} ${super.toString()}';
}

class Cube {
  final Range x;
  final Range y;
  final Range z;

  Cube(this.x, this.y, this.z);

  Cube? computeOverlap(Cube other) {
    var xOverlap = x.computeOverlap(other.x);
    if (xOverlap == null) return null;
    var yOverlap = y.computeOverlap(other.y);
    if (yOverlap == null) return null;
    var zOverlap = z.computeOverlap(other.z);
    if (zOverlap == null) return null;
    return Cube(xOverlap, yOverlap, zOverlap);
  }

  /// Returns a list of [Cube]s which represent the same area as this cube but
  /// with [other] removed.
  ///
  /// Note that [other] must be fully contained by this cube.
  List<Cube> remove(Cube other) {
    var xParts = [
      if (x.start < other.x.start) Range(x.start, other.x.start - 1),
      other.x,
      if (x.end > other.x.end) Range(other.x.end + 1, x.end),
    ];
    var yParts = [
      if (y.start < other.y.start) Range(y.start, other.y.start - 1),
      other.y,
      if (y.end > other.y.end) Range(other.y.end + 1, y.end),
    ];
    var zParts = [
      if (z.start < other.z.start) Range(z.start, other.z.start - 1),
      other.z,
      if (z.end > other.z.end) Range(other.z.end + 1, z.end),
    ];
    // Some of these could be merged, can optimize later if needed.
    return [
      for (var xPart in xParts)
        for (var yPart in yParts)
          for (var zPart in zParts)
            if (!(xPart == other.x && yPart == other.y && zPart == other.z))
              Cube(xPart, yPart, zPart),
    ];
  }

  String toString() => 'x:$x,y:$y,z:$z';
}

class Range {
  final int start;
  final int end;

  Range(this.start, this.end);

  factory Range.parse(String range) {
    var parts = range.split('..');
    return Range(int.parse(parts[0]), int.parse(parts[1]));
  }

  Range? computeOverlap(Range other) {
    if (start >= other.start && start <= other.end) {
      return Range(start, math.min(end, other.end));
    } else if (other.start >= start && other.start <= end) {
      return Range(other.start, math.min(end, other.end));
    }
    return null;
  }

  bool operator ==(other) =>
      other is Range && other.start == start && other.end == end;

  String toString() => '$start..$end';
}

enum State {
  on,
  off,
}
