import 'dart:io';

final input =
    File.fromUri(Platform.script.resolve('input.txt')).readAsLinesSync();

const digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

void main() {
  // Part 1
  {
    var sum = 0;
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      if (line.isEmpty) continue;
      for (var x = 0; x < line.length; x++) {
        if (digits.contains(line[x])) {
          var number = int.parse(line[x]);
          var foundSymbol = false;

          // Check for symbols above/below `x`
          void _checkSymbol(int x) {
            if (foundSymbol || x < 0 || x >= line.length) return;
            for (var yOffset in const [-1, 0, 1]) {
              var yActual = y + yOffset;
              if (yActual < 0 || yActual >= input.length) continue;
              final char = input[yActual][x];
              if (char != '.' && !digits.contains(char)) {
                foundSymbol = true;
                return;
              }
            }
          }

          _checkSymbol(x - 1);
          _checkSymbol(x);

          var x2 = x + 1;
          while (x2 < line.length && digits.contains(line[x2])) {
            _checkSymbol(x2);
            number = (number * 10) + int.parse(line[x2]);
            x2++;
          }
          _checkSymbol(x2);
          x = x2;

          if (foundSymbol) {
            sum += number;
          }
        }
      }
    }
    print('part 1: $sum');
  }

  // Part 2
  {
    var sum = 0;
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      if (line.isEmpty) continue;
      for (var x = 0; x < line.length; x++) {
        if (line[x] == '*') {
          final parts = <Part>{
            for (var x2 in [x - 1, x, x + 1])
              for (var y2 in [y - 1, y, y + 1])
                if (x2 >= 0 &&
                    x2 < input[y2].length &&
                    y2 >= 0 &&
                    y2 < input.length &&
                    digits.contains(input[y2][x2]))
                  Part.read(x2, y2),
          };
          if (parts.length == 2) {
            var ratio = 1;
            for (var part in parts) ratio *= part.readPart();
            sum += ratio;
          }
        }
      }
    }

    print('part 2: $sum');
  }
}

class Part {
  final int x;
  final int y;

  Part._(this.x, this.y);

  factory Part.read(int x, int y) {
    var line = input[y];
    while (x - 1 >= 0 && digits.contains(line[x - 1])) {
      x--;
    }
    return Part._(x, y);
  }

  int readPart() {
    var pos = this.x;
    var number = int.parse(input[y][x]);
    var line = input[y];
    while (++pos < line.length && digits.contains(line[pos])) {
      number = (number * 10) + int.parse(line[pos]);
    }
    return number;
  }

  operator ==(Object other) => other is Part && other.x == x && other.y == y;

  int get hashCode => Object.hash(x, y);
}
