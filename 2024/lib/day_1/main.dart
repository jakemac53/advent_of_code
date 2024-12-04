import 'dart:io';
import '../util.dart';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
    .where((l) => l.isNotEmpty);

void main() {
  // Part 1
  {
    var left = <int>[];
    var right = <int>[];
    for (var line in input) {
      var [l, r] = line.readNumbers();
      left.add(l);
      right.add(r);
    }
    left.sort();
    right.sort();
    assert(left.length == right.length);
    var total = 0;
    for (var i = 0; i < left.length; i++) {
      total += (left[i] - right[i]).abs();
    }
    print('part 1: $total');
  }

  // Part 2
  {
    var left = <int, int>{};
    var right = <int, int>{};
    for (var line in input) {
      var [l, r] = line.readNumbers();
      left.update(l, (i) => i + 1, ifAbsent: () => 1);
      right.update(r, (i) => i + 1, ifAbsent: () => 1);
    }
    var score = 0;
    for (var key in left.keys) {
      score += key * left[key]! * (right[key] ?? 0);
    }
    print('part 2: $score');
  }
}
