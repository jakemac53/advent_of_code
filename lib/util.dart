extension Chars on String {
  List<String> get chars => [
        for (var c = 0; c < length; c++) this[c],
      ];
}
