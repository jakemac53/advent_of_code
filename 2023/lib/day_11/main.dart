import 'dart:io';

final input =
    (File.fromUri(Platform.script.resolve('input.txt')).readAsLinesSync()
          ..removeWhere((l) => l.isEmpty))
        .map((s) => s.split(''))
        .toList();

void main() {
  var emptyRows = findEmptyRows(input);
  var emptyCols = findEmptyCols(input);
  var galaxies = findGalaxies(input);
  // Part 1
  {
    var total = 0;
    for (var a = 0; a < galaxies.length; a++) {
      var g = galaxies[a];
      for (var b = a; b < galaxies.length; b++) {
        total +=
            g.distanceTo(galaxies[b], emptyRows, emptyCols, distanceIfEmpty: 2);
      }
    }

    print('part 1: $total');
  }

  // Part 2
  {
    var total = 0;
    for (var a = 0; a < galaxies.length; a++) {
      var g = galaxies[a];
      for (var b = a; b < galaxies.length; b++) {
        total += g.distanceTo(galaxies[b], emptyRows, emptyCols,
            distanceIfEmpty: 1000000);
      }
    }
    print('part 2: $total');
  }
}

Set<int> findEmptyRows(List<List<String>> input) {
  var result = <int>{};
  for (var i = 0; i < input.length; i++) {
    var line = input[i];
    if (!line.contains('#')) result.add(i);
  }
  return result;
}

Set<int> findEmptyCols(List<List<String>> input) {
  var result = <int>{};
  for (var x = 0; x < input.first.length; x++) {
    var foundGalaxy = false;
    for (var y = 0; y < input.length; y++) {
      if (input[y][x] == '#') {
        foundGalaxy = true;
        break;
      }
    }
    if (!foundGalaxy) result.add(x);
  }
  return result;
}

List<List<String>> expandUniverse(List<List<String>> input) {
  var copy = [
    for (var line in input) line.toList(),
  ];
  // Expand the galaxy vertically
  for (var i = 0; i < copy.length; i++) {
    var line = copy[i];
    if (!line.contains('#')) {
      copy.insert(++i, List.filled(line.length, '.', growable: true));
    }
  }
  // Expand the galaxy horizontally
  for (var x = 0; x < copy.first.length; x++) {
    var foundGalaxy = false;
    for (var y = 0; y < copy.length; y++) {
      if (copy[y][x] == '#') {
        foundGalaxy = true;
        break;
      }
    }
    if (!foundGalaxy) {
      for (var y = 0; y < copy.length; y++) {
        copy[y].insert(x, '.');
      }
      x++;
    }
  }
  return copy;
}

void printUniverse(List<List<String>> universe) {
  var buffer = StringBuffer();
  for (var y = 0; y < universe.length; y++) {
    var line = universe[y];
    for (var x = 0; x < line.length; x++) {
      buffer.write(line[x]);
    }
    buffer.writeln();
  }
  print(buffer);
}

typedef Point = ({int x, int y});

List<Point> findGalaxies(List<List<String>> universe) {
  var result = <Point>[];
  for (var y = 0; y < universe.length; y++) {
    for (var x = 0; x < universe.first.length; x++) {
      if (universe[y][x] == '#') result.add((x: x, y: y));
    }
  }
  return result;
}

extension on Point {
  int distanceTo(Point other, Set<int> emptyRows, Set<int> emptyCols,
      {required int distanceIfEmpty}) {
    var (startX, endX) = x > other.x ? (other.x, x) : (x, other.x);
    var (startY, endY) = y > other.y ? (other.y, y) : (y, other.y);
    var total = 0;
    for (var x = startX; x < endX; x++) {
      total += emptyCols.contains(x) ? distanceIfEmpty : 1;
    }
    for (var y = startY; y < endY; y++) {
      total += emptyRows.contains(y) ? distanceIfEmpty : 1;
    }
    return total;
  }
}
