import 'dart:io';

import 'util.dart';

const day = 11;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<List<Octopus>> readOctopi() => [
      for (var line in lines)
        [
          for (var char in line.chars) Octopus(int.parse(char)),
        ],
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var flashes = 0;
  var octopi = readOctopi();
  for (var i = 0; i < 100; i++) {
    var flashed = <Octopus>{};

    void energize(Octopus octopus, int r, int c) {
      octopus.energyLevel++;
      if (octopus.energyLevel < 10 || !flashed.add(octopus)) return;

      for (var dir in dirs) {
        var next = Coord(r + dir.row, c + dir.col);
        if (next.row < 0 ||
            next.row >= octopi.length ||
            next.col < 0 ||
            next.col >= octopi[next.row].length) {
          continue;
        }
        energize(octopi[next.row][next.col], next.row, next.col);
      }
    }

    for (var r = 0; r < octopi.length; r++) {
      for (var c = 0; c < octopi[r].length; c++) {
        energize(octopi[r][c], r, c);
      }
    }

    flashes += flashed.length;
    for (var octopus in flashed) {
      octopus.energyLevel = 0;
    }
  }
  return flashes;
}

int part2() {
  var octopi = readOctopi();
  var i = 0;
  while (true) {
    i++;
    var flashed = <Octopus>{};

    void energize(Octopus octopus, int r, int c) {
      octopus.energyLevel++;
      if (octopus.energyLevel < 10 || !flashed.add(octopus)) return;

      for (var dir in dirs) {
        var next = Coord(r + dir.row, c + dir.col);
        if (next.row < 0 ||
            next.row >= octopi.length ||
            next.col < 0 ||
            next.col >= octopi[next.row].length) {
          continue;
        }
        energize(octopi[next.row][next.col], next.row, next.col);
      }
    }

    for (var r = 0; r < octopi.length; r++) {
      for (var c = 0; c < octopi[r].length; c++) {
        energize(octopi[r][c], r, c);
      }
    }

    for (var octopus in flashed) {
      octopus.energyLevel = 0;
    }

    if (flashed.length == 100) {
      return i;
    }
  }
}

final dirs = [
  for (var r = -1; r <= 1; r++)
    for (var c = -1; c <= 1; c++)
      if (!(r == 0 && c == 0)) Coord(r, c),
];

class Octopus {
  int energyLevel;

  Octopus(this.energyLevel);
}
