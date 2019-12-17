import 'dart:io';
import "package:packhorse/packhorse.dart";

Future<void> main() async {
  final data = Dataframe.fromCsv(await File('iris_data.csv').readAsString()),
      sepalLength = data.nums['sepal_length'],
      pScores = sepalLength.pScores,
      thPScores = sepalLength.pScoresIfNormal,
      thQuantiles = sepalLength.quantiles(thPScores);

  print("\nMeasure vs Cumulative relative frequency\n");
  simplePlot(pScores, sepalLength);

  print("\nNormal Q-Q Plot\n");
  simplePlot(thQuantiles, thPScores);
}

void simplePlot(Numeric xs, Numeric ys) {
  final width = 50, height = 20;
  int xCoord(num x) => ((x - xs.least) / xs.range * (width - 1)).round();
  int yCoord(num y) =>
      (height - 1 - ((y - ys.least) / ys.range * (height - 1))).round();
  var area = List<List<String>>.generate(
      height, (_) => List<String>.filled(width, " "));

  for (int i = 0; i < xs.length; i++) {
    final x = xs[i], y = ys[i], cx = xCoord(x), cy = yCoord(y);

    area[cy][cx] = "*";
  }

  print(".${"-" * width}.");
  print(area.map((row) => "|${row.join()}|").join("\n"));
  print("'${"-" * width}'");
}
