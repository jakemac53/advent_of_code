import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'util.dart';

const day = 23;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final level = [
  for (var line in lines)
    [
      for (var char in line.chars) char,
    ],
];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

const roomCols = [2, 4, 6, 8];
const roomSpots = [1, 2];
const hallwaySpots = [0, 1, 3, 5, 7, 9, 10];

int part1() {
  var queue = PriorityQueue<State>((a, b) => a.extraCost - b.extraCost);

  queue.add(State([
    for (var x in roomCols)
      for (var y in roomSpots) ...[
        if (level[y + 1][x + 1] == amber) Amber(Position(x, y)),
        if (level[y + 1][x + 1] == bronze) Bronze(Position(x, y)),
        if (level[y + 1][x + 1] == copper) Copper(Position(x, y)),
        if (level[y + 1][x + 1] == desert) Desert(Position(x, y)),
      ],
  ]));
  while (true) {
    var next = queue.removeFirst();
    if (next.isComplete) {
      return next.cost;
    }
    // Otherwise fork it into all possible moves from this state, and add each
    // to the queue;
    for (var pod in next.amphipods) {
      for (var destination in validDestinations(pod, next)) {
        var copy = next.copy();
        copy.amphipods
          ..remove(pod)
          ..add(pod.move(destination));
        queue.add(copy);
      }
    }
  }
}

int part2() {
  return 0;
}

Iterable<Position> validDestinations(Amphipod pod, State state) sync* {
  // Could have one or zero other pods in our room.
  var sameColPod = state[pod.position.x].firstWhereOrNull((p) => p != pod);

  // Check if this pod is done moving
  if (pod.position.x == pod.destinationCol) {
    if (pod.position.y == 2) return;
    // Should never have empty spots below
    if (sameColPod!.destinationCol == sameColPod.position.x) return;
  }

  // Stuck behind another one, can't move.
  if (pod.position.y == 2 && sameColPod != null) return;

  // cache the destination room pods
  var destRoomPods = state[pod.destinationCol].toList();

  // Can move into hallways
  if (pod.distanceMoved == null) {
    // move left
    for (var x
        in hallwaySpots.reversed.where((spot) => spot < pod.position.x)) {
      // Can't go through other pods
      if (state[x].isNotEmpty) break;
      yield Position(x, 0);
    }
    // move right
    for (var x in hallwaySpots.where((spot) => spot > pod.position.x)) {
      // Can't go through other pods
      if (state[x].isNotEmpty) break;
      yield Position(x, 0);
    }
  }
  // Otherwise move into destination room, if possible.
  int destinationY;
  switch (destRoomPods.length) {
    case 0:
      destinationY = 2;
      break;
    case 1:
      // can only move in if the other is in its expected spot
      if (destRoomPods.single.destinationCol != pod.destinationCol) return;
      destinationY = 1;
      break;
    case 2:
      // its full
      return;
    default:
      throw StateError('unreachable');
  }
  // see if we can make it to the desired point.
  var dir = pod.destinationCol < pod.position.x ? -1 : 1;
  for (var x = pod.position.x + dir; x != pod.destinationCol + dir; x += dir) {
    if (!hallwaySpots.contains(x)) continue;
    if (state[x].isNotEmpty) return;
  }
  // Didn't bail out so we can make it to the destination.
  yield Position(pod.destinationCol, destinationY);
}

const wall = '#';
const floor = '.';
const amber = 'A';
const bronze = 'B';
const copper = 'C';
const desert = 'D';

class State {
  final List<Amphipod> amphipods;

  State(this.amphipods);

  Iterable<Amphipod> operator [](int index) =>
      amphipods.where((pod) => pod.position.x == index);

  int get cost => amphipods.fold(
      0,
      (total, amphipod) =>
          total += (amphipod.distanceMoved ?? 0) * amphipod.moveCost);

  int get extraCost => amphipods.fold(
      0,
      (total, amphipod) =>
          total += amphipod.extraDistanceMoved * amphipod.moveCost);

  bool get isComplete =>
      amphipods.every((a) => a.position.x == a.destinationCol);

  State copy() => State(amphipods.toList());

  @override
  String toString() {
    var level = [
      '#############'.chars,
      '#...........#'.chars,
      '###.#.#.#.###'.chars,
      '  #.#.#.#.#'.chars,
      '  #########'.chars,
    ];
    for (var pod in amphipods) {
      var letter = pod is Amber
          ? amber
          : pod is Bronze
              ? bronze
              : pod is Copper
                  ? copper
                  : desert;
      level[pod.position.y + 1][pod.position.x + 1] = letter;
    }
    return '''
cost: $cost
extraCost: $extraCost
${level.map((l) => l.join('')).join('\n')}''';
  }
}

abstract class Amphipod {
  final int? distanceMoved;
  final int extraDistanceMoved;
  final Position position;
  int get destinationCol;
  int get moveCost;

  Amphipod(this.position, {this.distanceMoved, this.extraDistanceMoved = 0});

  Amphipod move(Position to) {
    var distance = 0;
    distance += (to.x - position.x).abs();
    if (to.x != position.x) {
      distance += position.y + to.y;
    }
    var beforeDestColDist = destinationCol - position.x;
    var afterDestColDist = destinationCol - to.x;
    var extraDistance = 0;
    if (beforeDestColDist > 0) {
      if (afterDestColDist > beforeDestColDist) {
        // moving wrong direction
        extraDistance = afterDestColDist - beforeDestColDist;
      } else if (afterDestColDist < 0) {
        // overshoot to the right
        extraDistance = afterDestColDist.abs();
      }
    } else {
      if (afterDestColDist < beforeDestColDist) {
        // moving wrong direction
        extraDistance = (afterDestColDist - beforeDestColDist).abs();
      } else if (afterDestColDist > 0) {
        // overshoot to the left
        extraDistance = afterDestColDist;
      }
    }
    // Adjust the extra distance moved by subtracting 2 if we are moving from
    // y position 1, because we would only do that if it was required to make
    // room for another amphipod.
    var adjustment = position.y == 1 ? 2 : 0;
    extraDistance = math.max(extraDistance - adjustment, extraDistance);
    return copy(
        distanceMoved: distance + (distanceMoved ?? 0),
        // doubled to account for moving back
        extraDistanceMoved: extraDistanceMoved + extraDistance * 2,
        position: to);
  }

  Amphipod copy(
      {int? distanceMoved, int? extraDistanceMoved, Position? position});

  String toString() => '$runtimeType: $position';
}

class Amber extends Amphipod {
  int get moveCost => 1;
  int get destinationCol => 2;

  Amber(Position position, {int? distanceMoved, int extraDistanceMoved = 0})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved);

  Amber copy(
          {int? distanceMoved, int? extraDistanceMoved, Position? position}) =>
      Amber(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved);
}

class Bronze extends Amphipod {
  int get moveCost => 10;
  int get destinationCol => 4;

  Bronze(Position position, {int? distanceMoved, int extraDistanceMoved = 0})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved);

  Bronze copy(
          {int? distanceMoved, int? extraDistanceMoved, Position? position}) =>
      Bronze(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved);
}

class Copper extends Amphipod {
  int get moveCost => 100;
  int get destinationCol => 6;

  Copper(Position position, {int? distanceMoved, int extraDistanceMoved = 0})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved);

  Copper copy(
          {int? distanceMoved, int? extraDistanceMoved, Position? position}) =>
      Copper(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved);
}

class Desert extends Amphipod {
  int get moveCost => 1000;
  int get destinationCol => 8;

  Desert(Position position, {int? distanceMoved, int extraDistanceMoved = 0})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved);

  Desert copy(
          {int? distanceMoved, int? extraDistanceMoved, Position? position}) =>
      Desert(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved);
}

class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  String toString() => '($x,$y)';
}
