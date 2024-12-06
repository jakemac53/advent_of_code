import 'dart:io';
import '../util.dart';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    var grid = input.map((l) => l.split('')).toList();
    var start = input.points.firstWhere((p) => input.lookup(p) == guardChar);
    var guard = Guard(start, up, grid);
    while (grid.isValid(guard.position)) {
      guard.move();
    }
    var total = 0;
    grid.points.forEach((p) {
      if (pathChars.contains(grid.lookup(p))) total++;
    });
    print('part 1: $total');
  }

  // Part 2
  {
    var total = 0;
    var start = input.points.firstWhere((p) => input.lookup(p) == guardChar);
    for (var newObstacle in input.points) {
      if (input.lookup(newObstacle) != emptyChar) continue;
      var grid = input.map((l) => l.split('')).toList();
      grid[newObstacle.y][newObstacle.x] = obstructionChar;

      var guard = Guard(start, up, grid);
      try {
        while (grid.isValid(guard.position)) {
          guard.move();
        }
      } on String catch (_) {
        total++;
      }
    }
    print('part 2: $total');
  }
}

const obstructionChar = '#';
const guardChar = '^';
const pathChars = [upChar, downChar, leftChar, rightChar];
const upChar = 'U';
const downChar = 'D';
const leftChar = 'L';
const rightChar = 'R';
const emptyChar = '.';

class Guard {
  Point position;
  Point direction;
  List<List<String>> grid;

  Guard(this.position, this.direction, this.grid);

  void move() {
    var next = position + direction;
    while (true) {
      // exited the room
      if (!grid.isValid(next)) break;

      // valid move
      if (grid.lookup(next) != obstructionChar) break;

      // Try a different direction
      direction = switch (direction) {
        up => right,
        right => down,
        down => left,
        left => up,
        _ => throw StateError('Whoops!'),
      };
      // Move from original position, in new direction
      next = position + direction;
    }

    var current = grid.lookup(position);
    void setPos(String char) {
      grid[position.y][position.x] = char;
    }

    if (current == guardChar) {
      setPos(upChar);
    } else if (current == emptyChar) {
      setPos(switch (direction) {
        up => upChar,
        down => downChar,
        left => leftChar,
        right => rightChar,
        _ => throw StateError('huh?'),
      });
    } else if (current.split('') case var chars
        when chars.any((c) => pathChars.contains(c))) {
      var dirChar = switch (direction) {
        up => upChar,
        down => downChar,
        left => leftChar,
        right => rightChar,
        _ => throw StateError('huh?'),
      };
      if (chars.contains(dirChar)) {
        throw 'cycle!';
      } else {
        setPos(current + dirChar);
      }
    } else {
      throw StateError('''
errorState:
  currentChar: ${grid.lookup(position)}
  position: $position
  dir: $direction
grid: ${grid.prettyString()}''');
    }
//         switch ((grid.lookup(guard.position), guard.direction)) {
//       (guardChar, _) => upDownChar, // starting space
//       (emptyChar, up || down) => upDownChar,
//       (emptyChar, left || right) => leftRightChar,
//       (upDownChar, left || right) || (leftRightChar, up || down) => bothChar,
//       (upDownChar, up || down) => throw 'cycle up/down!',
//       (leftRightChar, left || right) => throw 'cycle left/right!',
//       (bothChar, _) => throw 'cycle both!',
//       var error => throw StateError(),
//     };

    position = next;
  }
}
