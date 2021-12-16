import 'dart:io';

void main() async {
  var values = [
    for (var line in await File('lib/day_1.txt').readAsLines())
      if (line.isNotEmpty) int.parse(line),
  ];
  partOne(values);
  partTwo(values);
}

void partOne(List<int> values) {
  var count = 0;
  var last = values.first;
  for (var value in values.skip(1)) {
    if (value > last) count++;
    last = value;
  }
  print('Part One: $count');
}

void partTwo(List<int> values) {
  int sum(int index) => values[index] + values[index + 1] + values[index + 2];
  var count = 0;
  var previousSum = sum(0);
  for (var i = 1; i < values.length - 2; i++) {
    var nextSum = sum(i);
    if (nextSum > previousSum) count++;
    previousSum = nextSum;
  }
  print('Part Two: $count');
}
