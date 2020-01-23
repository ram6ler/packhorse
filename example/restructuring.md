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

