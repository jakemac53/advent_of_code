import 'dart:io';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    late final Point start;

    outer:
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        if (line[x] == 'S') {
          start = (x: x, y: y);
          break outer;
        }
      }
    }

    // Start should have exactly two connections
    var [a, b] = start.connectedPipes
        .where((p) => p.isValid && input.areConnected(start, p))
        .toList();
    var distance = 1;
    var previous = (a: start, b: start);
    var current = (a: a, b: b);
    var seen = <Point>{start};
    while (true) {
      if (!seen.add(current.a) || !seen.add(current.b)) {
        // overlapped
        if (current.a != current.b) distance--;
        break;
      }
      var nextA = current.a.nextConnection(previous.a);
      var nextB = current.b.nextConnection(previous.b);
      previous = current;
      current = (a: nextA, b: nextB);
      distance++;
    }

    print('part 1: $distance');
  }

  // Part 2
  {
    late final Point start;

    outer:
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        if (line[x] == 'S') {
          start = (x: x, y: y);
          break outer;
        }
      }
    }

    final gridStates = [
      for (var y = 0; y < input.length; y++)
        <GridState?>[
          for (var x = 0; x < input[y].length; x++) null,
        ],
    ];
    gridStates[start.y][start.x] = GridState.mainPath;

    // Mark the entire main path in the grid, and also record the path.
    var mainPath = [start];
    {
      // Start from the first connection we find from `start`.
      var previous = start;
      var next = start.connectedPipes
          .where((p) => p.isValid && input.areConnected(start, p))
          .first;
      while (next != start) {
        mainPath.add(next);
        gridStates[next.y][next.x] = GridState.mainPath;
        var temp = next;
        next = next.nextConnection(previous);
        previous = temp;
      }
    }

    // Figure out if the "left" or "right" side of the path is encapsulated.
    //
    // Copy the current grid state to use here, these values are incorrect
    // because they don't take into account "squeezing through".
    late final Dir leftOrRight;
    {
      final tempStates = [
        for (var y = 0; y < input.length; y++) gridStates[y].toList(),
      ];
      var previous = start;
      outer:
      for (var point in mainPath.skip(1)) {
        for (var l in point.leftPoints(previous)) {
          if (computeState(l, tempStates) == GridState.outside) {
            leftOrRight = Dir.right;
            break outer;
          }
        }

        for (var r in point.rightPoints(previous)) {
          if (computeState(r, tempStates) == GridState.outside) {
            leftOrRight = Dir.left;
            break outer;
          }
        }
        previous = point;
      }
    }

    // Seed the graph with known parts.
    {
      var previous = start;
      for (var current in mainPath.skip(1)) {
        var encapsulated = switch (leftOrRight) {
          Dir.left => current.leftPoints(previous),
          Dir.right => current.rightPoints(previous),
        };
        for (var point in encapsulated) {
          gridStates[point.y][point.x] ??= GridState.encapsulated;
        }
        var outside = switch (leftOrRight) {
          Dir.left => current.rightPoints(previous),
          Dir.right => current.leftPoints(previous),
        };
        for (var point in outside) {
          gridStates[point.y][point.x] ??= GridState.outside;
        }
        previous = current;
      }
    }

    // Fill in remaining pieces
    for (var y = 0; y < gridStates.length; y++) {
      var line = gridStates[y];
      for (var x = 0; x < line.length; x++) {
        computeState((x: x, y: y), gridStates);
      }
    }
    printStates(gridStates);

    // Calculate total
    var total = 0;
    for (var y = 0; y < gridStates.length; y++) {
      var line = gridStates[y];
      for (var x = 0; x < line.length; x++) {
        if (line[x] == GridState.encapsulated) total++;
      }
    }

    print('part 2: $total');
  }
}

/// Computes the [GridState] for [Point] and all points it touches that are not
/// a part of the main path (must already be marked as such in [gridStates]).
///
/// Note: Does not take into account squeezing through gaps!
GridState computeState(Point point, List<List<GridState?>> gridStates) {
  if (gridStates[point.y][point.x] != null) {
    return gridStates[point.y][point.x]!;
  }
  final seen = <Point>{point};
  final queue = <Point>[point];
  GridState? state;
  outer:
  while (queue.isNotEmpty) {
    var current = queue.removeLast();

    switch (gridStates[current.y][current.x]) {
      case null:
        break;
      case GridState.encapsulated:
        state = GridState.encapsulated;
        break outer;
      case GridState.outside:
        state = GridState.outside;
        break outer;
      case GridState.mainPath:
        throw StateError('shouldnt get these added to queue');
    }

    // Crawl all normal surrounding spaces
    for (var x = -1; x < 2; x++) {
      for (var y = -1; y < 2; y++) {
        var next = (x: x, y: y) + current;
        if (next == current) continue;

        if (!next.isValid) {
          state = GridState.outside;
          continue;
        }

        if (gridStates[next.y][next.x] != GridState.mainPath &&
            seen.add(next)) {
          queue.add(next);
          continue;
        }
      }
    }
  }
  // If we didn't set it to something else, we are encapsulated.
  state ??= GridState.encapsulated;
  // Set the discovered state for all the points.
  for (var point in seen) {
    gridStates[point.y][point.x] = state;
  }
  return state;
}

void printStates(List<List<GridState?>> states) {
  var buffer = StringBuffer();
  for (var y = 0; y < states.length; y++) {
    var line = states[y];
    for (var x = 0; x < line.length; x++) {
      switch (line[x]) {
        case null:
          buffer.write('?');
        case GridState.encapsulated:
          buffer.write('I');
        case GridState.outside:
          buffer.write('O');
        case GridState.mainPath:
          buffer.write(input[y][x]);
      }
    }
    buffer.writeln();
  }
  print(buffer);
}

typedef Point = ({int x, int y});

extension on List<String> {
  String point(Point point) => input[point.y][point.x];

  bool areConnected(Point a, Point b) {
    return a.connectedPipes.contains(b) && b.connectedPipes.contains(a);
  }
}

extension on Point {
  Point operator +(Point other) => (x: x + other.x, y: y + other.y);

  bool get isValid =>
      x >= 0 && x < input.first.length && y >= 0 && y < input.length;

  Iterable<Point> get connectedPipes =>
      connections[input.point(this)]!.map((c) => this + c);

  Point nextConnection(Point previous) =>
      connectedPipes.singleWhere((p) => p != previous);

  Iterable<Point> leftPoints(Point previous) => switch (input[y][x]) {
        '|' when previous == up + this => const [right],
        '|' when previous == down + this => const [left],
        '-' when previous == left + this => const [up],
        '-' when previous == right + this => const [down],
        'L' when previous == up + this => const [],
        'L' when previous == right + this => const [left, down],
        'J' when previous == up + this => const [right, down],
        'J' when previous == left + this => const [],
        '7' when previous == left + this => const [up, right],
        '7' when previous == down + this => const [],
        'F' when previous == right + this => const [],
        'F' when previous == down + this => const [left, up],
        _ => throw StateError('expected a pipe, got ${input[y][x]} $this'),
      }
          .map((p) => this + p)
          .where((p) => p.isValid);

  Iterable<Point> rightPoints(Point previous) => switch (input[y][x]) {
        '|' when previous == up + this => const [left],
        '|' when previous == down + this => const [right],
        '-' when previous == left + this => const [down],
        '-' when previous == right + this => const [up],
        'L' when previous == up + this => const [left, down],
        'L' when previous == right + this => const [],
        'J' when previous == up + this => const [],
        'J' when previous == left + this => const [right, down],
        '7' when previous == left + this => const [],
        '7' when previous == down + this => const [up, right],
        'F' when previous == right + this => const [left, up],
        'F' when previous == down + this => const [],
        _ => throw StateError('expected a pipe, got ${input[y][x]}'),
      }
          .map((p) => this + p)
          .where((p) => p.isValid);
}

/// All the valid connection points for each type of pipe.
const connections = <String, List<Point>>{
  '|': [up, down], // vertical pipe
  '-': [left, right], // horizontal pipe
  'L': [up, right], // 90-degree bend connecting N/E
  'J': [up, left], // 90-degree bend connecting N/W
  '7': [down, left], // 90-degree bend connecting S/W
  'F': [down, right], // 90-degree bend connecting S/E
  '.': [], // Ground, no connections
  'S': [up, down, right, left], // Start, connects to everything
};

const up = (x: 0, y: -1);
const down = (x: 0, y: 1);
const left = (x: -1, y: 0);
const right = (x: 1, y: 0);

enum GridState {
  encapsulated,
  outside,
  mainPath,
}

enum Dir {
  left,
  right,
}
