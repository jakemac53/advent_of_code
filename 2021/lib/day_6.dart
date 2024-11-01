import 'dart:io';

const day = 6;

Iterable<Fish> get fishies => [
      for (var num in File('lib/day_${day}_input.txt')
          .readAsLinesSync()
          .first
          .split(','))
        Fish(int.parse(num)),
    ];

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var fishyList = fishies.toList();
  for (var i = 0; i < 80; i++) {
    var newFishies = <Fish>[];
    for (var fish in fishies) {
      var newFish = fish.nextDay();
      if (newFish != null) newFishies.add(newFish);
    }
    fishyList.addAll(newFishies);
  }
  return fishies.length;
}

int part2() {
  var dayBuckets = List.filled(9, 0);
  for (var fish in fishies) {
    dayBuckets[fish.daysLeft]++;
  }
  for (var i = 0; i < 256; i++) {
    dayBuckets = List.generate(9, (index) {
      if (index == 8) return dayBuckets[0];
      if (index == 6) return dayBuckets[0] + dayBuckets[7];
      return dayBuckets[index + 1];
    });
  }
  return dayBuckets.fold(
      0, (previousValue, element) => previousValue + element);
}

class Fish {
  int daysLeft;

  Fish(this.daysLeft);

  Fish? nextDay() {
    if (daysLeft == 0) {
      daysLeft = 6;
      return Fish(8);
    } else {
      daysLeft--;
      return null;
    }
  }

  String toString() => '$daysLeft';
}
