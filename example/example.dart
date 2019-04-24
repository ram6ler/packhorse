import "package:packhorse/packhorse.dart";

main() {
  final data = Numeric([58, 69, 88, 90, 93, 97, 99, 99, 100, 104, 107, 127]),
      pScores = data.pScores,
      thPScores = data.pScoresIfNormal,
      thQuantiles = data.quantiles(thPScores);

  void simplePlot(Numeric xs, Numeric ys) {
    final width = 30, height = 15;
    int xCoord(num x) => ((x - xs.least) / xs.range * (width - 1)).round();
    int yCoord(num y) =>
        (height - 1 - ((y - ys.least) / ys.range * (height - 1))).round();
    var area = List<List<String>>.generate(
        height, (_) => List<String>.generate(width, (_) => " "));

    for (int i = 0; i < xs.length; i++) {
      final x = xs[i], y = ys[i], cx = xCoord(x), cy = yCoord(y);

      area[cy][cx] = "*";
    }

    print(".${"-" * width}.");
    print(area.map((row) => "|${row.join()}|").join("\n"));
    print("'${"-" * width}'");
  }

  print("\nMeasure vs Cumulative relative frequency\n");
  simplePlot(pScores, data);

  print("\nNormal Q-Q Plot\n");
  simplePlot(thQuantiles, data);
}
