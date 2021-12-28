import 'dart:io';
import 'dart:math' as math;

const day = 21;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

List<int> readStartPositions() {
  return List<int>.generate(2, (i) {
    var prefix = 'Player ${i + 1} starting position: ';
    var line = lines.firstWhere((line) => line.startsWith(prefix));
    return int.parse(line.substring(prefix.length));
  });
}

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var game = Game(readStartPositions());
  var nextRoll = 0;
  int roll() {
    var next = ++nextRoll;
    var actual = next % 100;
    return actual == 0 ? 100 : actual;
  }

  while (true) {
    for (var p = 0; p < 2; p++) {
      var score = game.movePlayer(p, [roll(), roll(), roll()]);
      if (score >= 1000) {
        return game.scores[(p + 1) % 2] * nextRoll;
      }
    }
  }
}

int part2() {
  // contains duplicates, could be optimized
  final allRolls = [
    for (var a = 1; a < 4; a++)
      for (var b = 1; b < 4; b++)
        for (var c = 1; c < 4; c++) a + b + c,
  ];
  const player1 = 0;
  const player2 = 1;
  final startPositions = readStartPositions();
  final wins = [0, 0];

  var lastTurnStates = <GameState, int>{
    GameState(PlayerState(score: 0, position: startPositions[0]),
        PlayerState(score: 0, position: startPositions[1])): 1,
  };
  var turn = 0;
  while (lastTurnStates.isNotEmpty) {
    turn++;
    var thisTurnStates = <GameState, int>{};

    for (var stateEntry in lastTurnStates.entries) {
      var state = stateEntry.key;
      var stateCount = stateEntry.value;
      var p1State = state.p1;
      // First take the player 1's turns.
      for (var p1Roll in allRolls) {
        var p1Position = (p1State.position + p1Roll) % 10;
        if (p1Position == 0) p1Position = 10;
        var p1Score = p1State.score + p1Position;
        if (p1Score >= 21) {
          wins[player1] += stateCount;
          continue; // Don't continue with this universe
        }
        // Player 1 didn't win, take player 2's turns.
        var p2State = state.p2;
        for (var p2Roll in allRolls) {
          var p2Position = (p2State.position + p2Roll) % 10;
          if (p2Position == 0) p2Position = 10;
          var p2Score = p2State.score + p2Position;
          if (p2Score >= 21) {
            wins[player2] += stateCount;
            continue; // Don't continue with this universe
          }
          // Universe continues, update the turn states.
          thisTurnStates.update(
              GameState(PlayerState(position: p1Position, score: p1Score),
                  PlayerState(position: p2Position, score: p2Score)),
              (current) => stateCount + current,
              ifAbsent: () => stateCount);
        }
      }
    }
    lastTurnStates = thisTurnStates;
  }
  print('Ended on turn $turn');
  var maxWins = math.max(wins[0], wins[1]);
  return maxWins;
}

// Used in part 2, immutable state class that implements hashCode/==
class GameState {
  final PlayerState p1;
  final PlayerState p2;

  GameState(this.p1, this.p2);

  int get hashCode => Object.hash(p1, p2);

  bool operator ==(other) =>
      other is GameState && p1 == other.p1 && p2 == other.p2;
}

class PlayerState {
  final int position;
  final int score;

  PlayerState({required this.position, required this.score});

  int get hashCode => Object.hash(position, score);

  bool operator ==(other) =>
      other is PlayerState &&
      position == other.position &&
      score == other.score;
}

// For part 1, part 2 uses the immutable State classes
class Game {
  final scores = [0, 0];
  final List<int> positions;

  Game(this.positions);

  int movePlayer(int player, List<int> rolls) {
    var roll = rolls.reduce((a, b) => a + b);
    var position = (positions[player] + roll) % 10;
    if (position == 0) position = 10;
    scores[player] += position;
    positions[player] = position;
    return scores[player];
  }
}
