# Instantiation

Instances if `Numeric` and `Categoric` (which can be interpreted as table
columns or variables) are generally instantiated directly from iterables:

```dart
final numeric = Numeric([1, 2, 3]),
  categoric = Categoric(['a', 'b', 'c']);

print(numeric);
print(categoric);
```

```text
Numeric [1, 2, 3]
Categoric [a, b, c]

[2201 μs]
```

Instances of `Dataframe` can be instantiated from strings (like csv or json),
maps or lists.

```dart
final dataframe = Dataframe.fromCsv('''
    id*,petal_length,petal_width,species
    1,1.4,0.2,setosa
    2,1.4,0.2,setosa
    3,1.3,0.2,setosa
    4,1.5,0.2,setosa
    51,4.7,1.4,versicolor
    52,4.5,1.5,versicolor
    53,4.9,1.5,versicolor
    54,4.0,1.3,versicolor
    101,6.0,2.5,virginica
    102,5.1,1.9,virginica
    103,5.9,2.1,virginica
    104,5.6,1.8,virginica
''');

print(dataframe);
```

```text
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

[5073 μs]
```

In the following examples, dataframes `iris`, `petals` and `sepals` have
been created from the famous [iris data set](https://en.wikipedia.org/wiki/Iris_flower_data_set).

# Chaining

Methods that start with `with` - `withDataAdded`, `withColumns`,
`withLeftJoin`, `withNumericFromFormula`, etc. - return a new
data frame, and thus can be conveniently chained:

```dart
final focus = iris
  .withColumnsDropped(['sepal_length', 'petal_length'])
  .withNumericFromNumeric('sepal_width_z_scores', 
    'sepal_width', (result) => result.zScores)
  .withRowsSampled(10, replacement: true);

print(focus);
```

```text
.---.----------.-----------.-----------.--------------------.
| id|   species|sepal_width|petal_width|sepal_width_z_scores|
:---+----------+-----------+-----------+--------------------:
| 91|versicolor|        2.6|        1.2| -1.0527665443562113|
| 53|versicolor|        3.1|        1.5| 0.09821728693702086|
|100|versicolor|        2.8|        1.3| -0.5923730118389191|
| 92|versicolor|        3.0|        1.4| -0.1319794793216258|
| 23|    setosa|        3.6|        0.2|  1.2492011182302531|
| 26|    setosa|        3.0|        0.2| -0.1319794793216258|
| 83|versicolor|        2.7|        1.2| -0.8225697780975647|
|148| virginica|        3.0|        2.0| -0.1319794793216258|
| 40|    setosa|        3.4|        0.2|  0.7888075857129598|
| 69|versicolor|        2.2|        1.5|  -1.973553609390797|
'---'----------'-----------'-----------'--------------------'

[13417 μs]
```

# Extensions

## Lists

Lists to Numerics:

```dart
final numeric = [1, 2, 3].toNumeric();
print(numeric);
print(numeric.mean);
```

```text
Numeric [1, 2, 3]
2.0

[4487 μs]
```

Lists to Categorics:

```dart
final categoric = ['red', 'blue', 'blue'].toCategoric();
print(categoric);
categoric.proportions.forEach((value, p) {
  print('  $value: $p');
});
```

```text
Categoric [red, blue, blue]
  blue: 0.6666666666666666
  red: 0.3333333333333333

[3004 μs]
```

## Map with variable keys

```dart
final data = {
    'a': [1, 2, 3], 
    'b': ['red', 'blue', 'blue']
  }.toDataframe();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

[4761 μs]
```

## List of instances

```dart
final data = [
    {'a': 1, 'b': 'red'},
    {'a': 2, 'b': 'blue'},
    {'a': 3, 'b': 'blue'}
  ].toDataframe();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

[5124 μs]
```

## Strings

### csv content:

```dart
final data = '''
  a,b
  1,red
  2,blue
  3,blue
'''.parseAsCsv();

print(data);
```

```text
.-.----.
|a|   b|
:-+----:
|1| red|
|2|blue|
|3|blue|
'-'----'

[4438 μs]
```

### Json / map of lists:

```dart
final data = '''
  {
    "a": [1, 2, 3],
    "b": ["red", "blue", "blue"]
  }
'''.parseAsMapOfLists();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

[9375 μs]
```

### Json / list of maps:

```dart
final data = '''
  [
    {"a": 1, "b": "red"},
    {"a": 2, "b": "blue"},
    {"a": 3, "b": "blue"}
  ]
'''.parseAsListOfMaps();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

[9096 μs]
```

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

[7521 μs]
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

[7734 μs]
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

[11514 μs]
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

[10880 μs]
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

[7584 μs]
```

# Products

```dart
print(petals.toMarkdown());
```

```text
|id|petal_length|petal_width|species|
|:--:|:--:|:--:|:--:|
|1|1.4|0.2|setosa|
|2|1.4|0.2|setosa|
|3|1.3|0.2|setosa|
|4|1.5|0.2|setosa|
|51|4.7|1.4|versicolor|
|52|4.5|1.5|versicolor|
|53|4.9|1.5|versicolor|
|54|4.0|1.3|versicolor|
|101|6.0|2.5|virginica|
|102|5.1|1.9|virginica|
|103|5.9|2.1|virginica|
|104|5.6|1.8|virginica|

[3747 μs]
```

```dart
print(petals.toCsv());
```

```text
id,petal_length,petal_width,species
1,1.4,0.2,setosa
2,1.4,0.2,setosa
3,1.3,0.2,setosa
4,1.5,0.2,setosa
51,4.7,1.4,versicolor
52,4.5,1.5,versicolor
53,4.9,1.5,versicolor
54,4.0,1.3,versicolor
101,6.0,2.5,virginica
102,5.1,1.9,virginica
103,5.9,2.1,virginica
104,5.6,1.8,virginica

[4394 μs]
```

```dart
print(petals.toHtml());
```

```text
<table>
<tr><th>id</th><th>petal_length</th><th>petal_width</th><th>species</th></tr>
<tr><td>1</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
<tr><td>2</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
<tr><td>3</td><td>1.3</td><td>0.2</td><td>setosa</td></tr>
<tr><td>4</td><td>1.5</td><td>0.2</td><td>setosa</td></tr>
<tr><td>51</td><td>4.7</td><td>1.4</td><td>versicolor</td></tr>
<tr><td>52</td><td>4.5</td><td>1.5</td><td>versicolor</td></tr>
<tr><td>53</td><td>4.9</td><td>1.5</td><td>versicolor</td></tr>
<tr><td>54</td><td>4.0</td><td>1.3</td><td>versicolor</td></tr>
<tr><td>101</td><td>6.0</td><td>2.5</td><td>virginica</td></tr>
<tr><td>102</td><td>5.1</td><td>1.9</td><td>virginica</td></tr>
<tr><td>103</td><td>5.9</td><td>2.1</td><td>virginica</td></tr>
<tr><td>104</td><td>5.6</td><td>1.8</td><td>virginica</td></tr>
</table>

[3488 μs]
```

```dart
print(sepals.withHead(2).toJsonAsMapOfLists());
```

```text
{"id":["3","4"],"sepal_length":[4.7,4.6],"sepal_width":[3.2,3.1]}

[8143 μs]
```

# Restructuring

## Adding data to a data frame

We can vertically combine two data frames with the same column names.

```dart
final headAndTail = iris.withHead(5).withDataAdded(iris.withTail(5));
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

[9893 μs]
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

[16875 μs]
```

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

[9740 μs]
```

We can get a summary of a numeric:

```dart
print('Sepal width:\n');
iris.nums['sepal_width'].summary.forEach((statistic, value) {
  print('  $statistic: $value');
});
```

```text
Sepal width:

  numberOfInstances: 150
  sum: 458.60000000000014
  sumOfSquares: 1430.399999999999
  mean: 3.057333333333334
  variance: 0.1887128888888887
  inferredVariance: 0.1899794183445188
  standardDeviation: 0.43441096773549437
  inferredStandardDeviation: 0.435866284936698
  meanAbsoluteDeviation: 0.33678222222222215
  least: 2.0
  leastNonOutlier: 2.3
  lowerQuartile: 2.8
  median: 3.0
  upperQuartile: 3.3
  greatestNonOutlier: 3.7
  greatest: 4.4
  range: 2.4000000000000004
  interQuartileRange: 0.5

[16972 μs]
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

  numberOfInstances: 150
  impurity: 0.6666666666666667
  entropy: 1.0986122886681096

[7959 μs]
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
  numberOfInstances: 150
  impurity: 0.6666666666666667
  entropy: 1.0986122886681096

sepal_length:
  numberOfInstances: 150
  sum: 876.5000000000002
  sumOfSquares: 5223.849999999998
  mean: 5.843333333333335
  variance: 0.6811222222222222
  inferredVariance: 0.6856935123042505
  standardDeviation: 0.8253012917851409
  inferredStandardDeviation: 0.8280661279778629
  meanAbsoluteDeviation: 0.6875555555555561
  least: 4.3
  leastNonOutlier: 4.3
  lowerQuartile: 5.1
  median: 5.8
  upperQuartile: 6.4
  greatestNonOutlier: 7.7
  greatest: 7.9
  range: 3.6000000000000005
  interQuartileRange: 1.3000000000000007

sepal_width:
  numberOfInstances: 150
  sum: 458.60000000000014
  sumOfSquares: 1430.399999999999
  mean: 3.057333333333334
  variance: 0.1887128888888887
  inferredVariance: 0.1899794183445188
  standardDeviation: 0.43441096773549437
  inferredStandardDeviation: 0.435866284936698
  meanAbsoluteDeviation: 0.33678222222222215
  least: 2.0
  leastNonOutlier: 2.3
  lowerQuartile: 2.8
  median: 3.0
  upperQuartile: 3.3
  greatestNonOutlier: 3.7
  greatest: 4.4
  range: 2.4000000000000004
  interQuartileRange: 0.5

petal_length:
  numberOfInstances: 150
  sum: 563.7000000000004
  sumOfSquares: 2582.7100000000005
  mean: 3.7580000000000027
  variance: 3.0955026666666674
  inferredVariance: 3.1162778523489942
  standardDeviation: 1.7594040657753032
  inferredStandardDeviation: 1.7652982332594667
  meanAbsoluteDeviation: 1.5627466666666645
  least: 1.0
  leastNonOutlier: 1.0
  lowerQuartile: 1.6
  median: 4.35
  upperQuartile: 5.1
  greatestNonOutlier: 6.9
  greatest: 6.9
  range: 5.9
  interQuartileRange: 3.4999999999999996

petal_width:
  numberOfInstances: 150
  sum: 180.0000000000001
  sumOfSquares: 302.3800000000001
  mean: 1.2000000000000008
  variance: 0.575866666666666
  inferredVariance: 0.5797315436241604
  standardDeviation: 0.7588587923103125
  inferredStandardDeviation: 0.7614010399416068
  meanAbsoluteDeviation: 0.6573333333333329
  least: 0.1
  leastNonOutlier: 0.1
  lowerQuartile: 0.3
  median: 1.3
  upperQuartile: 1.8
  greatestNonOutlier: 2.5
  greatest: 2.5
  range: 2.4
  interQuartileRange: 1.5

[32612 μs]
```

## Quantizing a category

```dart
print(petals
  .withColumns(['id', 'species'])
  .withCategoricEnumerated('species'));
```

```text
.---.----------.--------------.------------------.-----------------.
| id|   species|species_setosa|species_versicolor|species_virginica|
:---+----------+--------------+------------------+-----------------:
|  1|    setosa|             1|                 0|                0|
|  2|    setosa|             1|                 0|                0|
|  3|    setosa|             1|                 0|                0|
|  4|    setosa|             1|                 0|                0|
| 51|versicolor|             0|                 1|                0|
| 52|versicolor|             0|                 1|                0|
| 53|versicolor|             0|                 1|                0|
| 54|versicolor|             0|                 1|                0|
|101| virginica|             0|                 0|                1|
|102| virginica|             0|                 0|                1|
|103| virginica|             0|                 0|                1|
|104| virginica|             0|                 0|                1|
'---'----------'--------------'------------------'-----------------'

[7877 μs]
```

## Categorizing a quantity

```dart
print(petals
  .withColumns(['species', 'petal_length'])
  .withNumericCategorized('petal_length', bins: 5, decimalPlaces: 1));
```

```text
.----------.------------.---------------------.
|   species|petal_length|petal_length_category|
:----------+------------+---------------------:
|    setosa|         1.4|           [0.8, 2.0)|
|    setosa|         1.4|           [0.8, 2.0)|
|    setosa|         1.3|           [0.8, 2.0)|
|    setosa|         1.5|           [0.8, 2.0)|
|versicolor|         4.7|           [4.2, 5.3)|
|versicolor|         4.5|           [4.2, 5.3)|
|versicolor|         4.9|           [4.2, 5.3)|
|versicolor|         4.0|           [3.1, 4.2)|
| virginica|         6.0|           [5.3, 6.5)|
| virginica|         5.1|           [4.2, 5.3)|
| virginica|         5.9|           [5.3, 6.5)|
| virginica|         5.6|           [5.3, 6.5)|
'----------'------------'---------------------'

[15978 μs]
```

