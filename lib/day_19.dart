import 'dart:io';

const day = 19;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final scanners = () {
  var scanners = <Scanner>[];
  var current = <Coord>[];
  for (var line in lines.skip(1)) {
    if (line.startsWith('--- scanner')) {
      scanners.add(Scanner(current));
      current = <Coord>[];
    } else {
      current.add(Coord.parse(line));
    }
  }
  return scanners;
}();

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var found = <Scanner>{scanners.first};
  for (var scannerA in scanners) {
    for (var s = 0; s < scanners.length; s++) {
      var scannerB = scanners[s];
      if (scannerA == scannerB || found.contains(scannerB)) continue;

      searchScanners:
      for (var translation in translations) {
        for (var i = 0; i < scannerA.offsets.length; i++) {
          var firstOffsets = scannerA.offsets[i].toSet();
          for (var j = 0; j < scannerB.offsets.length; j++) {
            var otherOffsets = {
              for (var offset in scannerB.offsets[j])
                Coord.fromVector(multiplyVector(translation, offset.vector)),
            };
            if (firstOffsets.intersection(otherOffsets).length >= 11) {
              print(
                  'Found a match for scanner ${scanners.indexOf(scannerA)} at $s!');
              found.add(scannerB);
              break searchScanners;
            }
          }
        }
      }
    }
  }
  return 0;
}

int part2() {
  return 0;
}

class Scanner {
  final List<Coord> beacons;

  late final List<List<Coord>> offsets = [
    for (var beacon in beacons) beaconOffsets(beacon, this),
  ];

  Scanner(this.beacons);
}

/// The offsets from [beacon] to all other beacons in [scanner].
List<Coord> beaconOffsets(Coord beacon, Scanner scanner) {
  return [
    for (var other in scanner.beacons)
      if (other != beacon)
        Coord(
          other.x - beacon.x,
          other.y - beacon.y,
          other.z - beacon.z,
        ),
  ];
}

class Coord {
  final int x;
  final int y;
  final int z;

  Coord(this.x, this.y, this.z);

  factory Coord.parse(String line) {
    var parts = [
      for (var part in line.split(',')) int.parse(part),
    ];
    return Coord(parts[0], parts[1], parts[2]);
  }

  factory Coord.fromVector(List<int> vector) =>
      Coord(vector[0], vector[1], vector[2]);

  List<int> get vector => [x, y, z, 1];

  int get hashCode => Object.hash(x, y, z);

  bool operator ==(other) =>
      other is Coord && other.x == x && other.y == y && other.z == z;

  String toString() => '($x,$y,$z)';
}

/// All 24 possible matrix translations for a given coordinate.
final List<List<List<int>>> translations = [
  for (var direction in [identity, x90, x180, x270, y90, y270])
    for (var orientation in [identity, z90, z180, z270])
      multiplyMatrix(orientation, direction),
];

/// multiplies [matrix] by [vector].
List<int> multiplyVector(List<List<int>> matrix, List<int> vector) {
  assert(matrix.first.length == vector.length);
  return List.generate(vector.length, (r) {
    var row = matrix[r];
    var total = 0;
    for (var c = 0; c < row.length; c++) {
      total += row[c] * vector[c];
    }
    return total;
  });
}

/// multiplies two NxN matrices.
List<List<int>> multiplyMatrix(List<List<int>> a, List<List<int>> b) {
  assert(a.length == b.length);
  assert(a.first.length == a.length);
  assert(a.first.length == b.first.length);
  return List.generate(
      a.length,
      (r) => List.generate(a.length, (c) {
            var total = 0;
            for (var i = 0; i < a.length; i++) {
              total += a[r][i] * b[i][c];
            }
            return total;
          }));
}

const cos90 = 0;
const cos180 = -1;
const cos270 = 0;
const sin90 = 1;
const sin180 = 0;
const sin270 = -1;

const identity = [
  [1, 0, 0, 0],
  [0, 1, 0, 0],
  [0, 0, 1, 0],
  [0, 0, 0, 1],
];

const x90 = [
  [1, 0, 0, 0],
  [0, cos90, -sin90, 0],
  [0, sin90, cos90, 0],
  [0, 0, 0, 1],
];
const x180 = [
  [1, 0, 0, 0],
  [0, cos180, -sin180, 0],
  [0, sin180, cos180, 0],
  [0, 0, 0, 1],
];
const x270 = [
  [1, 0, 0, 0],
  [0, cos270, -sin270, 0],
  [0, sin270, cos270, 0],
  [0, 0, 0, 1],
];

const y90 = [
  [cos90, 0, sin90, 0],
  [0, 1, 0, 0],
  [-sin90, 0, cos90, 0],
  [0, 0, 0, 1],
];
const y180 = [
  [cos180, 0, sin180, 0],
  [0, 1, 0, 0],
  [-sin180, 0, cos180, 0],
  [0, 0, 0, 1],
];
const y270 = [
  [cos270, 0, sin270, 0],
  [0, 1, 0, 0],
  [-sin270, 0, cos270, 0],
  [0, 0, 0, 1],
];

const z90 = [
  [cos90, -sin90, 0, 0],
  [sin90, cos90, 0, 0],
  [0, 0, 1, 0],
  [0, 0, 0, 1],
];

const z180 = [
  [cos180, -sin180, 0, 0],
  [sin180, cos180, 0, 0],
  [0, 0, 1, 0],
  [0, 0, 0, 1],
];

const z270 = [
  [cos270, -sin270, 0, 0],
  [sin270, cos270, 0, 0],
  [0, 0, 1, 0],
  [0, 0, 0, 1],
];
