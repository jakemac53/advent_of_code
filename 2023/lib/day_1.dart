import 'dart:io';

final input = File('lib/day_1.input.txt').readAsLinesSync();

void main() {
  var sum = 0;
  for (var line in input) {
    if (line.isEmpty) continue;
    int? first;
    int? last;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      var digit = switch (char) {
        '0' => 0,
        '1' => 1,
        '2' => 2,
        '3' => 3,
        '4' => 4,
        '5' => 5,
        '6' => 6,
        '7' => 7,
        '8' => 8,
        '9' => 9,
        _ => null,
      };
      if (digit == null) {
        if (line.startsWith('one', i)) {
          digit = 1;
        } else if (line.startsWith('two', i)) {
          digit = 2;
        } else if (line.startsWith('three', i)) {
          digit = 3;
        } else if (line.startsWith('four', i)) {
          digit = 4;
        } else if (line.startsWith('five', i)) {
          digit = 5;
        } else if (line.startsWith('six', i)) {
          digit = 6;
        } else if (line.startsWith('seven', i)) {
          digit = 7;
        } else if (line.startsWith('eight', i)) {
          digit = 8;
        } else if (line.startsWith('nine', i)) {
          digit = 9;
        }
      }
      if (digit == null) continue;
      if (first == null) first = digit;
      last = digit;
    }
    sum += (first! * 10) + last!;
  }
  print(sum);
}
