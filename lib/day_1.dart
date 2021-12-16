import 'dart:io';

void main() async {
  var values = [
    for (var line in await File('lib/day_1.txt').readAsLines())
      if (line.isNotEmpty) int.parse(line),
  ];
  var count = 0;
  var last = values.first;
  for (var value in values.skip(1)) {
    if (value > last) count++;
    last = value;
  }
  print(count);
}
