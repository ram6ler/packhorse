# Bootstrap Confidence Intervals

`Column.bootstrapConfidenceIntervals` returns a (future to a) map of bootstrapped confidence intervals for each of the statistics associated with the column type.

## Test

The the petal areas are very different between species; expect 95% confidence intervals for mean to be far apart.

```dart
final petalFocus = iris.withColumns([
      "petal_length",
      "petal_width",
      "species",
    ]).withNumericColumnFromFormula(
      name: "area",
      formula: "petal_length * petal_width",
    ),
    split = petalFocus.groupedByCategory("species"),
    offset = 14,
    range = 12,
    width = 60;

print(" " * offset + "Petal Area Mean 95% CI by Species\n");
for (final MapEntry(:key, :value) in split.entries) {
  final confidenceIntervals =
      await value.numericColumns["area"]!.bootstrapConfidenceIntervals();

  final (lower, upper) = confidenceIntervals["mean"]!;

  print("$key:".padLeft(offset) +
      " " * (lower * width ~/ range) +
      "|" +
      "-" * ((upper - lower) * width ~/ range) +
      "|");
  print("(${lower.toStringAsFixed(1)}, ${upper.toStringAsFixed(1)})\n"
      .padLeft(offset));
}
print(" " * offset + ("'" + " " * ((width - 1) ~/ range)) * (range + 1));
print(" " * offset + "0" + " " * (width - 1) + "$range");
```

```text
              Petal Area Mean 95% CI by Species

       setosa: ||
   (0.3, 0.4)

   versicolor:                          |---|
   (5.4, 6.1)

    virginica:                                                     |-----|
 (10.7, 11.9)

              '    '    '    '    '    '    '    '    '    '    '    '    '    
              0                                                           12

[147422 μs]
```

## Potential Issues

* The current implementation generates confidence intervals for all statistics associated with the column type; this could be separated to be more efficient if we are only interested in confidence intervals for specific statistics, as in the example above.
