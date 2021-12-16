import 'dart:io';

final day1Values = [
  for (var line in File('lib/day_1_input.txt').readAsLinesSync())
    if (line.isNotEmpty) int.parse(line),
];

int day1Part1() {
  int sum(int index) =>
      day1Values[index] + day1Values[index + 1] + day1Values[index + 2];
  var count = 0;
  var previousSum = sum(0);
  for (var i = 1; i < day1Values.length - 2; i++) {
    var nextSum = sum(i);
    if (nextSum > previousSum) count++;
    previousSum = nextSum;
  }
  return count;
}

int day1Part2() {
  var count = 0;
  var last = day1Values.first;
  for (var value in day1Values.skip(1)) {
    if (value > last) count++;
    last = value;
  }
  return count;
}
