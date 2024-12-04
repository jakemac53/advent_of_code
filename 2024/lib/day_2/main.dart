import 'dart:io';
import '../util.dart';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
    .where((l) => l.isNotEmpty);

void main() {
  var levels = [
    for (var line in input) line.readNumbers(),
  ];

  // Part 1
  {
    var safeLevels = 0;
    for (var level in levels) {
      assert(level.length > 1);
      var safeOffsets =
          level[0] > level[1] ? const [-1, -2, -3] : const [1, 2, 3];
      var isSafe = true;
      for (var i = 1; i < level.length; i++) {
        if (!safeOffsets.any((o) => level[i - 1] + o == level[i])) {
          isSafe = false;
          break;
        }
      }
      if (isSafe) safeLevels++;
    }
    print('part 1: $safeLevels');
  }

  // Part 2
  {
    var safeLevels = 0;
    for (var level in levels) {
      if (isSafe(level)) safeLevels++;
    }
    print('part 2: $safeLevels');
  }
}

bool isSafe(List<int> level, [bool alreadyRemoved = false]) {
  assert(level.length > 1);
  var safeOffsets = level[0] > level[1] ? const [-1, -2, -3] : const [1, 2, 3];
  for (var i = 1; i < level.length; i++) {
    if (!safeOffsets.any((o) => level[i - 1] + o == level[i])) {
      if (!alreadyRemoved) {
        return (i > 1
                ? isSafe(level.toList()..removeAt(i - 2), true)
                : false) ||
            isSafe(level.toList()..removeAt(i - 1), true) ||
            isSafe(level.toList()..removeAt(i), true);
      } else {
        return false;
      }
    }
  }
  return true;
}
