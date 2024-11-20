import 'dart:io';

import '../util.dart';

final input =
    File.fromUri(Platform.script.resolve('input.txt')).readAsLinesSync();

typedef Range = (int, int);

extension on Range {
  int get start => $1;
  int get end => $2;
}

Range solve(Range possiblities, int time, int distance) {
  int? start;
  int? end;
  for (var i = possiblities.start; i <= possiblities.end; i++) {
    var traveled = i * (time - i);
    if (traveled > distance) {
      start ??= i;
    } else if (start != null) {
      end = i - 1;
      break;
    }
  }
  return (start!, end!);
}

void main() {
  // Part 1
  {
    final times = input[0].readNumbers('Time:');
    final distances = input[1].readNumbers('Distance:');
    var answer = 1;
    for (var i = 0; i < times.length; i++) {
      var possiblities = solve((0, times[i]), times[i], distances[i]);
      answer *= possiblities.end - possiblities.start + 1;
    }

    print('part 1: $answer');
  }

  // Part 2
  {
    var time =
        int.parse(input[0].substring('Time:'.length).replaceAll(' ', ''));
    var distance =
        int.parse(input[1].substring('Distance:'.length).replaceAll(' ', ''));
    var possiblities = solve((0, time), time, distance);
    print('part 2: ${possiblities.end - possiblities.start + 1} $possiblities');
  }
}
