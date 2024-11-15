import 'dart:io';
import 'dart:math' as math;

final input = File('lib/day_5.input.txt').readAsLinesSync();

void main() {
  // Part 1
  {
    var lineIter = input.iterator;
    final seeds = (lineIter..moveNext()).current.readNumbers('seeds: ');
    lineIter.moveNext();
    print('seeds: $seeds');

    RangeMap readNextMap() {
      while (lineIter.current.isEmpty) {
        lineIter.moveNext();
      }
      // Skip the header for the map
      lineIter.moveNext();
      var map = RangeMap();
      while (lineIter.current.isNotEmpty) {
        lineIter.current.readIntoMap(map);
        if (!lineIter.moveNext()) break;
      }
      map.ranges.sort((RangeOffset a, RangeOffset b) {
        return a.start.compareTo(b.start);
      });
      return map;
    }

    var seedsToSoil = readNextMap();
    var soilToFertilizer = readNextMap();
    var fertilizerToWater = readNextMap();
    var waterToLight = readNextMap();
    var lightToTemperature = readNextMap();
    var temperatureToHumidity = readNextMap();
    var humidityToLocation = readNextMap();

    int location(int seed) {
      var soil = seedsToSoil[seed];
      var fertilizer = soilToFertilizer[soil];
      var water = fertilizerToWater[fertilizer];
      var light = waterToLight[water];
      var temperature = lightToTemperature[light];
      var humidity = temperatureToHumidity[temperature];
      var location = humidityToLocation[humidity];
      return location;
    }

    var min = location(seeds.first);
    for (var seed in seeds.skip(1)) {
      min = math.min(location(seed), min);
    }

    print('part 1: $min');
  }

  // Part 2
  {
    var lineIter = input.iterator;
    final seedNums = (lineIter..moveNext()).current.readNumbers('seeds: ');
    final seedRanges = <Range>[
      for (var i = 0; i < seedNums.length; i += 2)
        (start: seedNums[i], length: seedNums[i + 1]),
    ];
    lineIter.moveNext();
    print('seeds: $seedRanges');

    RangeMap readNextMap() {
      while (lineIter.current.isEmpty) {
        lineIter.moveNext();
      }
      // Skip the header for the map
      lineIter.moveNext();
      var map = RangeMap();
      while (lineIter.current.isNotEmpty) {
        lineIter.current.readIntoMap(map);
        if (!lineIter.moveNext()) break;
      }
      map.ranges.sort((RangeOffset a, RangeOffset b) {
        return a.start.compareTo(b.start);
      });
      return map;
    }

    var seedsToSoil = readNextMap();
    var soilToFertilizer = readNextMap();
    var fertilizerToWater = readNextMap();
    var waterToLight = readNextMap();
    var lightToTemperature = readNextMap();
    var temperatureToHumidity = readNextMap();
    var humidityToLocation = readNextMap();

    Iterable<Range> locationRanges(Iterable<Range> seedRanges) {
      var soilRanges = seedsToSoil.mapAllRanges(seedRanges);
      var fertilizerRanges = soilToFertilizer.mapAllRanges(soilRanges);
      var waterRanges = fertilizerToWater.mapAllRanges(fertilizerRanges);
      var lightRanges = waterToLight.mapAllRanges(waterRanges);
      var temperatureRanges = lightToTemperature.mapAllRanges(lightRanges);
      var humidityRanges =
          temperatureToHumidity.mapAllRanges(temperatureRanges);
      var locationRanges = humidityToLocation.mapAllRanges(humidityRanges);
      return locationRanges;
    }

    var locationsIterator = locationRanges(seedRanges).iterator..moveNext();
    var min = locationsIterator.current.start;
    while (locationsIterator.moveNext()) {
      min = math.min(locationsIterator.current.start, min);
    }
    print('part 2: $min');
  }
}

extension on String {
  List<int> readNumbers([String prefix = '']) => [
        for (var seed
            in substring(prefix.length).split(' ')
              ..removeWhere((s) => s.isEmpty))
          int.parse(seed),
      ];

  void readIntoMap(RangeMap map) {
    final [valueStart, keyStart, length] = readNumbers();
    map.ranges.add((
      start: keyStart,
      offset: valueStart - keyStart,
      length: length,
    ));
  }
}

/// A simple range.
typedef Range = ({int start, int length});

/// A range with an offset to be applied to all things in the range.
typedef RangeOffset = ({int start, int length, int offset});

extension on Range {
  Range remove(int count) => (start: start + count, length: length - count);
}

extension on RangeOffset {
  int get end => start + length - 1;
}

class RangeMap {
  /// Should be sorted before use, `overlap` assumes this.
  final ranges = <RangeOffset>[];

  Iterable<Range> mapAllRanges(Iterable<Range> from) sync* {
    for (var range in from) {
      yield* mapRange(range);
    }
  }

  /// Produces a new set of ranges for [from], mapped to all [ranges].
  Iterable<Range> mapRange(Range from) sync* {
    for (var range in ranges) {
      // Yield the part of `from` in front of `range`, if any, and update `from`
      if (from.start < range.start) {
        var before = (
          start: from.start,
          length: math.min(range.start - from.start + 1, from.length),
        );
        yield before;
        from = from.remove(before.length);
        if (from.length == 0) return;
      }

      // Yield the overlapping part of `from` and `range`, with the offset, if
      // any, and update `from`.
      if (range.end >= from.start) {
        var overlap = (
          start: from.start + range.offset,
          length: math.min(from.length, range.end - from.start + 1),
        );
        yield overlap;
        from = from.remove(overlap.length);
        if (from.length == 0) return;
      }
    }
    // Any left over at the end we just yield directly.
    yield from;
  }

  int operator [](int lookup) {
    for (var range in ranges) {
      if (lookup >= range.start && lookup - range.start < range.length) {
        return lookup + range.offset;
      }
    }
    return lookup;
  }
}
