import 'dart:io';

import '../util.dart';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    var histories = input.map((s) => s.readNumbers()).toList();
    var total = 0;
    for (var history in histories) {
      var diffs = <List<int>>[history];
      while (true) {
        history = [
          for (var i = 0; i < history.length - 1; i++)
            history[i + 1] - history[i],
        ];
        diffs.add(history);
        if (history.every((d) => d == 0)) break;
      }
      diffs.last.add(0);
      for (var i = diffs.length - 2; i >= 0; i--) {
        var diff = diffs[i];
        diff.add(diff.last + diffs[i + 1].last);
      }
      total += diffs.first.last;
    }

    print('part 1: $total');
  }

  // Part 2
  {
    var histories = input.map((s) => s.readNumbers()).toList();
    var total = 0;
    for (var history in histories) {
      var diffs = <List<int>>[history];
      while (true) {
        history = [
          for (var i = 0; i < history.length - 1; i++)
            history[i + 1] - history[i],
        ];
        diffs.add(history);
        if (history.every((d) => d == 0)) break;
      }
      diffs.last.add(0);
      for (var i = diffs.length - 2; i >= 0; i--) {
        var diff = diffs[i];
        diff.insert(0, diff.first - diffs[i + 1].first);
      }
      total += diffs.first.first;
    }

    print('part 2: $total');
  }
}
