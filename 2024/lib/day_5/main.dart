import 'dart:io';
import '../util.dart';

final input =
    File.fromUri(Platform.script.resolve('input.txt')).readAsLinesSync();

void main() {
  // Part 1
  {
    var constraintsByA = <int, List<int>>{};
    var updates = <List<int>>[];
    var total = 0;
    for (var line in input) {
      if (line.contains('|')) {
        var [a, b] = line.readNumbers(separator: '|');
        constraintsByA.update(a, (c) => c..add(b), ifAbsent: () => [b]);
      } else if (line.contains(',')) {
        updates.add(line.readNumbers(separator: ','));
      }
    }
    for (var update in updates) {
      if (!isValid(update, constraintsByA)) continue;
      total += update[((update.length - 1) / 2).toInt()];
    }
    print('part 1: $total');
  }

  // Part 2
  {
    var constraintsByA = <int, List<int>>{};
    var constraintsByB = <int, List<int>>{};
    var updates = <List<int>>[];
    var total = 0;
    for (var line in input) {
      if (line.contains('|')) {
        var [a, b] = line.readNumbers(separator: '|');
        constraintsByA.update(a, (c) => c..add(b), ifAbsent: () => [b]);
        constraintsByB.update(b, (c) => c..add(a), ifAbsent: () => [a]);
      } else if (line.contains(',')) {
        updates.add(line.readNumbers(separator: ','));
      }
    }
    for (var update in updates) {
      if (isValid(update, constraintsByA)) continue;
      update.sort((a, b) {
        if (constraintsByA[a]?.contains(b) ?? false) {
          return -1;
        } else if (constraintsByA[b]?.contains(a) ?? false) {
          return 1;
        } else {
          return 0;
        }
      });
      if (!isValid(update, constraintsByA)) throw 'hey!';

      total += update[((update.length - 1) / 2).toInt()];
    }
    print('part 2: $total');
  }
}

bool isValid(List<int> update, Map<int, List<int>> constraintsByA) {
  var seen = <int>{};
  for (var value in update) {
    if (constraintsByA[value] case var constraints?) {
      for (var constraint in constraints) {
        if (seen.contains(constraint)) return false;
      }
    }
    seen.add(value);
  }
  return true;
}
