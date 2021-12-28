import 'dart:collection';
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
  scanners.add(Scanner(current));
  return scanners;
}();

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  /// Compute the offsets for all scanners from the first scanner.
  var first = scanners.first;
  first.rootTranslation = Coord(0, 0, 0);
  var found = <Scanner>{first};
  var queue = Queue.of([first]);
  while (queue.isNotEmpty) {
    var scannerA = queue.removeFirst();
    for (var s = 0; s < scanners.length; s++) {
      var scannerB = scanners[s];
      if (scannerA == scannerB || found.contains(scannerB)) continue;

      searchScanners:
      for (var rotation in rotations) {
        var computedRotation = rotation.reversed.reduce(multiplyMatrix);
        for (var i = 0; i < scannerA.offsets.length; i++) {
          var beaconOffsetsA = {
            for (var offset in scannerA.offsets[i])
              multiplyCoord(
                  scannerA.rootRotations.reversed.reduce(multiplyMatrix),
                  offset),
          };
          for (var j = 0; j < scannerB.offsets.length; j++) {
            var beaconOffsetsB = {
              for (var offset in scannerB.offsets[j])
                multiplyCoord(computedRotation, offset),
            };
            var intersection = beaconOffsetsA.intersection(beaconOffsetsB);
            if (intersection.length >= 11) {
              var rotatedBeacon =
                  multiplyCoord(computedRotation, scannerB.beacons[j]);
              var rootBeacon = multiplyCoord(
                  scannerA.rootRotations.reversed.reduce(multiplyMatrix),
                  scannerA.beacons[i]);
              var rootTranslation =
                  rotatedBeacon - rootBeacon + scannerA.rootTranslation!;
              print(
                  'matched scanner ${scanners.indexOf(scannerA)} with $s: $rootTranslation');
              scannerB.rootTranslation = rootTranslation;
              scannerB.rootRotations
                ..addAll(scannerA.rootRotations)
                ..addAll(rotation);

              found.add(scannerB);
              queue.add(scannerB);
              break searchScanners;
            }
          }
        }
      }
    }
  }

  var allBeacons = {
    for (var scanner in scanners)
      for (var beacon in scanner.beacons)
        multiplyCoord(
                scanner.rootRotations.reversed.reduce(multiplyMatrix), beacon) +
            scanner.rootTranslation!,
  }.toList()
    ..sort((a, b) => a.x - b.x);
  for (var beacon in allBeacons) {
    print(beacon);
  }
  return allBeacons.length;
}

int part2() {
  return 0;
}

class Scanner {
  final List<Coord> beacons;

  late final List<List<Coord>> offsets = [
    for (var beacon in beacons) beaconOffsets(beacon, this),
  ];

  /// Offset from scanner 0 (after rotation).
  Coord? rootTranslation;

  /// All rotations in order to be applied from the root.
  final rootRotations = <List<List<int>>>[identity];

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

  Coord operator +(Coord other) => Coord(x + other.x, y + other.y, z + other.z);
  Coord operator -(Coord other) => Coord(x - other.x, y - other.y, z - other.z);

  String toString() => '($x,$y,$z)';
}

/// All 24 possible matrix translations for a given coordinate.
List<List<List<List<int>>>> rotations = [
  for (var direction in [identity, x90, x180, x270, y90, y270])
    for (var orientation in [identity, z90, z180, z270])
      [direction, orientation],
];

var _coordCache = <List<List<int>>, Map<Coord, Coord>>{};

/// multiplies [matrix] by [vector].
Coord multiplyCoord(List<List<int>> matrix, Coord coord) {
  return _coordCache.putIfAbsent(matrix, () => {}).putIfAbsent(coord, () {
    var vector = coord.vector;
    assert(matrix.first.length == vector.length);
    return Coord.fromVector(List.generate(vector.length, (r) {
      var row = matrix[r];
      var total = 0;
      for (var c = 0; c < row.length; c++) {
        total += row[c] * vector[c];
      }
      return total;
    }));
  });
}

var _matrixCache = <List<List<int>>, Map<List<List<int>>, List<List<int>>>>{};

/// multiplies two NxN matrices.
List<List<int>> multiplyMatrix(List<List<int>> a, List<List<int>> b) {
  assert(a.length == b.length);
  assert(a.first.length == a.length);
  assert(a.first.length == b.first.length);
  return _matrixCache.putIfAbsent(a, () => {}).putIfAbsent(b, () {
    return List.generate(
        a.length,
        (r) => List.generate(a.length, (c) {
              var total = 0;
              for (var i = 0; i < a.length; i++) {
                total += a[r][i] * b[i][c];
              }
              return total;
            }));
  });
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
