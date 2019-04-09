# Packhorse

[Introduction](introduction.md) | [Numeric](numeric.md) | [Categoric](categoric.md) | [Dataframe](dataframe.md) | [Issues](issues.md) | [About](about.md)



## Numeric

The `Numeric` class is a convenience wrapper for `List<num>` that provides for properties and methods commonly associated with numeric data in statistics.

### Operations

The operators `+`, `-`, `*`, `/` and `%` are defined for elementwise addition, subtraction, multiplication, division and modulus respectively. The dot product, treating numerics as a vectors, is available through `dot`. For example:

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

### Statistics

Maty statistics are presented as properties of a numeric instance, including `sum`, `sumOfSquares`, `mean`, `variance`, `standardDeviation`, `meanAbsoluteDeviation`, `lowerQuartile`, `median`, `upperQuartile`, `interquartileRange`, `greatest`, `least`, `outliers`, `squaredResiduals` and `zScores`.