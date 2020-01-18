import "dart:io";
import 'package:packhorse/packhorse.dart';

main() async {
  // Density plots...
  {
    final data = Dataframe.fromCsv(await File("iris_data.csv").readAsString()),
        petals = data.nums["petal_length"],
        speciesIndices = (String species) =>
            data.cats["species"].indicesWhere((s) => s == species),
        setosaIndices = speciesIndices("setosa"),
        versicolorIndices = speciesIndices("versicolor"),
        virginicaIndices = speciesIndices("virginica"),
        gaps = 40,
        gap = (petals.greatest - petals.least) / gaps,
        fset = petals.elementsAtIndices(setosaIndices).density(),
        fver = petals.elementsAtIndices(versicolorIndices).density(),
        fvir = petals.elementsAtIndices(virginicaIndices).density(),
        xs = List.generate(gaps + 1, (i) => petals.least + i * gap),
        display = (num x, Function f) {
      final scale = 40, spaces = (f(x) * 0.5 * scale).round();
      return "|${" " * spaces}:${" " * (scale - spaces)}";
    };
    for (final x in xs) {
      print("${x.toStringAsFixed(2)} ${[
        fset,
        fver,
        fvir
      ].map((f) => display(x, f)).join(" ")}");
    }
  }

  // Density plots 2...
  {
    final data = Dataframe.fromCsv(await File("iris_data.csv").readAsString()),
        petals = data.nums["petal_width"],
        d = petals.density(),
        bars = petals.histogram(density: true),
        display = (HistogramBar bar) {
      final scale = 40;

      print("|${" " * (d(bar.lowerBound) * scale).round()}:");
      print("|${" " * (bar.value * scale).round()}]");
    };

    bars.forEach(display);
  }
}
