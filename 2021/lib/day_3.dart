import 'dart:io';

const day = 3;

final day3Values = [
  for (var line in lines)
    if (line.isNotEmpty) int.parse(line, radix: 2),
];

final lines = File('lib/day_${day}_input.txt').readAsLinesSync();

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var length = lines.first.length;

  var gammaRate = 0;
  var epsilonRate = 0;
  for (var i = 0; i < length; i++) {
    var gammaVal = mostCommon(day3Values, length - i - 1);
    gammaRate |= gammaVal << (length - i - 1);
    epsilonRate << 1;
    var epsilonVal = gammaVal ^ 1;
    epsilonRate |= epsilonVal << (length - i - 1);
  }
  return gammaRate * epsilonRate;
}

int part2() {
  var length = lines.first.length;
  var oxygenRating = 0;
  var co2ScrubberRating = 0;
  var oxygenMatches = day3Values;
  for (var i = length - 1; i >= 0; i--) {
    var oxygenBit = mostCommon(oxygenMatches, i);
    oxygenMatches = [
      for (var item in oxygenMatches)
        if (readBit(item, i) == oxygenBit) item,
    ];
    if (oxygenMatches.length == 1) {
      oxygenRating = oxygenMatches.first;
      break;
    }
  }
  var co2Matches = day3Values;
  for (var i = length - 1; i >= 0; i--) {
    var co2Bit = mostCommon(co2Matches, i) ^ 0x1;
    co2Matches = [
      for (var item in co2Matches)
        if (readBit(item, i) == co2Bit) item,
    ];
    if (co2Matches.length == 1) {
      co2ScrubberRating = co2Matches.first;
      break;
    }
  }
  return oxygenRating * co2ScrubberRating;
}

/// The most common bit a [position] of [day3Values], counting from
/// right to left, zero indexed.
int mostCommon(List<int> values, int position) {
  var ones = 0;
  for (var num in values) {
    ones += readBit(num, position);
  }
  return ones >= values.length / 2 ? 1 : 0;
}

/// Returns the bit at [position] from [original], counting from
/// right to left, zero indexed.
int readBit(int original, int position) {
  return (original & (0x1 << position)) >> position;
}
