import 'dart:io';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    final links = <String, Link>{};

    for (var i = 1; i < input.length; i++) {
      var line = input[i];
      var [key, linkStr] = line.split(' = ');
      var [left, right] = linkStr.substring(1, linkStr.length - 1).split(', ');
      links[key] = (left: left, right: right);
    }
    var instructions = input.first;
    var current = 'AAA';
    var steps = 0;
    var i = 0;
    while (current != 'ZZZ') {
      steps++;
      switch (instructions[i]) {
        case 'L':
          current = links[current]!.left;
        case 'R':
          current = links[current]!.right;
        default:
          throw StateError('not L or R (${instructions[i]})');
      }
      i++;
      if (i == instructions.length) i = 0;
    }

    print('part 1: $steps');
  }

  // Part 2
  {
    final links = <String, Link>{};

    for (var i = 1; i < input.length; i++) {
      var line = input[i];
      var [key, linkStr] = line.split(' = ');
      var [left, right] = linkStr.substring(1, linkStr.length - 1).split(', ');
      links[key] = (left: left, right: right);
    }
    var instructions = input.first;
    var startPoints = links.keys.where((key) => key.endsWith('A')).toList();

    var results = <int>[]; // cycle sizes for each input
    for (var current in startPoints) {
      var steps = 0;
      var i = 0;
      var lastSeen = <({String node, int instruction}), int>{};
      while (true) {
        if (current.endsWith('Z')) {
          var description = (node: current, instruction: i);
          var last = lastSeen[description];
          if (last != null) {
            results.add(steps - last);
            break;
          } else {
            lastSeen[description] = steps;
          }
        }

        switch (instructions[i]) {
          case 'L':
            current = links[current]!.left;
          case 'R':
            current = links[current]!.right;
          default:
            throw StateError('not L or R (${instructions[i]})');
        }
        i++;
        if (i == instructions.length) i = 0;
        steps++;
      }
    }
    // now find least common multiple in results
    var lcm = results
        .skip(1)
        .fold<int>(results.first, (a, b) => leastCommonMultiple(a, b));
    print('part 2: $lcm');
  }
}

typedef Link = ({String left, String right});

int leastCommonMultiple(int a, int b) =>
    (a * b) ~/ greatestCommonDenominator(a, b);

int greatestCommonDenominator(int a, int b) {
  while (b != 0) {
    var t = b;
    b = a % t;
    a = t;
  }
  return a;
}
