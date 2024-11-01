import 'dart:io';

import 'util.dart';

const day = 10;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  const pointsMap = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137,
  };
  var score = 0;
  for (var line in lines) {
    final expectedClosing = <String>[];
    for (var char in line.chars) {
      var closingChar = closingCharsMap[char];
      if (closingChar != null) {
        expectedClosing.add(closingChar);
      } else {
        if (expectedClosing.isEmpty) {
          score += pointsMap[char]!;
          break;
        } else if (expectedClosing.removeLast() != char) {
          score += pointsMap[char]!;
          break;
        }
      }
    }
  }
  return score;
}

int part2() {
  const pointsMap = {
    ')': 1,
    ']': 2,
    '}': 3,
    '>': 4,
  };
  var scores = [];
  for (var line in lines) {
    var score = 0;
    final expectedClosing = <String>[];
    var failed = false;
    for (var char in line.chars) {
      var closingChar = closingCharsMap[char];
      if (closingChar != null) {
        expectedClosing.add(closingChar);
      } else {
        if (expectedClosing.isEmpty) {
          failed = true;
          break;
        } else if (expectedClosing.removeLast() != char) {
          failed = true;
          break;
        }
      }
    }
    if (!failed) {
      for (var char in expectedClosing.reversed) {
        score *= 5;
        score += pointsMap[char]!;
      }
      scores.add(score);
    }
  }
  scores.sort((a, b) => a - b);
  return scores[(scores.length / 2).floor()];
}

const closingCharsMap = {
  '(': ')',
  '[': ']',
  '{': '}',
  '<': '>',
};
