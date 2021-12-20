import 'dart:io';

const day = 12;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

final edges = () {
  var edges = <String, List<String>>{};
  for (var line in lines) {
    var parts = line.split('-');
    var from = parts[0];
    var to = parts[1];
    if (from != 'end' && to != 'start') {
      edges.putIfAbsent(from, () => <String>[]).add(to);
    }
    to = parts[0];
    from = parts[1];
    if (from != 'end' && to != 'start') {
      edges.putIfAbsent(from, () => <String>[]).add(to);
    }
  }
  return edges;
}();

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  // small caves that have been visited.
  var visited = <String>{};
  // returns the number of paths to the end from `from`,
  // keeps `visited` up to date.
  int visit(String from) {
    var count = 0;
    for (var next in edges[from] ?? []) {
      if (next == 'end') {
        count++;
      } else if (next[0].toUpperCase() == next[0]) {
        count += visit(next);
      } else if (visited.add(next)) {
        count += visit(next);
        visited.remove(next);
      }
    }
    return count;
  }

  return visit('start');
}

int part2() {
  // small caves that have been visited.
  var visited = <String>{};
  var visitedTwice = false;
  // returns the number of paths to the end from `from`,
  // keeps `visited` up to date.
  int visit(String from) {
    var count = 0;
    for (var next in edges[from] ?? []) {
      if (next == 'end') {
        count++;
      } else if (next[0].toUpperCase() == next[0]) {
        count += visit(next);
      } else {
        if (visited.add(next)) {
          count += visit(next);
          visited.remove(next);
        } else if (!visitedTwice) {
          visitedTwice = true;
          count += visit(next);
          visitedTwice = false;
        }
      }
    }
    return count;
  }

  return visit('start');
}
