import 'dart:io';
import 'dart:math' as math;
import 'dart:developer';

import 'package:collection/collection.dart';

import 'util.dart';

const day = 23;

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

const roomCols = [2, 4, 6, 8];
const hallwaySpots = [0, 1, 3, 5, 7, 9, 10];

int part1() {
  final lines = File('lib/day_${day}_part_1_input.txt').readAsLinesSync()
    ..removeWhere((element) => element.isEmpty);
  return cheapestSolve(lines);
}

int part2() {
  final lines = File('lib/day_${day}_part_2_input.txt').readAsLinesSync()
    ..removeWhere((element) => element.isEmpty);
  return cheapestSolve(lines);
}

int cheapestSolve(List<String> lines) {
  final level = [
    for (var line in lines)
      [
        for (var char in line.chars) char,
      ],
  ];
  var queue = PriorityQueue<State>((a, b) => a.extraCost - b.extraCost);
  var roomDepth = level.length - 3;
  var initialState = State([
    for (var x in roomCols)
      for (var y = 0; y < roomDepth; y++) ...[
        if (level[y + 2][x + 1] == amber) Amber(Position(x, y + 1)),
        if (level[y + 2][x + 1] == bronze) Bronze(Position(x, y + 1)),
        if (level[y + 2][x + 1] == copper) Copper(Position(x, y + 1)),
        if (level[y + 2][x + 1] == desert) Desert(Position(x, y + 1)),
      ],
  ]);

  // Mark all the amphipods that are already done moving so they can be
  // skipped cheaply later.
  for (var i = 0; i < initialState.amphipods.length; i++) {
    var pod = initialState.amphipods[i];
    if (reachedDestination(pod, initialState, roomDepth)) {
      initialState.amphipods[i] = pod.copy(reachedDestination: true);
    }
  }

  queue.add(initialState);
  while (true) {
    var next = queue.removeFirst();
    if (next.isComplete) {
      return next.cost;
    }

    // Otherwise fork it into all possible moves from this state, and add each
    // to the queue;
    for (var pod in next.amphipods) {
      if (pod.reachedDestination) continue;
      for (var destination in validDestinations(pod, next, roomDepth)) {
        var copy = next.copy();
        copy.amphipods
          ..remove(pod)
          ..add(pod.move(destination));
        queue.add(copy);
      }
    }
  }
}

bool reachedDestination(Amphipod pod, State state, int roomDepth) {
  if (pod.position.x != pod.destinationCol) return false;

  // We are at the bottom of the room
  if (pod.position.y == roomDepth) return true;

  // All amphipods below us are also in their desitination room
  if (state[pod.position.x].every((p) =>
      p.reachedDestination ||
      p.position.y < pod.position.y ||
      p.destinationCol == p.position.x)) {
    return true;
  }

  return false;
}

Iterable<Position> validDestinations(
    Amphipod pod, State state, int roomDepth) sync* {
  // In a room, first try to move into hallways
  if (pod.position.y > 0) {
    // Stuck behind another one, can't move.
    if (state[pod.position.x].any((p) => p.position.y < pod.position.y)) {
      return;
    }

    // Can only move into hallways if we haven't moved yet
    if (pod.distanceMoved == 0) {
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
  } else {
    // In a hallway, try to move into a room

    // All the destination room amphipods
    var destRoomPods = state[pod.destinationCol];

    // Otherwise move into destination room, if possible.
    int destinationY;
    if (destRoomPods.length == roomDepth) {
      // it's full
      return;
    } else if (destRoomPods.any((p) => p.destinationCol != p.position.x)) {
      // Can only move in if all existing ones are in their destination room.
      return;
    } else {
      // Go as far down as possible into the room.
      destinationY = roomDepth - destRoomPods.length;
    }

    // see if we can make it to the desired point.
    var dir = pod.destinationCol < pod.position.x ? -1 : 1;
    for (var x = pod.position.x + dir;
        x != pod.destinationCol + dir;
        x += dir) {
      if (!hallwaySpots.contains(x)) continue;
      if (state[x].isNotEmpty) return;
    }
    // Didn't bail out so we can make it to the destination.
    yield Position(pod.destinationCol, destinationY);
  }
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

  final _rowCache = List<List<Amphipod>?>.filled(11, null);
  Iterable<Amphipod> operator [](int index) => _rowCache[index] ??= [
        for (var pod in amphipods)
          if (pod.position.x == index) pod,
      ];

  late int cost = amphipods.fold(0,
      (total, amphipod) => total += amphipod.distanceMoved * amphipod.moveCost);

  late int extraCost = amphipods.fold(
      0,
      (total, amphipod) =>
          total += amphipod.extraDistanceMoved * amphipod.moveCost);

  bool get isComplete => amphipods.every((p) => p.reachedDestination);

  State copy() => State(amphipods.toList());

  @override
  String toString() {
    var level = [
      '#############'.chars,
      '#...........#'.chars,
      '###.#.#.#.###'.chars,
      '  #.#.#.#.#'.chars,
      '  #.#.#.#.#'.chars,
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
  final int distanceMoved;
  final int extraDistanceMoved;
  final Position position;
  final bool reachedDestination;
  int get destinationCol;
  int get moveCost;

  Amphipod(this.position,
      {this.distanceMoved = 0,
      this.extraDistanceMoved = 0,
      this.reachedDestination = false});

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
    // Adjust the extra distance moved if we are moving out of a room,
    // because we would only do that if it was required to make room
    // for another amphipod (its a required move).
    var adjustment = position.y > 0 ? position.y + 1 : 0;
    extraDistance = math.max(extraDistance - adjustment, extraDistance);
    return copy(
        distanceMoved: distance + distanceMoved,
        // doubled to account for moving back
        extraDistanceMoved: extraDistanceMoved + extraDistance * 2,
        position: to,
        reachedDestination: to.y > 0 ? true : false);
  }

  Amphipod copy(
      {int? distanceMoved,
      int? extraDistanceMoved,
      Position? position,
      bool? reachedDestination});

  String toString() => '$runtimeType: $position';
}

class Amber extends Amphipod {
  int get moveCost => 1;
  int get destinationCol => 2;

  Amber(Position position,
      {int distanceMoved = 0,
      int extraDistanceMoved = 0,
      bool reachedDestination = false})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved,
            reachedDestination: reachedDestination);

  Amber copy(
          {int? distanceMoved,
          int? extraDistanceMoved,
          Position? position,
          bool? reachedDestination}) =>
      Amber(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved,
          reachedDestination: reachedDestination ?? this.reachedDestination);
}

class Bronze extends Amphipod {
  int get moveCost => 10;
  int get destinationCol => 4;

  Bronze(Position position,
      {int distanceMoved = 0,
      int extraDistanceMoved = 0,
      bool reachedDestination = false})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved,
            reachedDestination: reachedDestination);

  Bronze copy(
          {int? distanceMoved,
          int? extraDistanceMoved,
          Position? position,
          bool? reachedDestination}) =>
      Bronze(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved,
          reachedDestination: reachedDestination ?? this.reachedDestination);
}

class Copper extends Amphipod {
  int get moveCost => 100;
  int get destinationCol => 6;

  Copper(Position position,
      {int distanceMoved = 0,
      int extraDistanceMoved = 0,
      bool reachedDestination = false})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved,
            reachedDestination: reachedDestination);

  Copper copy(
          {int? distanceMoved,
          int? extraDistanceMoved,
          Position? position,
          bool? reachedDestination}) =>
      Copper(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved,
          reachedDestination: reachedDestination ?? this.reachedDestination);
}

class Desert extends Amphipod {
  int get moveCost => 1000;
  int get destinationCol => 8;

  Desert(Position position,
      {int distanceMoved = 0,
      int extraDistanceMoved = 0,
      bool reachedDestination = false})
      : super(position,
            distanceMoved: distanceMoved,
            extraDistanceMoved: extraDistanceMoved,
            reachedDestination: reachedDestination);

  Desert copy(
          {int? distanceMoved,
          int? extraDistanceMoved,
          Position? position,
          bool? reachedDestination}) =>
      Desert(position ?? this.position,
          distanceMoved: distanceMoved ?? this.distanceMoved,
          extraDistanceMoved: extraDistanceMoved ?? this.extraDistanceMoved,
          reachedDestination: reachedDestination ?? this.reachedDestination);
}

class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  String toString() => '($x,$y)';
}
