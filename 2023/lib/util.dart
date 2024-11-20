extension StringUtils on String {
  List<int> readNumbers([String prefix = '']) => [
        for (var seed
            in substring(prefix.length).split(' ')
              ..removeWhere((s) => s.isEmpty))
          int.parse(seed),
      ];
}
