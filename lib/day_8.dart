import 'dart:io';

const day = 8;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final allInputs = lines.map((line) => line.split(' | ')[0].split(' ')).toList();
final allOutputs =
    lines.map((line) => line.split(' | ')[1].split(' ')).toList();

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  const oneSegs = 2;
  const fourSegs = 4;
  const sevenSegs = 3;
  const eightSegs = 7;
  const specialCounts = [oneSegs, fourSegs, sevenSegs, eightSegs];
  var count = 0;
  for (var outputs in allOutputs) {
    for (var output in outputs) {
      if (specialCounts.contains(output.length)) count++;
    }
  }
  return count;
}

int part2() {
  var sum = 0;
  for (var i = 0; i < allInputs.length; i++) {
    sum += solveLine(allInputs[i], allOutputs[i]);
  }
  return sum;
}

int solveLine(List<String> inputs, List<String> outputs) {
  inputs = inputs.toList();

  late Set<String> one;
  late Set<String> four;
  late Set<String> seven;
  late Set<String> eight;
  for (var sequence in inputs) {
    if (sequence.length == 2)
      one = sequence.chars;
    else if (sequence.length == 3)
      seven = sequence.chars;
    else if (sequence.length == 4)
      four = sequence.chars;
    else if (sequence.length == 7)
      eight = sequence.chars;
    else
      continue;
  }

  late Set<String> zero;
  late Set<String> two;
  late Set<String> three;
  late Set<String> five;
  late Set<String> six;
  late Set<String> nine;

  for (var sequence in inputs) {
    var chars = sequence.chars;
    if (sequence.length == 5) {
      // two, three , or five
      if (chars.containsAll(one)) {
        three = chars;
      } else if (chars.intersection(four).length == 3) {
        five = chars;
      } else {
        two = chars;
      }
    } else if (sequence.length == 6) {
      // zero, six, or nine
      if (chars.containsAll(one)) {
        // zero or nine
        if (chars.containsAll(four.difference(one))) {
          nine = chars;
        } else {
          zero = chars;
        }
      } else {
        six = chars;
      }
    }
  }

  var mapping = <String, String>{};
  var a = seven.difference(one).single;
  mapping[a] = 'a';
  var b = four.difference(three).single;
  mapping[b] = 'b';
  var c = two.intersection(one).single;
  mapping[c] = 'c';
  var d = nine.difference(zero).single;
  mapping[d] = 'd';
  var e = eight.difference(nine).single;
  mapping[e] = 'e';
  var f = one.difference({c}).single;
  mapping[f] = 'f';
  var g = three.difference({a, c, d, f}).single;
  mapping[g] = 'g';

  var result = 0;
  for (var sequence in outputs) {
    result = result * 10;
    var mapped = {
      for (var char in sequence.chars) mapping[char],
    };
    if (mapped.exactly(oneChars)) {
      result += 1;
    } else if (mapped.exactly(twoChars)) {
      result += 2;
    } else if (mapped.exactly(threeChars)) {
      result += 3;
    } else if (mapped.exactly(fourChars)) {
      result += 4;
    } else if (mapped.exactly(fiveChars)) {
      result += 5;
    } else if (mapped.exactly(sixChars)) {
      result += 6;
    } else if (mapped.exactly(sevenChars)) {
      result += 7;
    } else if (mapped.exactly(eightChars)) {
      result += 8;
    } else if (mapped.exactly(nineChars)) {
      result += 9;
    } else if (mapped.exactly(zeroChars)) {
      result += 0;
    } else {
      throw StateError('Unrecognized pattern $mapped');
    }
  }
  return result;
}

extension _exactly on Set {
  bool exactly(Set other) =>
      other.length == length && difference(other).isEmpty;
}

const zeroChars = {'a', 'b', 'c', 'e', 'f', 'g'};
const oneChars = {'c', 'f'};
const twoChars = {'a', 'c', 'd', 'e', 'g'};
const threeChars = {'a', 'c', 'd', 'f', 'g'};
const fourChars = {'b', 'c', 'd', 'f'};
const fiveChars = {'a', 'b', 'd', 'f', 'g'};
const sixChars = {'a', 'b', 'd', 'e', 'f', 'g'};
const sevenChars = {'a', 'c', 'f'};
const eightChars = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
const nineChars = {'a', 'b', 'c', 'd', 'f', 'g'};

extension _chars on String {
  Set<String> get chars => {
        for (var c = 0; c < length; c++) this[c],
      };
}
