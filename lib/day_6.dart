import 'dart:io';

const day = 6;

final fish = [
  for (var num
      in File('lib/day_${day}_input.txt').readAsLinesSync().first.split(','))
    int.parse(num),
];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  return 0;
}

int part2() {
  return 0;
}
