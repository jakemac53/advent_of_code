import 'dart:io';
import 'dart:math' as math;

const day = 16;

final lines = File('lib/day_${day}_input.txt').readAsLinesSync()
  ..removeWhere((element) => element.isEmpty);

void main() {
  print('Day $day: Part 1: ${part1()} - Part 2: ${part2()}');
}

int part1() {
  var packet = Packet.parse(BitView(lines.single));
  if (packet is LiteralPacket) {
    return packet.literalNum;
  } else if (packet is OperatorPacket) {
    var sum = 0;
    void addVersions(Packet packet) {
      sum += packet.version;
      if (packet is OperatorPacket) {
        for (var subPacket in packet.subPackets) addVersions(subPacket);
      }
    }

    addVersions(packet);
    return sum;
  }
  throw UnsupportedError('unsupported packet $packet');
}

int part2() {
  return Packet.parse(BitView(lines.single)).compute();
}

class BitView {
  final String hexString;
  int offset = 0;

  BitView(this.hexString);

  int read(int length) {
    var charOffset = (offset / 4).floor();
    var bitOffset = offset % 4;
    var result = 0;
    offset += length; // Do this before modifying length.
    while (length > 0) {
      var charBits = int.parse(hexString[charOffset], radix: 16);
      var lenToRead = math.min(length, 4 - bitOffset);
      var bits = readBits(charBits, bitOffset, lenToRead);
      result <<= lenToRead;
      result |= bits;

      length -= lenToRead;
      charOffset++;
      bitOffset = 0;
    }
    return result;
  }
}

abstract class Packet {
  final int version;
  final int typeId;

  Packet({required this.version, required this.typeId});

  int compute();

  factory Packet.parse(BitView bits) {
    var version = bits.read(3);
    var typeId = bits.read(3);

    if (typeId == 4) {
      // Literal value
      var shouldContinue = true;
      var literalNum = 0;
      while (shouldContinue) {
        if (bits.read(1) == 0) {
          shouldContinue = false;
        }
        literalNum <<= 4;
        literalNum |= bits.read(4);
      }
      return LiteralPacket(literalNum, version: version, typeId: typeId);
    } else {
      // Operator packet
      var lengthTypeId = bits.read(1);
      var subPackets = <Packet>[];
      if (lengthTypeId == 0) {
        var subPacketsLength = bits.read(15);
        var finalBit = bits.offset + subPacketsLength;
        while (bits.offset < finalBit) {
          subPackets.add(Packet.parse(bits));
        }
      } else {
        assert(lengthTypeId == 1);
        var subPacketsCount = bits.read(11);
        for (var i = 0; i < subPacketsCount; i++) {
          subPackets.add(Packet.parse(bits));
        }
      }
      return OperatorPacket(subPackets, version: version, typeId: typeId);
    }
  }
}

class LiteralPacket extends Packet {
  final int literalNum;

  LiteralPacket(this.literalNum, {required int version, required int typeId})
      : super(version: version, typeId: typeId);

  int compute() => literalNum;
}

class OperatorPacket extends Packet {
  final List<Packet> subPackets;

  OperatorPacket(this.subPackets, {required int version, required int typeId})
      : super(version: version, typeId: typeId);

  int compute() {
    switch (typeId) {
      case 0:
        return subPackets.fold(0, (sum, packet) => sum + packet.compute());
      case 1:
        return subPackets.fold(
            1, (product, packet) => product * packet.compute());
      case 2:
        return subPackets.skip(1).fold(subPackets.first.compute(),
            (min, packet) => math.min(min, packet.compute()));
      case 3:
        return subPackets.skip(1).fold(subPackets.first.compute(),
            (max, packet) => math.max(max, packet.compute()));
      case 5:
        assert(subPackets.length == 2);
        return subPackets[0].compute() > subPackets[1].compute() ? 1 : 0;
      case 6:
        assert(subPackets.length == 2);
        return subPackets[0].compute() < subPackets[1].compute() ? 1 : 0;
      case 7:
        assert(subPackets.length == 2);
        return subPackets[0].compute() == subPackets[1].compute() ? 1 : 0;
      default:
        throw UnsupportedError('Unrecognized operand id $typeId');
    }
  }
}

/// Reads [length] bits from 4 bit int [bits], starting from bit [start] (higher order
/// indexed) and returns the value as an int.
int readBits(int bits, int start, int length) {
  var mask = 0x0;
  for (var i = 0; i < length; i++) {
    mask <<= 1;
    mask += 1;
  }
  mask <<= (4 - (length + start));
  return (bits & mask) >> (4 - (length + start));
}
