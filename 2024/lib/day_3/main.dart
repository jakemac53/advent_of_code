import 'dart:io';

final input =
    File.fromUri(Platform.script.resolve('input.txt')).readAsStringSync();

void main() {
  // Part 1
  {
    assert(input.length == 1);
    var regex = RegExp(r'mul\(([0-9]+),([0-9]+)\)');
    var total = 0;
    for (var match in regex.allMatches(input)) {
      total += int.parse(match.group(1)!) * int.parse(match.group(2)!);
    }
    print('part 1: $total');
  }

  // Part 2
  {
    assert(input.length == 1);
    var regex = RegExp(r"mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)");
    var total = 0;
    var enabled = true;
    for (var match in regex.allMatches(input)) {
      var matchedText = match.group(0);
      if (matchedText == 'do()') {
        enabled = true;
      } else if (matchedText == "don't()") {
        enabled = false;
      } else if (enabled) {
        total += int.parse(match.group(1)!) * int.parse(match.group(2)!);
      }
    }
    print('part 2: $total');
  }
}
