

## Head and tail

```dart
print('Head:');
print(iris.head(5));
print('\nTail:');
print(iris.tail(5));
```

```text
Head:
.--.------------.-----------.------------.-----------.-------.
|id|sepal_length|sepal_width|petal_length|petal_width|species|
:--+------------+-----------+------------+-----------+-------:
| 1|         5.1|        3.5|         1.4|        0.2| setosa|
| 2|         4.9|        3.0|         1.4|        0.2| setosa|
| 3|         4.7|        3.2|         1.3|        0.2| setosa|
| 4|         4.6|        3.1|         1.5|        0.2| setosa|
| 5|         5.0|        3.6|         1.4|        0.3| setosa|
'--'------------'-----------'------------'-----------'-------'

Tail:
.---.------------.-----------.------------.-----------.---------.
| id|sepal_length|sepal_width|petal_length|petal_width|  species|
:---+------------+-----------+------------+-----------+---------:
|150|         5.9|        3.0|         5.1|        1.8|virginica|
|149|         6.2|        3.4|         5.4|        2.3|virginica|
|148|         6.5|        3.0|         5.2|        2.0|virginica|
|147|         6.3|        2.5|         5.0|        1.9|virginica|
|146|         6.7|        3.0|         5.2|        2.3|virginica|
'---'------------'-----------'------------'-----------'---------'

```

## Adding data to a data frame

We can vertically combine two data frames with the same column names.

```dart
final headAndTail = iris.head(5).withDataAdded(iris.tail(5));
print(headAndTail);
```

```text
.---.------------.-----------.------------.-----------.---------.
| id|sepal_length|sepal_width|petal_length|petal_width|  species|
:---+------------+-----------+------------+-----------+---------:
|  1|         5.1|        3.5|         1.4|        0.2|   setosa|
|  2|         4.9|        3.0|         1.4|        0.2|   setosa|
|  3|         4.7|        3.2|         1.3|        0.2|   setosa|
|  4|         4.6|        3.1|         1.5|        0.2|   setosa|
|  5|         5.0|        3.6|         1.4|        0.3|   setosa|
|150|         5.9|        3.0|         5.1|        1.8|virginica|
|149|         6.2|        3.4|         5.4|        2.3|virginica|
|148|         6.5|        3.0|         5.2|        2.0|virginica|
|147|         6.3|        2.5|         5.0|        1.9|virginica|
|146|         6.7|        3.0|         5.2|        2.3|virginica|
'---'------------'-----------'------------'-----------'---------'

```

## Performing joins

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nLeft-join:');
print(petals.withLeftJoin(sepals, 'id'));

print('\nLeft-outer-join:');
print(petals.withLeftOuterJoin(sepals, 'id'));

print('\nRight-join:');
print(petals.withRightJoin(sepals, 'id'));

print('\nRight-outer-join:');
print(petals.withRightOuterJoin(sepals, 'id'));

print('\nFull-join:');
print(petals.withFullJoin(sepals, 'id'));

print('\nInner-join:');
print(petals.withInnerJoin(sepals, 'id'));

print('\nOuter-join:');
print(petals.withOuterJoin(sepals, 'id'));
```

```text
Left: petals sample:
.---.------------.-----------.----------.
| id|petal_length|petal_width|   species|
:---+------------+-----------+----------:
|  1|         1.4|        0.2|    setosa|
|  2|         1.4|        0.2|    setosa|
|  3|         1.3|        0.2|    setosa|
|  4|         1.5|        0.2|    setosa|
| 51|         4.7|        1.4|versicolor|
| 52|         4.5|        1.5|versicolor|
| 53|         4.9|        1.5|versicolor|
| 54|         4.0|        1.3|versicolor|
|101|         6.0|        2.5| virginica|
|102|         5.1|        1.9| virginica|
|103|         5.9|        2.1| virginica|
|104|         5.6|        1.8| virginica|
'---'------------'-----------'----------'

Right: sepals sample:
.---.------------.-----------.
| id|sepal_length|sepal_width|
:---+------------+-----------:
|  3|         4.7|        3.2|
|  4|         4.6|        3.1|
|  5|         5.0|        3.6|
|  6|         5.4|        3.9|
| 53|         6.9|        3.1|
| 54|         5.5|        2.3|
| 55|         6.5|        2.8|
| 56|         5.7|        2.8|
|103|         7.1|        3.0|
|104|         6.3|        2.9|
|105|         6.5|        3.0|
|106|         7.6|        3.0|
'---'------------'-----------'

Left-join:
.---.----------.--------.------------.-----------.------------.-----------.
| id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:---+----------+--------+------------+-----------+------------+-----------:
|  1|    setosa|    null|         1.4|        0.2|        null|       null|
|  2|    setosa|    null|         1.4|        0.2|        null|       null|
|  3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
|  4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
| 51|versicolor|    null|         4.7|        1.4|        null|       null|
| 52|versicolor|    null|         4.5|        1.5|        null|       null|
| 53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
| 54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
|101| virginica|    null|         6.0|        2.5|        null|       null|
|102| virginica|    null|         5.1|        1.9|        null|       null|
|103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
|104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
'---'----------'--------'------------'-----------'------------'-----------'

Left-outer-join:
.---.----------.--------.------------.-----------.------------.-----------.
| id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:---+----------+--------+------------+-----------+------------+-----------:
|  1|    setosa|    null|         1.4|        0.2|        null|       null|
|  2|    setosa|    null|         1.4|        0.2|        null|       null|
| 51|versicolor|    null|         4.7|        1.4|        null|       null|
| 52|versicolor|    null|         4.5|        1.5|        null|       null|
|101| virginica|    null|         6.0|        2.5|        null|       null|
|102| virginica|    null|         5.1|        1.9|        null|       null|
'---'----------'--------'------------'-----------'------------'-----------'

Right-join:
.----.----------.--------.------------.-----------.------------.-----------.
|  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:----+----------+--------+------------+-----------+------------+-----------:
|   3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
|   4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
|null|      null|       5|        null|       null|         5.0|        3.6|
|null|      null|       6|        null|       null|         5.4|        3.9|
|  53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
|  54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
|null|      null|      55|        null|       null|         6.5|        2.8|
|null|      null|      56|        null|       null|         5.7|        2.8|
| 103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
| 104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
|null|      null|     105|        null|       null|         6.5|        3.0|
|null|      null|     106|        null|       null|         7.6|        3.0|
'----'----------'--------'------------'-----------'------------'-----------'

Right-outer-join:
.----.-------.--------.------------.-----------.------------.-----------.
|  id|species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:----+-------+--------+------------+-----------+------------+-----------:
|null|   null|       5|        null|       null|         5.0|        3.6|
|null|   null|       6|        null|       null|         5.4|        3.9|
|null|   null|      55|        null|       null|         6.5|        2.8|
|null|   null|      56|        null|       null|         5.7|        2.8|
|null|   null|     105|        null|       null|         6.5|        3.0|
|null|   null|     106|        null|       null|         7.6|        3.0|
'----'-------'--------'------------'-----------'------------'-----------'

Full-join:
.----.----------.--------.------------.-----------.------------.-----------.
|  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:----+----------+--------+------------+-----------+------------+-----------:
|   1|    setosa|    null|         1.4|        0.2|        null|       null|
|   2|    setosa|    null|         1.4|        0.2|        null|       null|
|   3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
|   4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
|  51|versicolor|    null|         4.7|        1.4|        null|       null|
|  52|versicolor|    null|         4.5|        1.5|        null|       null|
|  53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
|  54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
| 101| virginica|    null|         6.0|        2.5|        null|       null|
| 102| virginica|    null|         5.1|        1.9|        null|       null|
| 103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
| 104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
|null|      null|       5|        null|       null|         5.0|        3.6|
|null|      null|       6|        null|       null|         5.4|        3.9|
|null|      null|      55|        null|       null|         6.5|        2.8|
|null|      null|      56|        null|       null|         5.7|        2.8|
|null|      null|     105|        null|       null|         6.5|        3.0|
|null|      null|     106|        null|       null|         7.6|        3.0|
'----'----------'--------'------------'-----------'------------'-----------'

Inner-join:
.---.----------.--------.------------.-----------.------------.-----------.
| id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:---+----------+--------+------------+-----------+------------+-----------:
|  3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
|  4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
| 53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
| 54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
|103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
|104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
'---'----------'--------'------------'-----------'------------'-----------'

Outer-join:
.----.----------.--------.------------.-----------.------------.-----------.
|  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
:----+----------+--------+------------+-----------+------------+-----------:
|   1|    setosa|    null|         1.4|        0.2|        null|       null|
|   2|    setosa|    null|         1.4|        0.2|        null|       null|
|  51|versicolor|    null|         4.7|        1.4|        null|       null|
|  52|versicolor|    null|         4.5|        1.5|        null|       null|
| 101| virginica|    null|         6.0|        2.5|        null|       null|
| 102| virginica|    null|         5.1|        1.9|        null|       null|
|null|      null|       5|        null|       null|         5.0|        3.6|
|null|      null|       6|        null|       null|         5.4|        3.9|
|null|      null|      55|        null|       null|         6.5|        2.8|
|null|      null|      56|        null|       null|         5.7|        2.8|
|null|      null|     105|        null|       null|         6.5|        3.0|
|null|      null|     106|        null|       null|         7.6|        3.0|
'----'----------'--------'------------'-----------'------------'-----------'

```

## Descriptive statistics

### Example statistic: mean

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
```

### Create a summary of a numeric column

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
```

### Create a summary of a categoric column

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
```

## Create a summary of an entire data frame

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

```

