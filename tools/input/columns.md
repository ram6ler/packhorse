
## Columns

The distinction between numeric and categoric columns is central to *packhorse*.

### Numeric

The `Numeric` class is a convenience wrapper for `List<num>` that represents a column of numeric data and provides properties and methods commonly associated with numeric data in statistics.

#### Operations

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

#### Statistics

Several statistics are presented as properties of a numeric instance, including `sum`, `sumOfSquares`, `mean`, `variance`, `standardDeviation`, `meanAbsoluteDeviation`, `lowerQuartile`, `median`, `upperQuartile`, `interquartileRange`, `greatest`, `least`, `outliers`, `residuals`, `squaredResiduals` and `zScores`.

### Categoric

The `Categoric` class is a convenience wrapper for `List<String>` that represents a column of categoric or qualitative data.

### List behavior

Column instances generally behave in similarly to lists, except:

* Indices wrap. (This is important to take into account when, for example, dealing with data frames containing columns of different lengths.) For example:

```dart
final xs = Numeric([0, 1, 2, 3]);
print(xs[-1]);
print(xs[10]);
```

* Since the operator `+` is used for elementwise addition, it cannot be used to add elements to the numeric.