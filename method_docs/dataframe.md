Creates a data frame with `cats` and `nums` specified.
An empty data frame.
Creates a data frame from a map of lists.

The keys of the map are interpreted as the column names;
the values in the respective lists populate the rows.

Example:

```dart
final data = Dataframe.fromMapOfLists({
'id': [3, 55, 114, 107, 122],
'species': ['setosa', 'versicolor', 'virginica', 'virginica', 'virginica'],
'sepal_length': [4.7, 6.5, 5.7, 4.9, 5.6],
'sepal_width': [3.2, 2.8, 2.5, 2.5, 2.8],
'petal_length': [1.3, 4.6, 5.0, 4.5, 4.9],
'petal_width': [0.2, 1.5, 2.0, 1.7, 2.0]});

print(data);
```

```text
.----------.---.------------.-----------.------------.-----------.
|   species| id|sepal_length|sepal_width|petal_length|petal_width|
:----------+---+------------+-----------+------------+-----------:
|    setosa|  3|         4.7|        3.2|         1.3|        0.2|
|versicolor| 55|         6.5|        2.8|         4.6|        1.5|
| virginica|114|         5.7|        2.5|         5.0|        2.0|
| virginica|107|         4.9|        2.5|         4.5|        1.7|
| virginica|122|         5.6|        2.8|         4.9|        2.0|
'----------'---'------------'-----------'------------'-----------'

```

Creates a data frame from a json string.

The keys of the map are interpreted as the column names;
the values in the respective lists populate the rows.

Example:

```dart
print(Dataframe.fromJsonAsMapOfLists('''
{
"id":["3","4","5","6","53","54","55","56","103","104","105","106"],
"sepal_length":[4.7,4.6,5.0,5.4,6.9,5.5,6.5,5.7,7.1,6.3,6.5,7.6],
"sepal_width":[3.2,3.1,3.6,3.9,3.1,2.3,2.8,2.8,3.0,2.9,3.0,3.0]
}
'''));
```

```text
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

```

Creates a data frame form a list of maps.

Each map populates a row; the keys in each map determine
the column each value should be put into.

Example:

```dart
final data = Dataframe.fromListOfMaps([
{'id': 103, 'species': 'virginica', 'petal_length': 5.9, 'petal_width': 2.1},
{'id': 53, 'species': 'versicolor', 'petal_length': 4.9, 'petal_width': 1.5},
{'id': 52, 'species': 'versicolor', 'petal_length': 4.5, 'petal_width': 1.5},
{'id': 101, 'species': 'virginica', 'petal_length': 6.0, 'petal_width': 2.5},
{'id': 4, 'species': 'setosa', 'petal_length': 1.5, 'petal_width': 0.2}]);

print(data);
```

```text
.----------.---.------------.-----------.
|   species| id|petal_length|petal_width|
:----------+---+------------+-----------:
| virginica|103|         5.9|        2.1|
|versicolor| 53|         4.9|        1.5|
|versicolor| 52|         4.5|        1.5|
| virginica|101|         6.0|        2.5|
|    setosa|  4|         1.5|        0.2|
'----------'---'------------'-----------'

```

Creates a data fram from a json string.

Each map in the list is interpreted as an instance.

Example:

```dart
print(Dataframe.fromJsonAsListOfMaps('''
[
{
"id":"4",
"sepal_length":4.6,
"sepal_width":3.1
},{
"id":"53",
"sepal_length":6.9,
"sepal_width":3.1
},{
"id":"6",
"sepal_length":5.4,
"sepal_width":3.9
}
]
'''));
```

```text
.--.------------.-----------.
|id|sepal_length|sepal_width|
:--+------------+-----------:
| 4|         4.6|        3.1|
|53|         6.9|        3.1|
| 6|         5.4|        3.9|
'--'------------'-----------'

```

Creates a data frame from a csv expression.

Whether a column contains numeric or categorig is either
explicitly set using [types] or guessed based on the values
in the first row of data. A shorthand way of explicitly
defining column type is to include an asterisk (*) or carat (^) in
the column header to force a column to be categoric or numeric
respectively.

Example:

```dart
final data = Dataframe.fromCsv('''
id,sepal_length,sepal_width,petal_length,petal_width,species
57,6.3,3.3,4.7,1.6,versicolor
44,5.0,3.5,1.6,0.6,setosa
58,4.9,2.4,3.3,1.0,versicolor
68,5.8,2.7,4.1,1.0,versicolor
94,5.0,2.3,3.3,1.0,versicolor
''');

print(data);
```

```text
.--.------------.-----------.------------.-----------.----------.
|id|sepal_length|sepal_width|petal_length|petal_width|   species|
:--+------------+-----------+------------+-----------+----------:
|57|         6.3|        3.3|         4.7|        1.6|versicolor|
|44|         5.0|        3.5|         1.6|        0.6|    setosa|
|58|         4.9|        2.4|         3.3|        1.0|versicolor|
|68|         5.8|        2.7|         4.1|        1.0|versicolor|
|94|         5.0|        2.3|         3.3|        1.0|versicolor|
'--'------------'-----------'------------'-----------'----------'

```

The categoric columns in this data frame.
The numeric columns in this data frame.
The order of the columns in displays.
The names of the columns in this data frame.
The number of rows in this data frame.
The number of columns in this data frame.
A sequence of integers that runs along the rows of this data frame.
A summary of each column in this data frame.
Returns a data frame with just the first, specified number of rows.

Example:

```dart
print(iris.withHead(5));
```

```text
.--.------------.-----------.------------.-----------.-------.
|id|sepal_length|sepal_width|petal_length|petal_width|species|
:--+------------+-----------+------------+-----------+-------:
| 1|         5.1|        3.5|         1.4|        0.2| setosa|
| 2|         4.9|        3.0|         1.4|        0.2| setosa|
| 3|         4.7|        3.2|         1.3|        0.2| setosa|
| 4|         4.6|        3.1|         1.5|        0.2| setosa|
| 5|         5.0|        3.6|         1.4|        0.3| setosa|
'--'------------'-----------'------------'-----------'-------'

```

Returns a data frame with just the last, specified number of rows.

Example:

```dart
print(iris.withTail(5));
```

```text
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

Returns a data frame with the rows ordered by the values in the specified column.

Example:

```dart
print(petals.withRowsOrderedBy('petal_width'));
```

```text
.---.------------.-----------.----------.
| id|petal_length|petal_width|   species|
:---+------------+-----------+----------:
|  1|         1.4|        0.2|    setosa|
|  2|         1.4|        0.2|    setosa|
|  3|         1.3|        0.2|    setosa|
|  4|         1.5|        0.2|    setosa|
| 54|         4.0|        1.3|versicolor|
| 51|         4.7|        1.4|versicolor|
| 52|         4.5|        1.5|versicolor|
| 53|         4.9|        1.5|versicolor|
|104|         5.6|        1.8| virginica|
|102|         5.1|        1.9| virginica|
|103|         5.9|        2.1| virginica|
|101|         6.0|        2.5| virginica|
'---'------------'-----------'----------'

```

Gets a list of sample row indices.
Returns a data frame made up of rows randomly sampled from this data frame.

Example:

```dart
print(iris.withRowsSampled(5));
```

```text
.---.------------.-----------.------------.-----------.----------.
| id|sepal_length|sepal_width|petal_length|petal_width|   species|
:---+------------+-----------+------------+-----------+----------:
| 88|         6.3|        2.3|         4.4|        1.3|versicolor|
| 91|         5.5|        2.6|         4.4|        1.2|versicolor|
| 65|         5.6|        2.9|         3.6|        1.3|versicolor|
| 62|         5.9|        3.0|         4.2|        1.5|versicolor|
|136|         7.7|        3.0|         6.1|        2.3| virginica|
'---'------------'-----------'------------'-----------'----------'

```

Returns a data frame with a row index column added.
Ckecks whether all [columns] are actually columns.
Returns a data frame with only the specified columns, in that order.

Example:

```dart
print(petals.withColumns(['species', 'petal_length']));
```

```text
.----------.------------.
|   species|petal_length|
:----------+------------:
|    setosa|         1.4|
|    setosa|         1.4|
|    setosa|         1.3|
|    setosa|         1.5|
|versicolor|         4.7|
|versicolor|         4.5|
|versicolor|         4.9|
|versicolor|         4.0|
| virginica|         6.0|
| virginica|         5.1|
| virginica|         5.9|
| virginica|         5.6|
'----------'------------'

```

Returns a data frame with the specified columns dropped.

Example:

```dart
print(petals.withColumnsDropped(['id', 'petal_width']));
```

```text
.----------.------------.
|   species|petal_length|
:----------+------------:
|    setosa|         1.4|
|    setosa|         1.4|
|    setosa|         1.3|
|    setosa|         1.5|
|versicolor|         4.7|
|versicolor|         4.5|
|versicolor|         4.9|
|versicolor|         4.0|
| virginica|         6.0|
| virginica|         5.1|
| virginica|         5.9|
| virginica|         5.6|
'----------'------------'

```

Returns a data frame with the specified columns renamed.

Example:

```dart
print(petals.withColumnNamesChanged({
'petal_length': 'length',
'petal_width': 'width'}));
```

```text
.---.------.-----.----------.
| id|length|width|   species|
:---+------+-----+----------:
|  1|   1.4|  0.2|    setosa|
|  2|   1.4|  0.2|    setosa|
|  3|   1.3|  0.2|    setosa|
|  4|   1.5|  0.2|    setosa|
| 51|   4.7|  1.4|versicolor|
| 52|   4.5|  1.5|versicolor|
| 53|   4.9|  1.5|versicolor|
| 54|   4.0|  1.3|versicolor|
|101|   6.0|  2.5| virginica|
|102|   5.1|  1.9| virginica|
|103|   5.9|  2.1| virginica|
|104|   5.6|  1.8| virginica|
'---'------'-----'----------'

```

Returns a data frame with only the predicated columns.

Example:

```dart
print(petals.withColumnsWhere((column) => column.contains('petal')));
```

```text
.------------.-----------.
|petal_length|petal_width|
:------------+-----------:
|         1.4|        0.2|
|         1.4|        0.2|
|         1.3|        0.2|
|         1.5|        0.2|
|         4.7|        1.4|
|         4.5|        1.5|
|         4.9|        1.5|
|         4.0|        1.3|
|         6.0|        2.5|
|         5.1|        1.9|
|         5.9|        2.1|
|         5.6|        1.8|
'------------'-----------'

```

Returns a data frame with only the rows at specified indices.

Example:

```dart
print(iris.withRowsAtIndices([0, 20, 40]));
```

```text
.--.------------.-----------.------------.-----------.-------.
|id|sepal_length|sepal_width|petal_length|petal_width|species|
:--+------------+-----------+------------+-----------+-------:
| 1|         5.1|        3.5|         1.4|        0.2| setosa|
|21|         5.4|        3.4|         1.7|        0.2| setosa|
|41|         5.0|        3.5|         1.3|        0.3| setosa|
'--'------------'-----------'------------'-----------'-------'

```

A helper function that generates the values specified by a template.
A helper function that generates values from a formula.
Gives the indices that match a template predicate.
Gives the indices of rows whose values match the defined predicate.
Returns a data frame with only the rows that match a template predicate.

Example:

```dart
final template = '{id}-{species}';
print(petals.withRowsWhereTemplate(template,
(result) => result.contains('3') || result.contains('setosa')));
```

```text
.---.------------.-----------.----------.
| id|petal_length|petal_width|   species|
:---+------------+-----------+----------:
|  1|         1.4|        0.2|    setosa|
|  2|         1.4|        0.2|    setosa|
|  3|         1.3|        0.2|    setosa|
|  4|         1.5|        0.2|    setosa|
| 53|         4.9|        1.5|versicolor|
|103|         5.9|        2.1| virginica|
'---'------------'-----------'----------'

```

Gives the indices that match a formula predicate.
Returns a data frame with only the rows that match a formula predicate.

Example:

```dart
final formula = 'log(petal_length * petal_width)';
print(petals.withRowsWhereFormula(formula, (result) => result < 0));
```

```text
.--.------------.-----------.-------.
|id|petal_length|petal_width|species|
:--+------------+-----------+-------:
| 1|         1.4|        0.2| setosa|
| 2|         1.4|        0.2| setosa|
| 3|         1.3|        0.2| setosa|
| 4|         1.5|        0.2| setosa|
'--'------------'-----------'-------'

```

Gives the indices that match a template and formula predicate.
Returns a data frame with only the rows that match a template and formula predicate.

Example:

```dart
final template = '{species}', formula = 'petal_length / petal_width';
print(iris.withRowsWhereTemplateAndFormula(template, formula,
(templateResult, formulaResult) =>
templateResult == 'virginica' && formulaResult > 3));
```

```text
.---.------------.-----------.------------.-----------.---------.
| id|sepal_length|sepal_width|petal_length|petal_width|  species|
:---+------------+-----------+------------+-----------+---------:
|104|         6.3|        2.9|         5.6|        1.8|virginica|
|106|         7.6|        3.0|         6.6|        2.1|virginica|
|108|         7.3|        2.9|         6.3|        1.8|virginica|
|109|         6.7|        2.5|         5.8|        1.8|virginica|
|117|         6.5|        3.0|         5.5|        1.8|virginica|
|118|         7.7|        3.8|         6.7|        2.2|virginica|
|119|         7.7|        2.6|         6.9|        2.3|virginica|
|120|         6.0|        2.2|         5.0|        1.5|virginica|
|123|         7.7|        2.8|         6.7|        2.0|virginica|
|126|         7.2|        3.2|         6.0|        1.8|virginica|
|130|         7.2|        3.0|         5.8|        1.6|virginica|
|131|         7.4|        2.8|         6.1|        1.9|virginica|
|132|         7.9|        3.8|         6.4|        2.0|virginica|
|134|         6.3|        2.8|         5.1|        1.5|virginica|
|135|         6.1|        2.6|         5.6|        1.4|virginica|
|138|         6.4|        3.1|         5.5|        1.8|virginica|
'---'------------'-----------'------------'-----------'---------'

```

Returns the data frame with only rows matched by the defined predicate.

Example:

```dart
print(iris.withRowsWhereRowValues((cats, nums) =>
cats['species'] == 'virginica' && nums['petal_length'] > 6));
```

```text
.---.------------.-----------.------------.-----------.---------.
| id|sepal_length|sepal_width|petal_length|petal_width|  species|
:---+------------+-----------+------------+-----------+---------:
|106|         7.6|        3.0|         6.6|        2.1|virginica|
|108|         7.3|        2.9|         6.3|        1.8|virginica|
|110|         7.2|        3.6|         6.1|        2.5|virginica|
|118|         7.7|        3.8|         6.7|        2.2|virginica|
|119|         7.7|        2.6|         6.9|        2.3|virginica|
|123|         7.7|        2.8|         6.7|        2.0|virginica|
|131|         7.4|        2.8|         6.1|        1.9|virginica|
|132|         7.9|        3.8|         6.4|        2.0|virginica|
|136|         7.7|        3.0|         6.1|        2.3|virginica|
'---'------------'-----------'------------'-----------'---------'

```

Returns a data frame with a categoric column inserted.

Example:

```dart
print(sepals.withCategoric('species', petals.cats['species']));
```

```text
.---.------------.-----------.----------.
| id|sepal_length|sepal_width|   species|
:---+------------+-----------+----------:
|  3|         4.7|        3.2|    setosa|
|  4|         4.6|        3.1|    setosa|
|  5|         5.0|        3.6|    setosa|
|  6|         5.4|        3.9|    setosa|
| 53|         6.9|        3.1|versicolor|
| 54|         5.5|        2.3|versicolor|
| 55|         6.5|        2.8|versicolor|
| 56|         5.7|        2.8|versicolor|
|103|         7.1|        3.0| virginica|
|104|         6.3|        2.9| virginica|
|105|         6.5|        3.0| virginica|
|106|         7.6|        3.0| virginica|
'---'------------'-----------'----------'

```

Returns a data frame with a numeric inserted.

Example:

```dart
print(petals.withNumeric('sepal_length', sepals.nums['sepal_length']));
```

```text
.---.------------.-----------.----------.------------.
| id|petal_length|petal_width|   species|sepal_length|
:---+------------+-----------+----------+------------:
|  1|         1.4|        0.2|    setosa|         4.7|
|  2|         1.4|        0.2|    setosa|         4.6|
|  3|         1.3|        0.2|    setosa|         5.0|
|  4|         1.5|        0.2|    setosa|         5.4|
| 51|         4.7|        1.4|versicolor|         6.9|
| 52|         4.5|        1.5|versicolor|         5.5|
| 53|         4.9|        1.5|versicolor|         6.5|
| 54|         4.0|        1.3|versicolor|         5.7|
|101|         6.0|        2.5| virginica|         7.1|
|102|         5.1|        1.9| virginica|         6.3|
|103|         5.9|        2.1| virginica|         6.5|
|104|         5.6|        1.8| virginica|         7.6|
'---'------------'-----------'----------'------------'

```

Returns a data frame with a numeric based on an existing numeric.

Example:

```dart
print(petals.withNumericFromNumeric('petal_length_z', 'petal_length',
(result) => result.zScores));
```

```text
.---.------------.-----------.----------.-------------------.
| id|petal_length|petal_width|   species|     petal_length_z|
:---+------------+-----------+----------+-------------------:
|  1|         1.4|        0.2|    setosa| -1.350726370793662|
|  2|         1.4|        0.2|    setosa| -1.350726370793662|
|  3|         1.3|        0.2|    setosa|-1.4056711723174717|
|  4|         1.5|        0.2|    setosa| -1.295781569269852|
| 51|         4.7|        1.4|versicolor|  0.462452079492067|
| 52|         4.5|        1.5|versicolor|  0.352562476444447|
| 53|         4.9|        1.5|versicolor| 0.5723416825396871|
| 54|         4.0|        1.3|versicolor|0.07783846882539718|
|101|         6.0|        2.5| virginica| 1.1767344993015965|
|102|         5.1|        1.9| virginica| 0.6822312855873066|
|103|         5.9|        2.1| virginica| 1.1217896977777868|
|104|         5.6|        1.8| virginica| 0.9569552932063564|
'---'------------'-----------'----------'-------------------'

```

Returns a data frame with a numeric based on an existing categoric.

Example:

```dart
final sample = iris.withRowsSampled(10, seed: 0);
print(sample.withNumericFromCategoric('proportion', 'species',
(species) => Numeric(species.map((name) => species.proportions[name]))));
```

```text
.---.------------.-----------.------------.-----------.----------.----------.
| id|sepal_length|sepal_width|petal_length|petal_width|   species|proportion|
:---+------------+-----------+------------+-----------+----------+----------:
|111|         6.5|        3.2|         5.1|        2.0| virginica|       0.3|
|147|         6.3|        2.5|         5.0|        1.9| virginica|       0.3|
| 79|         6.0|        2.9|         4.5|        1.5|versicolor|       0.4|
| 34|         5.5|        4.2|         1.4|        0.2|    setosa|       0.3|
| 86|         6.0|        3.4|         4.5|        1.6|versicolor|       0.4|
| 61|         5.0|        2.0|         3.5|        1.0|versicolor|       0.4|
| 40|         5.1|        3.4|         1.5|        0.2|    setosa|       0.3|
|119|         7.7|        2.6|         6.9|        2.3| virginica|       0.3|
|  8|         5.0|        3.4|         1.5|        0.2|    setosa|       0.3|
| 56|         5.7|        2.8|         4.5|        1.3|versicolor|       0.4|
'---'------------'-----------'------------'-----------'----------'----------'

```

Returns a data frame with a categoric based on an existing numeric.

Example:

```dart
final sample = iris.withRowsSampled(10, seed: 0);
print(sample.withCategoricFromNumeric('sepal_length_outlier', 'sepal_length',
(width) => Categoric(width.map((w) => width.outliers.contains(w) ? 'yes': 'no'))));
```

```text
.---.------------.-----------.------------.-----------.----------.--------------------.
| id|sepal_length|sepal_width|petal_length|petal_width|   species|sepal_length_outlier|
:---+------------+-----------+------------+-----------+----------+--------------------:
|111|         6.5|        3.2|         5.1|        2.0| virginica|                  no|
|147|         6.3|        2.5|         5.0|        1.9| virginica|                  no|
| 79|         6.0|        2.9|         4.5|        1.5|versicolor|                  no|
| 34|         5.5|        4.2|         1.4|        0.2|    setosa|                  no|
| 86|         6.0|        3.4|         4.5|        1.6|versicolor|                  no|
| 61|         5.0|        2.0|         3.5|        1.0|versicolor|                  no|
| 40|         5.1|        3.4|         1.5|        0.2|    setosa|                  no|
|119|         7.7|        2.6|         6.9|        2.3| virginica|                 yes|
|  8|         5.0|        3.4|         1.5|        0.2|    setosa|                  no|
| 56|         5.7|        2.8|         4.5|        1.3|versicolor|                  no|
'---'------------'-----------'------------'-----------'----------'--------------------'

```

Returns a data frame with a categoric based on an existing categoric.

```dart
final sample = iris.withRowsSampled(10, seed: 0);
print(sample.withCategoricFromCategoric('rarity', 'species',
(species) => Categoric(
species.map((s) => species.proportions[s] <= 0.3 ? 'rare': 'common'))));
```

```text
.---.------------.-----------.------------.-----------.----------.------.
| id|sepal_length|sepal_width|petal_length|petal_width|   species|rarity|
:---+------------+-----------+------------+-----------+----------+------:
|111|         6.5|        3.2|         5.1|        2.0| virginica|  rare|
|147|         6.3|        2.5|         5.0|        1.9| virginica|  rare|
| 79|         6.0|        2.9|         4.5|        1.5|versicolor|common|
| 34|         5.5|        4.2|         1.4|        0.2|    setosa|  rare|
| 86|         6.0|        3.4|         4.5|        1.6|versicolor|common|
| 61|         5.0|        2.0|         3.5|        1.0|versicolor|common|
| 40|         5.1|        3.4|         1.5|        0.2|    setosa|  rare|
|119|         7.7|        2.6|         6.9|        2.3| virginica|  rare|
|  8|         5.0|        3.4|         1.5|        0.2|    setosa|  rare|
| 56|         5.7|        2.8|         4.5|        1.3|versicolor|common|
'---'------------'-----------'------------'-----------'----------'------'

```

Returns a data frame with a new categoric column created from a template.

Example:

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

```

Returns a data frame with a new numeric column created from a template.

Example:

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

```

Returns a data frame with a new categoric column created from a formula.

Example:

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

```

Returns a data frame with a new numeric column created from a formula.

Example:

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

```

Returns a data frame with a categoric column from a template and formula.
Returns a data frame with a numeric column from a template and formula.
Returns a data frame with a new categoric column created from the row values.

Example:

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

```

Returns a data frame with a numeric column from the row values.
Returns a data frame with a numeric column for each value in a categoric column.
Returns a left join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nLeft-join:');
print(petals.withLeftJoin(sepals, 'id'));
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

```

Returns a right join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nRight-join:');
print(petals.withRightJoin(sepals, 'id'));
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

```

Returns an inner join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nInner-join:');
print(petals.withInnerJoin(sepals, 'id'));
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

```

Returns a full join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nFull-join:');
print(petals.withFullJoin(sepals, 'id'));
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

```

Returns a left outer join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nLeft-outer-join:');
print(petals.withLeftOuterJoin(sepals, 'id'));
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

```

Returns a right outer join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

print('\nRight-outer-join:');
print(petals.withRightOuterJoin(sepals, 'id'));
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

```

Returns an outer join on the data frame.

Example:

```dart
print('Left: petals sample:');
print(petals);

print('\nRight: sepals sample:');
print(sepals);

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

Returns a data frame with the rows of [other] added.

Example:

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

```

TODO: document
TODO: document
Gives a map of data frames grouped by category.
TODO: document
Gives a map of data frames grouped by value.
Returns an object containing the data in the specified row

The returned object has map properties `cats` and `nums` with the
categorical and numerical row data respectively.

Example:

```dart
final rowData = petals.valuesInRow(0);
print(rowData);
```

```text
cats:
  id: 1
  species: setosa  
nums:
  petal_length: 1.4
  petal_width: 0.2
  
```

Gives a markdown representation of this data frame.

Example:

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

```

Gives a csv representation of this data frame.

Example:

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

```

Returns a json representation of the data frame.

The json represents a single list of maps representing instances.

Example:

```dart
print(sepals.withHead(2).toJsonAsListOfMaps());
```

```text
[{"id":"3","sepal_length":4.7,"sepal_width":3.2},{"id":"4","sepal_length":4.6,"sepal_width":3.1}]
```

Returns a json representation of the data frame.

The json represents a map with keys corresponding to column names
and lists as values corresponding to row data.

Example

```dart
print(sepals.withHead(2).toJsonAsMapOfLists());
```

```text
{"id":["3","4"],"sepal_length":[4.7,4.6],"sepal_width":[3.2,3.1]}
```

Gives an html table representation of this data frame.

Example:

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

```

Gives a map of lists, each column name as a key.
Gives a list of maps, each map representing a row.
Gives a list of strings generated from the row values.
Gives a string representation of this data frame.
