import 'dart:io';

final input = File.fromUri(Platform.script.resolve('input.txt'))
    .readAsLinesSync()
  ..removeWhere((l) => l.isEmpty);

void main() {
  // Part 1
  {
    var hands = <Hand>[];
    for (var line in input) {
      var [handStr, bid] = line.split(' ');
      hands.add(Hand.parseNoJokers(handStr, bid));
    }
    hands.sort((a, b) => b.compareTo(a, cardRanksPartOne));
    var total = 0;
    for (var i = 0; i < hands.length; i++) {
      total += hands[i].bid * (i + 1);
    }
    print('part 1: $total');
  }

  // Part 2
  {
    var hands = <Hand>[];
    for (var line in input) {
      var [handStr, bid] = line.split(' ');
      hands.add(Hand.parseWithJokers(handStr, bid));
    }
    hands.sort((a, b) => b.compareTo(a, cardRanksPartTwo));
    var total = 0;
    for (var i = 0; i < hands.length; i++) {
      total += hands[i].bid * (i + 1);
    }
    print('part 2: $total');
  }
}

class Hand {
  final String cards;
  final int priority;
  final int bid;

  Hand(this.cards, this.priority, this.bid);

  factory Hand.parseNoJokers(String hand, String bid) {
    var cardCounts = <String, int>{};
    for (var i = 0; i < hand.length; i++) {
      cardCounts.update(hand[i], (i) => i + 1, ifAbsent: () => 1);
    }
    var priority = switch (cardCounts.length) {
      5 => 6, // high card
      4 => 5, // pair
      3 => cardCounts.values.any((i) => i == 2)
          ? 4 /* two pair */
          : 3 /* three of a kind */,
      2 => cardCounts.values.any((i) => i == 3)
          ? 2 /* full house */
          : 1 /*four of a kind*/,
      1 => 0, // Five of a kind
      _ => throw StateError('5 of a kind?'),
    };

    return Hand(hand, priority, int.parse(bid));
  }

  factory Hand.parseWithJokers(String hand, String bid) {
    var cardCounts = <String, int>{};
    var jokerCount = 0;
    for (var i = 0; i < hand.length; i++) {
      var card = hand[i];
      if (card == 'J') {
        jokerCount++;
      } else {
        cardCounts.update(card, (i) => i + 1, ifAbsent: () => 1);
      }
    }

    if (cardCounts.isEmpty) {
      cardCounts['A'] = 5;
      jokerCount = 0;
    }

    if (jokerCount > 0) {
      // Always best to just add the jokers to the already highest count card.
      var MapEntry(key: highestKey, value: highestCount) =
          cardCounts.entries.first;
      for (var MapEntry(:key, :value) in cardCounts.entries.skip(1)) {
        if (value > highestCount) {
          highestKey = key;
          highestCount = value;
        }
      }
      cardCounts[highestKey] = highestCount + jokerCount;
    }

    var priority = switch (cardCounts.length) {
      5 => 6, // high card
      4 => 5, // pair
      3 => cardCounts.values.any((i) => i == 2)
          ? 4 /* two pair */
          : 3 /* three of a kind */,
      2 => cardCounts.values.any((i) => i == 3)
          ? 2 /* full house */
          : 1 /*four of a kind*/,
      1 => 0, // Five of a kind
      _ => throw StateError('5 of a kind?'),
    };

    return Hand(hand, priority, int.parse(bid));
  }

  int compareTo(Hand other, Map<String, int> cardRanks) {
    var byPriority = priority.compareTo(other.priority);
    if (byPriority != 0) return byPriority;
    for (var i = 0; i < 5; i++) {
      if (cards[i] != other.cards[i]) {
        return cardRanks[cards[i]]!.compareTo(cardRanks[other.cards[i]]!);
      }
    }
    return 0;
  }

  @override
  String toString() => '''
Hand:
  cards: $cards
  priority: $priority
''';
}

const cardRanksPartOne = {
  'A': 0,
  'K': 1,
  'Q': 2,
  'J': 3,
  'T': 4,
  '9': 5,
  '8': 6,
  '7': 7,
  '6': 8,
  '5': 9,
  '4': 10,
  '3': 11,
  '2': 12,
};
const cardRanksPartTwo = {
  'A': 0,
  'K': 1,
  'Q': 2,
  'T': 3,
  '9': 4,
  '8': 5,
  '7': 6,
  '6': 7,
  '5': 8,
  '4': 9,
  '3': 10,
  '2': 11,
  'J': 12,
};
