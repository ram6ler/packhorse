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

```text
-xs: [-1, -2, -3, -4, -5]
xs + 10: [11, 12, 13, 14, 15]
xs + ys: [3, 5, 5, 7, 7]
xs * ys: [2, 6, 6, 12, 10]
xs / ys: [0.5, 0.6666666666666666, 1.5, 1.3333333333333333, 2.5]
xs % ys: [1, 2, 1, 1, 1]
xs dot ys: 36

```

#### Statistics

Several statistics are presented as properties of a numeric instance, including `sum`, `sumOfSquares`, `mean`, `variance`, `standardDeviation`, `meanAbsoluteDeviation`, `lowerQuartile`, `median`, `upperQuartile`, `interquartileRange`, `greatest`, `least`, `outliers`, `residuals`, `squaredResiduals` and `zScores`. For example:

```dart
final xs = Numeric([1, 2, 3, 4, 5]);
print(xs.residuals);
```

```text
[-2.0, -1.0, 0.0, 1.0, 2.0]

```

A `summary` is also available:

```dart
final ys = Numeric([2, 3, 2, 3, 2]);
ys.summary.forEach((statistic, value) {
  print("$statistic: $value");
});
```

```text
Sum: 12
Sum Of Squares: 30
Mean: 2.4
Variance: 0.3
Standard Deviation: 0.5477225575051661
Median: 2.0
Lower Quartile: 2.0
Upper Quartile: 3.0
Least Non Outlier: 2
Greatest Non Outlier: 3
Least: 2
Greatest: 3
Outliers: []

```



