# `fromMapOfLists`

Creates a data frame from a map of lists.

The keys of the map are interpreted as the column names;
the values in the respective lists populate the rows.

Example:

```dart
final data = Dataframe.fromMapOfLists({
   'image': ['🍑', '🍆', '🍊', '🍓', '🍍'],
   'fruit': [
     'peach',
     'eggplant',
     'tangerine',
     'strawberry',
     'pineapple'
   ],
   'color': [
     'pink',
     'purple',
     'orange',
     'red',
     'yellow'
   ],
   'rating': [7, 7, 8, 9, 6]
 });

print(data);
```

```text
.-----.----------.------.------.
|image|     fruit| color|rating|
:-----+----------+------+------:
|   🍑|     peach|  pink|     7|
|   🍆|  eggplant|purple|     7|
|   🍊| tangerine|orange|     8|
|   🍓|strawberry|   red|     9|
|   🍍| pineapple|yellow|     6|
'-----'----------'------'------'

```

# `fromListOfMaps`

Creates a data frame form a list of maps.

Each map populates a row; the keys in each map determine
the column each value should be put into.

Example:

```dart
final data = Dataframe.fromListOfMaps([
  {'image': '🍑', 'fruit': 'peach', 'color': 'pink', 'rating': 7},
  {'image': '🍆', 'fruit': 'eggplant', 'color': 'purple', 'rating': 7},
  {'image': '🍊', 'fruit': 'tangerine', 'color': 'orange', 'rating': 8},
  {'image': '🍓', 'fruit': 'strawberry', 'color': 'red', 'rating': 9},
  {'image': '🍍', 'fruit': 'pineapple', 'color': 'yellow', 'rating': 6}
]);

print(data);
```

```text
.-----.----------.------.------.
|image|     fruit| color|rating|
:-----+----------+------+------:
|   🍑|     peach|  pink|     7|
|   🍆|  eggplant|purple|     7|
|   🍊| tangerine|orange|     8|
|   🍓|strawberry|   red|     9|
|   🍍| pineapple|yellow|     6|
'-----'----------'------'------'

```

# `fromCsv`

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
  image,fruit,color,rating
  🍑,peach,pink,7
  🍆,eggplant,purple,7
  🍊,tangerine,orange,8
  🍓,strawberry,red,9
  🍍,pineapple,yellow,6
''');

print(data);
```

```text
.-----.----------.------.------.
|image|     fruit| color|rating|
:-----+----------+------+------:
|   🍑|     peach|  pink|     7|
|   🍆|  eggplant|purple|     7|
|   🍊| tangerine|orange|     8|
|   🍓|strawberry|   red|     9|
|   🍍| pineapple|yellow|     6|
'-----'----------'------'------'

```

# `withLeftJoin`

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

# `withLeftOuterJoin`

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

# `withRightJoin`

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

# `withRightOuterJoin`

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

# `withFullJoin`

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

# `withInnerJoin`

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

# `withOuterJoin`

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

# `withCategoricFromTemplate`

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

# `withNumericFromTemplate`

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

# `withNumericFromFormula`

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

# `withCategoricFromFormula`

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

# `withCategoricFromRowValues`

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

# `withHead`

Returns a data frame containing the first [n] rows.

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

# `withTail`

Returns data frame containing the last [n] rows.

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

# `withRowsOrderedBy`

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

# `withRowsSampled`

Returns a data frame made up of rows randomly sampled from this data frame.

Example:

```dart
print(iris.withRowsSampled(5));
```

```text
.---.------------.-----------.------------.-----------.----------.
| id|sepal_length|sepal_width|petal_length|petal_width|   species|
:---+------------+-----------+------------+-----------+----------:
| 33|         5.2|        4.1|         1.5|        0.1|    setosa|
| 92|         6.1|        3.0|         4.6|        1.4|versicolor|
| 25|         4.8|        3.4|         1.9|        0.2|    setosa|
| 20|         5.1|        3.8|         1.5|        0.3|    setosa|
|112|         6.4|        2.7|         5.3|        1.9| virginica|
'---'------------'-----------'------------'-----------'----------'

```

# `withColumns`

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

# `withColumnsDropped`

Returns a data frame with the specified columns dropped.

Example:

```dart
print(petals.withColumnsDropped(['id', 'petal_width']));
```

```text
.------------.----------.
|petal_length|   species|
:------------+----------:
|         1.4|    setosa|
|         1.4|    setosa|
|         1.3|    setosa|
|         1.5|    setosa|
|         4.7|versicolor|
|         4.5|versicolor|
|         4.9|versicolor|
|         4.0|versicolor|
|         6.0| virginica|
|         5.1| virginica|
|         5.9| virginica|
|         5.6| virginica|
'------------'----------'

```

# `withColumnNamesChanged`

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

# `withColumnsWhere`

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

# `withRowsAtIndices`

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

# `withRowsWhereTemplate`

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

# `withRowsWhereFormula`

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

# `withRowsWhereTemplateAndFormula`

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

# `withRowsWhereRowValues`

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

# `withNumericFromNumeric`

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

# `withCategoricFromTemplate`

Returns a data frame with a categoric column from a template.

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

