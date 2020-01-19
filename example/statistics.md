## Statistics

Several commonly used statistics are built into the `Numeric` and
`Categoric` classes.

```dart
print('Petal length:\n');
final variable = 'petal_length';

print('Whole-sample-mean: ${
    iris.nums[variable].mean.toStringAsFixed(2)
}');

print('By species:');
iris.groupedByCategoric('species').forEach((species, data) {
    print('  $species: ${
        data.nums[variable].mean.toStringAsFixed(2)
    }');
});
```

```text
Petal length:

Whole-sample-mean: 3.76
By species:
  setosa: 1.46
  versicolor: 4.26
  virginica: 5.55

[7959 μs]
```

We can get a summary of a numeric:

```dart
print('Sepal width:\n');
iris.nums['sepal_width'].summary.forEach((statistic, value) {
  print('  $statistic: ${
      value is num ? value.toStringAsFixed(2) : value
  }');
});
```

```text
Sepal width:

  Sum: 458.60
  Sum Of Squares: 1430.40
  Mean: 3.06
  Variance: 0.19
  Standard Deviation: 0.44
  Median: 3.00
  Lower Quartile: 2.80
  Upper Quartile: 3.30
  Least Non Outlier: 2.30
  Greatest Non Outlier: 3.70
  Least: 2.00
  Greatest: 4.40
  Outliers: [3.9, 4.0, 4.4, 3.9, 3.8, 3.8, 4.1, 4.2, 3.8, 3.8, 2.0, 2.2, 2.2, 3.8, 2.2, 3.8]

[13789 μs]
```

... or of a categoric:

```dart
print('Species:\n');
iris.cats['species'].summary.forEach((statistic, value) {
  print('  $statistic: $value');
});
```

```text
Species:

  counts: {setosa: 50, versicolor: 50, virginica: 50}
  proportions: {setosa: 0.3333333333333333, versicolor: 0.3333333333333333, virginica: 0.3333333333333333}
  impurity: 0.6666666666666667
  entropy: 1.0986122886681096

[7187 μs]
```

A summary of an entire data frame is in the form of a map with the
column names as the keys and the individual summaries as the values:

```dart
print('Summary of iris data frame columns:');
(iris.summary..remove('id')).forEach((column, summary) {
  print('\n$column:');
  summary.forEach((statistic, value) {
      print('  $statistic: $value');
  });
});
```

```text
Summary of iris data frame columns:

species:
  counts: {setosa: 50, versicolor: 50, virginica: 50}
  proportions: {setosa: 0.3333333333333333, versicolor: 0.3333333333333333, virginica: 0.3333333333333333}
  impurity: 0.6666666666666667
  entropy: 1.0986122886681096

sepal_length:
  Sum: 876.5000000000002
  Sum Of Squares: 5223.849999999998
  Mean: 5.843333333333335
  Variance: 0.6856935123042505
  Standard Deviation: 0.8280661279778629
  Median: 5.8
  Lower Quartile: 5.1
  Upper Quartile: 6.4
  Least Non Outlier: 4.3
  Greatest Non Outlier: 7.7
  Least: 4.3
  Greatest: 7.9
  Outliers: [7.9]

sepal_width:
  Sum: 458.60000000000014
  Sum Of Squares: 1430.399999999999
  Mean: 3.057333333333334
  Variance: 0.1899794183445188
  Standard Deviation: 0.435866284936698
  Median: 3.0
  Lower Quartile: 2.8
  Upper Quartile: 3.3
  Least Non Outlier: 2.3
  Greatest Non Outlier: 3.7
  Least: 2.0
  Greatest: 4.4
  Outliers: [3.9, 4.0, 4.4, 3.9, 3.8, 3.8, 4.1, 4.2, 3.8, 3.8, 2.0, 2.2, 2.2, 3.8, 2.2, 3.8]

petal_length:
  Sum: 563.7000000000004
  Sum Of Squares: 2582.7100000000005
  Mean: 3.7580000000000027
  Variance: 3.1162778523489942
  Standard Deviation: 1.7652982332594667
  Median: 4.35
  Lower Quartile: 1.6
  Upper Quartile: 5.1
  Least Non Outlier: 1.0
  Greatest Non Outlier: 6.9
  Least: 1.0
  Greatest: 6.9
  Outliers: []

petal_width:
  Sum: 180.0000000000001
  Sum Of Squares: 302.3800000000001
  Mean: 1.2000000000000008
  Variance: 0.5797315436241604
  Standard Deviation: 0.7614010399416068
  Median: 1.3
  Lower Quartile: 0.3
  Upper Quartile: 1.8
  Least Non Outlier: 0.1
  Greatest Non Outlier: 2.5
  Least: 0.1
  Greatest: 2.5
  Outliers: []

[33390 μs]
```

## Quantizing a category

```dart
print(petals.withCategoricEnumerated('species'));
```

```text
.---.------------.-----------.----------.--------------.------------------.-----------------.
| id|petal_length|petal_width|   species|species_setosa|species_versicolor|species_virginica|
:---+------------+-----------+----------+--------------+------------------+-----------------:
|  1|         1.4|        0.2|    setosa|             1|                 0|                0|
|  2|         1.4|        0.2|    setosa|             1|                 0|                0|
|  3|         1.3|        0.2|    setosa|             1|                 0|                0|
|  4|         1.5|        0.2|    setosa|             1|                 0|                0|
| 51|         4.7|        1.4|versicolor|             0|                 1|                0|
| 52|         4.5|        1.5|versicolor|             0|                 1|                0|
| 53|         4.9|        1.5|versicolor|             0|                 1|                0|
| 54|         4.0|        1.3|versicolor|             0|                 1|                0|
|101|         6.0|        2.5| virginica|             0|                 0|                1|
|102|         5.1|        1.9| virginica|             0|                 0|                1|
|103|         5.9|        2.1| virginica|             0|                 0|                1|
|104|         5.6|        1.8| virginica|             0|                 0|                1|
'---'------------'-----------'----------'--------------'------------------'-----------------'

[7553 μs]
```

## Categorizing a quantity

```dart
print(petals.withNumericCategorized('petal_length', bins: 5, decimalPlaces: 1));
```

```text
.---.------------.-----------.----------.---------------------.
| id|petal_length|petal_width|   species|petal_length_category|
:---+------------+-----------+----------+---------------------:
|  1|         1.4|        0.2|    setosa|           [0.8, 2.0)|
|  2|         1.4|        0.2|    setosa|           [0.8, 2.0)|
|  3|         1.3|        0.2|    setosa|           [0.8, 2.0)|
|  4|         1.5|        0.2|    setosa|           [0.8, 2.0)|
| 51|         4.7|        1.4|versicolor|           [4.2, 5.3)|
| 52|         4.5|        1.5|versicolor|           [4.2, 5.3)|
| 53|         4.9|        1.5|versicolor|           [4.2, 5.3)|
| 54|         4.0|        1.3|versicolor|           [3.1, 4.2)|
|101|         6.0|        2.5| virginica|           [5.3, 6.5)|
|102|         5.1|        1.9| virginica|           [4.2, 5.3)|
|103|         5.9|        2.1| virginica|           [5.3, 6.5)|
|104|         5.6|        1.8| virginica|           [5.3, 6.5)|
'---'------------'-----------'----------'---------------------'

[12640 μs]
```