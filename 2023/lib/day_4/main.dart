import 'dart:io';
import 'dart:math' as math;

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    var score = 0;
    for (var line in input) {
      var [_, trimmed] = line.split(': ');
      var [winning, mine] = trimmed
          .split('|')
          .map((part) => (part.split(' ')..removeWhere((p) => p.isEmpty))
              .map(int.parse)
              .toSet())
          .toList();
      var intersection = mine.intersection(winning);
      score += intersection.isEmpty
          ? 0
          : math.pow(2, intersection.length - 1).toInt();
    }
    print('part 1: $score');
  }

  // Part 2
  {
    var copies = List.filled(input.length, 1);
    for (var i = 0; i < input.length; i++) {
      var line = input[i];
      var [_, trimmed] = line.split(': ');
      var [winning, mine] = trimmed
          .split('|')
          .map((part) => (part.split(' ')..removeWhere((p) => p.isEmpty))
              .map(int.parse)
              .toSet())
          .toList();
      var intersection = mine.intersection(winning);
      for (var l = 0; l < intersection.length; l++) {
        copies[i + l + 1] += copies[i];
      }
    }
    var score = copies.fold(0, (a, b) => a + b);

    print('part 2: $score');
  }
}
