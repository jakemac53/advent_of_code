import 'dart:io';

final lines = File('lib/day_4_input.txt').readAsLinesSync();

final numbers = [
  for (var num in lines.first.split(',')) int.parse(num),
];

final boards = [
  for (var i = 2; i + 4 < lines.length; i += 6) Board.parse(lines, i),
];

void main() {
  print('Day 4: Part 1: ${day4Part1()} - Part 2: ${day4Part2()}');
}

int day4Part1() {
  for (var num in numbers) {
    var bingos = [
      for (var board in boards)
        if (board.mark(num)) board,
    ];
    if (bingos.isNotEmpty) {
      return bingos.first.score(num);
    }
  }
  throw StateError('nobody won!');
}

int day4Part2() {
  for (var num in numbers) {
    for (var board in boards.toList()) {
      if (board.mark(num)) {
        boards.remove(board);
        if (boards.isEmpty) {
          return board.score(num);
        }
      }
    }
  }
  throw StateError('more than one board remaining at end of numbers!');
}

class Board {
  final List<List<int>> values;
  final marked = List.generate(5, (_) => List<bool>.filled(5, false));

  Board(this.values);

  factory Board.parse(List<String> input, int startingRow) {
    return Board([
      for (var row = startingRow; row < startingRow + 5; row++)
        [
          for (var col
              in input[row].split(' ').where((element) => element.isNotEmpty))
            int.parse(col),
        ],
    ]);
  }

  /// Marks [number] on this board and returns `true` if that creates a bingo.
  bool mark(int number) {
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (values[r][c] == number) {
          marked[r][c] = true;
          if (checkBingo(r, c)) return true;
        }
      }
    }
    return false;
  }

  /// Checks if there is a bingo in either [row] or [col].
  bool checkBingo(int row, int col) =>
      marked[row].every((e) => e) || marked.every((r) => r[col]);

  int score(int lastCalled) {
    var unmarkedSum = 0;
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (!marked[r][c]) unmarkedSum += values[r][c];
      }
    }
    print('$lastCalled * $unmarkedSum');
    return lastCalled * unmarkedSum;
  }

  String toString() => values
      .map((row) => row.map((col) => '$col'.padLeft(2)).join(' '))
      .join('\n');
}
