import 'dart:io';

import 'util.dart';

const day = 20;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final algorithm = [
  for (var char in lines.first.chars) char == '#' ? 1 : 0,
];

List<List<int>> readImage() => [
      for (var line in lines.skip(1))
        [
          for (var char in line.chars) char == '#' ? 1 : 0,
        ],
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var image = readImage();
  image = image.enhance();
  image = image.enhance();
  return image.count;
}

int part2() {
  outOfBoundsBit = 0;
  var image = readImage();
  for (var i = 0; i < 50; i++) {
    image = image.enhance();
  }
  return image.count;
}

var outOfBoundsBit = 0;

extension Image on List<List<int>> {
  int computePixel(int row, int col) {
    var index = 0;
    for (var r = row - 1; r < row + 2; r++) {
      for (var c = col - 1; c < col + 2; c++) {
        index <<= 1;
        if (r < 0 || r >= length || c < 0 || c >= this[r].length) {
          index |= outOfBoundsBit;
        } else {
          index |= this[r][c];
        }
      }
    }
    return algorithm[index];
  }

  List<List<int>> enhance() {
    var result = [
      for (var r = -1; r <= length; r++)
        [
          for (var c = -1; c <= first.length; c++) computePixel(r, c),
        ]
    ];
    if (algorithm[0] == 1 && outOfBoundsBit == 0) {
      outOfBoundsBit = 1;
    } else if (algorithm.last == 0 && outOfBoundsBit == 1) {
      outOfBoundsBit = 0;
    }
    return result;
  }

  int get count {
    if (outOfBoundsBit == 1) throw 'Infinity!';
    var count = 0;
    for (var row in this) {
      for (var col in row) {
        count += col;
      }
    }
    return count;
  }

  String get displayString {
    var buffer = StringBuffer();
    for (var row in this) {
      buffer.writeln(row.map((e) => e == 1 ? '#' : '.').join(' '));
    }
    return buffer.toString();
  }
}
