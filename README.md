# packhorse

Welcome to *packhorse*, a package supporting small to medium
data manipulation and analysis projects. Using packhorse, we have
access to several classes that allow us to easily extract commonly
used statistics, perform data manipulations such as joins, and
export data into a variety of forms, such as csv and json. 

## Basic classes

### Numeric

Instances of `Numeric` are list-like structures for numeric data, with properties and methods commonly used in data analysis.

Example:

```dart
final numeric = Numeric([4.57, 5.62, 4.12, 5.29, 4.64, 4.31]);
print('Variance: ${numeric.variance}');
```

```text
Variance: 0.28051388888888895
```

### Categoric

Instances of `Categoric` are list-like structures for categoric data, with properties and methods commonly used in data analysis.

Example:

```dart
final categoric = Categoric('mississippi'.split(''));
print('Counts:');
categoric.counts.forEach((category, count) {
  print('  $category: $count');
});
print('\nEntropy: ${categoric.entropy}');
```

```text
Counts:
  i: 4
  m: 1
  p: 2
  s: 4

Entropy: 1.2636544318820964
```

### Dataframe

Instances of `Dataframe` are objects containing maps of `Categoric`s (`cats`) and `Numeric`s (`nums`) that may be interpreted as data frames or tables of data, with each column a variable (categorization or measure) and each row an instance.

```dart
final iris = Dataframe.fromCsv(
    await File('data/iris_data.csv').readAsString());

print(iris
  .withColumns(['id', 'species', 'petal_length'])
  .withNumericFromNumeric('residuals', 'petal_length',
      (numeric) => numeric.residuals)
  .withRowsSampled(10, seed: 0));
```

```text
.---.----------.------------.--------------------.
| id|   species|petal_length|           residuals|
:---+----------+------------+--------------------:
|111| virginica|         5.1|   1.341999999999997|
|147| virginica|         5.0|  1.2419999999999973|
| 79|versicolor|         4.5|  0.7419999999999973|
| 34|    setosa|         1.4| -2.3580000000000028|
| 86|versicolor|         4.5|  0.7419999999999973|
| 61|versicolor|         3.5|-0.25800000000000267|
| 40|    setosa|         1.5| -2.2580000000000027|
|119| virginica|         6.9|  3.1419999999999977|
|  8|    setosa|         1.5| -2.2580000000000027|
| 56|versicolor|         4.5|  0.7419999999999973|
'---'----------'------------'--------------------'

```

Thanks for your interest. Please [file any issues here](https://bitbucket.org/ram6ler/packhorse/issues). 