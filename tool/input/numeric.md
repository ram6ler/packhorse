# Packhorse

[Home](Home.md) | [Numeric](numeric.md) | [Categoric](categoric.md) | [Dataframe](dataframe.md) | [About](about.md)

## Numeric

The `Numeric` class is a convenience wrapper of `List<num>` that represents a column of numeric data and provides properties and methods commonly associated with numeric data in statistics.

#### Operations

The operators `+`, `-`, `*`, `/` and `%` are defined for element-wise addition, subtraction, multiplication, division and modulus respectively. The dot product, treating numerics as a vectors, is available through `dot`. For example:

```dart
  final xs = Numeric([1, 2, 3, 4, 5]), ys = Numeric([2, 3, 2, 3, 2]);
  print("-xs: ${-xs}");
  print("xs + 10: ${xs + 10}");
  print("xs + ys: ${xs + ys}");
  print("xs * ys: ${xs * ys}");
  print("xs / ys: ${xs / ys}");
  print("xs % ys: ${xs % ys}");
  print("xs dot ys: ${xs.dot(ys)}");
```

#### Statistics

Several statistics are presented as properties of a numeric instance, including `sum`, `sumOfSquares`, `mean`, `variance`, `standardDeviation`, `meanAbsoluteDeviation`, `lowerQuartile`, `median`, `upperQuartile`, `interquartileRange`, `greatest`, `least`, `outliers`, `residuals`, `squaredResiduals` and `zScores`. For example:

```dart
final xs = Numeric([1, 2, 3, 4, 5]);
print(xs.residuals);
```

A `summary` is also available:

```dart
final ys = Numeric([2, 3, 2, 3, 2]);
ys.summary.forEach((statistic, value) {
  print("$statistic: $value");
});
```



