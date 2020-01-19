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
.---.-----------.-----------.----------.--------------------.
| id|sepal_width|petal_width|   species|sepal_width_z_scores|
:---+-----------+-----------+----------+--------------------:
| 16|        4.4|        0.4|    setosa|  3.0907752482994253|
|132|        3.8|        2.0| virginica|  1.7095946507475455|
| 54|        2.3|        1.3|versicolor| -1.7433568431321513|
|147|        2.5|        1.9| virginica|  -1.282963310614858|
| 70|        2.5|        1.1|versicolor|  -1.282963310614858|
| 90|        2.5|        1.3|versicolor|  -1.282963310614858|
|105|        3.0|        2.2| virginica| -0.1319794793216258|
| 10|        3.1|        0.1|    setosa| 0.09821728693702086|
|  3|        3.2|        0.2|    setosa|  0.3284140531956675|
| 64|        2.9|        1.4|versicolor|-0.36217624558027245|
'---'-----------'-----------'----------'--------------------'

[11885 μs]
```

