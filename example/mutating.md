# Mutating

Mutating variables, or creating new variables from existing variables,
is performed via

1. templates
2. formulas
3. row variable access

## 1. Using templates

A *template* is a string with placeholders marked with column names.
For example:

```dart
final template = '{species}-{id}';
print(petals.withCategoricFromTemplate('id_code', template));
```

```text
.---.------------.-----------.----------.-------------.
| id|petal_length|petal_width|   species|      id_code|
:---+------------+-----------+----------+-------------:
|  1|         1.4|        0.2|    setosa|     setosa-1|
|  2|         1.4|        0.2|    setosa|     setosa-2|
|  3|         1.3|        0.2|    setosa|     setosa-3|
|  4|         1.5|        0.2|    setosa|     setosa-4|
| 51|         4.7|        1.4|versicolor|versicolor-51|
| 52|         4.5|        1.5|versicolor|versicolor-52|
| 53|         4.9|        1.5|versicolor|versicolor-53|
| 54|         4.0|        1.3|versicolor|versicolor-54|
|101|         6.0|        2.5| virginica|virginica-101|
|102|         5.1|        1.9| virginica|virginica-102|
|103|         5.9|        2.1| virginica|virginica-103|
|104|         5.6|        1.8| virginica|virginica-104|
'---'------------'-----------'----------'-------------'

[6812 μs]
```

We can also create numerical columns from templates:

```dart
final template = '{species}';
print(petals.withNumericFromTemplate('species_letters', template,
  (result) => result.length));
```

```text
.---.------------.-----------.----------.---------------.
| id|petal_length|petal_width|   species|species_letters|
:---+------------+-----------+----------+---------------:
|  1|         1.4|        0.2|    setosa|              6|
|  2|         1.4|        0.2|    setosa|              6|
|  3|         1.3|        0.2|    setosa|              6|
|  4|         1.5|        0.2|    setosa|              6|
| 51|         4.7|        1.4|versicolor|             10|
| 52|         4.5|        1.5|versicolor|             10|
| 53|         4.9|        1.5|versicolor|             10|
| 54|         4.0|        1.3|versicolor|             10|
|101|         6.0|        2.5| virginica|              9|
|102|         5.1|        1.9| virginica|              9|
|103|         5.9|        2.1| virginica|              9|
|104|         5.6|        1.8| virginica|              9|
'---'------------'-----------'----------'---------------'

[7189 μs]
```

## 2. Using formulas

A *formula* is a mathematical expression using the numeric column
names as variables. For example:

```dart
final formula = 'log(petal_length * petal_width)';

print(petals.withNumericFromFormula('log_petal_area', formula));
```

```text
.---.------------.-----------.----------.-------------------.
| id|petal_length|petal_width|   species|     log_petal_area|
:---+------------+-----------+----------+-------------------:
|  1|         1.4|        0.2|    setosa|-1.2729656758128876|
|  2|         1.4|        0.2|    setosa|-1.2729656758128876|
|  3|         1.3|        0.2|    setosa|-1.3470736479666092|
|  4|         1.5|        0.2|    setosa| -1.203972804325936|
| 51|         4.7|        1.4|versicolor|  1.884034745337226|
| 52|         4.5|        1.5|versicolor| 1.9095425048844386|
| 53|         4.9|        1.5|versicolor| 1.9947003132247454|
| 54|         4.0|        1.3|versicolor| 1.6486586255873816|
|101|         6.0|        2.5| virginica|   2.70805020110221|
|102|         5.1|        1.9| virginica| 2.2710944259026746|
|103|         5.9|        2.1| virginica|  2.516889695641051|
|104|         5.6|        1.8| virginica| 2.3105532626432224|
'---'------------'-----------'----------'-------------------'

[11682 μs]
```

We can also create categorical columns using formulas:

```dart
final formula = 'petal_width / petal_length';

print(petals.withCategoricFromFormula('description', formula,
  (result) => result < 0.3 ? 'narrow' : 'wide'));
```

```text
.---.------------.-----------.----------.-----------.
| id|petal_length|petal_width|   species|description|
:---+------------+-----------+----------+-----------:
|  1|         1.4|        0.2|    setosa|     narrow|
|  2|         1.4|        0.2|    setosa|     narrow|
|  3|         1.3|        0.2|    setosa|     narrow|
|  4|         1.5|        0.2|    setosa|     narrow|
| 51|         4.7|        1.4|versicolor|     narrow|
| 52|         4.5|        1.5|versicolor|       wide|
| 53|         4.9|        1.5|versicolor|       wide|
| 54|         4.0|        1.3|versicolor|       wide|
|101|         6.0|        2.5| virginica|       wide|
|102|         5.1|        1.9| virginica|       wide|
|103|         5.9|        2.1| virginica|       wide|
|104|         5.6|        1.8| virginica|       wide|
'---'------------'-----------'----------'-----------'

[10671 μs]
```

## 3. Using row variables

```dart
print(petals.withCategoricFromRowValues('code',
  (cats, nums) {
      final pre = cats['species'].substring(0, 3),
        area = (nums['petal_length'] * nums['petal_width'])
          .toStringAsFixed(2).padLeft(5, '0');
      return '$pre-$area';
  }));
```

```text
.---.------------.-----------.----------.---------.
| id|petal_length|petal_width|   species|     code|
:---+------------+-----------+----------+---------:
|  1|         1.4|        0.2|    setosa|set-00.28|
|  2|         1.4|        0.2|    setosa|set-00.28|
|  3|         1.3|        0.2|    setosa|set-00.26|
|  4|         1.5|        0.2|    setosa|set-00.30|
| 51|         4.7|        1.4|versicolor|ver-06.58|
| 52|         4.5|        1.5|versicolor|ver-06.75|
| 53|         4.9|        1.5|versicolor|ver-07.35|
| 54|         4.0|        1.3|versicolor|ver-05.20|
|101|         6.0|        2.5| virginica|vir-15.00|
|102|         5.1|        1.9| virginica|vir-09.69|
|103|         5.9|        2.1| virginica|vir-12.39|
|104|         5.6|        1.8| virginica|vir-10.08|
'---'------------'-----------'----------'---------'

[7130 μs]
```

