import 'dart:io';
import 'dart:math' as math;

import 'util.dart';

const day = 14;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final template = lines.first;

final insertions = {
  for (var line in lines.skip(1)) line.split(' -> ')[0]: line.split(' -> ')[1],
};

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var line = template;
  for (var i = 0; i < 10; i++) {
    line = performInsertions(line);
  }

  var counts = <String, int>{};
  for (var char in line.chars) {
    counts[char] = (counts[char] ?? 0) + 1;
  }
  var max = 0;
  var min = 999999999;
  for (var count in counts.values) {
    max = math.max(max, count);
    min = math.min(min, count);
  }
  return max - min;
}

int part2() {
  var pairCounts = {
    for (var insertion in insertions.keys) insertion: 0,
  };
  for (var i = 0; i < template.length - 1; i++) {
    var pair = template.substring(i, i + 2);
    pairCounts[pair] = pairCounts[pair]! + 1;
  }

  for (var i = 0; i < 40; i++) {
    for (var entry in pairCounts.entries.toList()) {
      var pair = entry.key;
      var count = entry.value;
      pairCounts[pair] = pairCounts[pair]! - count;
      var insertion = insertions[pair]!;
      for (var newPair in ['${pair[0]}$insertion', '$insertion${pair[1]}']) {
        pairCounts[newPair] = pairCounts[newPair]! + count;
      }
    }
  }
  var counts = <String, int>{};
  for (var count in pairCounts.entries) {
    counts[count.key[0]] = (counts[count.key[0]] ?? 0) + count.value;
  }
  // Special case the final char
  var lastChar = template[template.length - 1];
  counts[lastChar] = counts[lastChar]! + 1;

  var max = counts.values.first;
  var min = counts.values.first;
  for (var count in counts.values) {
    max = math.max(max, count);
    min = math.min(min, count);
  }
  return max - min;
}

String performInsertions(String line) {
  var buf = StringBuffer();
  for (var i = 0; i < line.length - 1; i++) {
    var insertion = insertions[line.substring(i, i + 2)]!;
    buf.write('${line[i]}$insertion');
  }
  buf.write(line[line.length - 1]);
  return buf.toString();
}
