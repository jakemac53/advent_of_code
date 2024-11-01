import 'dart:io';
import 'dart:math';

final input = File('lib/day_2.input.txt').readAsLinesSync();

void main() {
  // Game => Selections => color : amount
  final games = <List<Map<String, int>>>[];
  for (var i = 0; i < input.length; i++) {
    var line = input[i];
    if (line.isEmpty) continue;
    final prefix = 'Game ${i + 1}: ';
    if (!line.startsWith(prefix)) {
      throw StateError(
          'unrecognized line $line, expected it to start with `Game ${i + 1}: `');
    }
    line = line.substring(prefix.length);
    games.add([
      for (final group in line.split('; '))
        <String, int>{
          for (final [count, color]
              in group.split(', ').map((str) => str.split(' ')))
            color: int.parse(count),
        },
    ]);
  }

  // Part 1
  {
    var sum = 0;
    for (var i = 0; i < games.length; i++) {
      final game = games[i];
      if (game.every((group) =>
          (group['red'] ?? 0) <= 12 &&
          (group['green'] ?? 0) <= 13 &&
          (group['blue'] ?? 0) <= 14)) {
        sum += i + 1;
      }
    }
    print('part 1: $sum');
  }

  // Part 2
  {
    var sum = 0;
    for (var i = 0; i < games.length; i++) {
      final game = games[i];
      var minRed = 0;
      var minGreen = 0;
      var minBlue = 0;
      for (var group in game) {
        minRed = max(minRed, group['red'] ?? 0);
        minGreen = max(minGreen, group['green'] ?? 0);
        minBlue = max(minBlue, group['blue'] ?? 0);
      }
      final power = minRed * minGreen * minBlue;
      sum += power;
    }
    print('part 2: $sum');
  }
}
