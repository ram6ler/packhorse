# Examples

## Instantiation

### Columns

Instances of `NumericColumn` and `CategoricColumn` are generally instantiated directly from iterables:

```dart
final numeric = NumericColumn([1, 2, 3]),
  categoric = CategoricColumn(["a", "b", "c"]);

print(numeric);
print(categoric);
```

```text
NumericColumn [1, 2, 3]
CategoricColumn [a, b, c]

[618 μs]
```

Alternatively, we can instantiate these instances directly from lists:

```dart
final numeric = [1, 2, 3].toNumericColumn(),
    categoric = ["a", "b", "c"].toCategoricColumn();

print(numeric);
print(categoric);
```

```text
NumericColumn [1, 2, 3]
CategoricColumn [a, b, c]

[610 μs]
```

### Data frames

Instances of `DataFrame` can be instantiated from strings (csv or json representations), maps or lists. For example:

```dart
final df = """
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
""".parseAsCsv();

print(df);
```

```text

.---.------------.-----------.------------.
|id |petal_length|petal_width|species     |
:---+------------+-----------+------------:
|1  |1.4         |0.2        |setosa      |
|2  |1.4         |0.2        |setosa      |
|3  |1.3         |0.2        |setosa      |
|4  |1.5         |0.2        |setosa      |
|51 |4.7         |1.4        |versicolor  |
|52 |4.5         |1.5        |versicolor  |
|53 |4.9         |1.5        |versicolor  |
|54 |4.0         |1.3        |versicolor  |
|101|6.0         |2.5        |virginica   |
|102|5.1         |1.9        |virginica   |
|103|5.9         |2.1        |virginica   |
|104|5.6         |1.8        |virginica   |
'---'------------'-----------'------------'

[3729 μs]
```

```dart
final data = """
  {
    "a": [1, 2, 3],
    "b": ["red", "blue", "blue"]
  }
""".parseAsMapOfLists();

print(data);
```

```text

.-.------.
|a|b     |
:-+------:
|1|red   |
|2|blue  |
|3|blue  |
'-'------'

[5097 μs]
```

```dart
final data = """
  [
    {"a": 1, "b": "red"},
    {"a": 2, "b": "blue"},
    {"a": 3, "b": "blue"}
  ]
""".parseAsListOfMaps();

print(data);
```

```text

.-.------.
|a|b     |
:-+------:
|1|red   |
|2|blue  |
|3|blue  |
'-'------'

[4695 μs]
```

```dart
final data = {
  "a": [1, 2, 3],
  "b": ["red", "blue", "blue"]
}.toDataFrame();

print(data);
```

```text

.-.------.
|a|b     |
:-+------:
|1|red   |
|2|blue  |
|3|blue  |
'-'------'

[3297 μs]
```

```dart
final data = [
  {"a": 1, "b": "red"},
  {"a": 2, "b": "blue"},
  {"a": 3, "b": "blue"},
].toDataFrame();

print(data);
```

```text

.-.------.
|a|b     |
:-+------:
|1|red   |
|2|blue  |
|3|blue  |
'-'------'

[3067 μs]
```

## Manipulation

(In the following examples, the data frames `iris`, `petals` and `sepals` have been created from the famous [iris data set](https://en.wikipedia.org/wiki/Iris_flower_data_set).)

### `with...`

Methods that start with `with`, such as `withDataAdded`, `withColumns`, `withLeftJoin` and `withNumericFromFormula`, return new data frames, and thus can be conveniently chained:

```dart
final focus = iris
    .withColumnsDropped([
      "sepal_length",
      "petal_length",
    ])
    .withNumeric(
        name: "sepal_width_z_scores",
        column: NumericColumn(
            iris.numericColumns["sepal_width"]!.zScores,
        ),
    )
    .withRowsSampled(
      10,
      withReplacement: true,
      seed: 0,
    );

print(focus);
```

```text

.---.-----------.-----------.--------------------.------------.
|id |sepal_width|petal_width|sepal_width_z_scores|species     |
:---+-----------+-----------+--------------------+------------:
|106|3.0        |2.1        |-0.1319794793216258 |virginica   |
|60 |2.7        |1.4        |-0.8225697780975647 |versicolor  |
|65 |2.9        |1.3        |-0.36217624558027245|versicolor  |
|50 |3.3        |0.2        |0.5586108194543131  |setosa      |
|7  |3.4        |0.3        |0.7888075857129598  |setosa      |
|142|3.1        |2.3        |0.09821728693702086 |virginica   |
|45 |3.8        |0.4        |1.7095946507475455  |setosa      |
|32 |3.4        |0.4        |0.7888075857129598  |setosa      |
|92 |3.0        |1.4        |-0.1319794793216258 |versicolor  |
|120|2.2        |1.5        |-1.973553609390797  |virginica   |
'---'-----------'-----------'--------------------'------------'

[5571 μs]
```

## Mutating

Creating new columns from existing variables, is performed via

1. templates
2. formulas
3. row variable access

### 1. Using templates

A *template* is a string with placeholders marked with column names.
For example:

```dart
print(petals.withCategoricColumnFromTemplate(
  name: "id_code",
  template: "{species}-{id}"));
```

```text

.---.------------.-----------.------------.---------------.
|id |petal_length|petal_width|species     |id_code        |
:---+------------+-----------+------------+---------------:
|1  |1.4         |0.2        |setosa      |setosa-1       |
|2  |1.4         |0.2        |setosa      |setosa-2       |
|3  |1.3         |0.2        |setosa      |setosa-3       |
|4  |1.5         |0.2        |setosa      |setosa-4       |
|51 |4.7         |1.4        |versicolor  |versicolor-51  |
|52 |4.5         |1.5        |versicolor  |versicolor-52  |
|53 |4.9         |1.5        |versicolor  |versicolor-53  |
|54 |4.0         |1.3        |versicolor  |versicolor-54  |
|101|6.0         |2.5        |virginica   |virginica-101  |
|102|5.1         |1.9        |virginica   |virginica-102  |
|103|5.9         |2.1        |virginica   |virginica-103  |
|104|5.6         |1.8        |virginica   |virginica-104  |
'---'------------'-----------'------------'---------------'

[4609 μs]
```

We can also create numerical columns from templates:

```dart
print(petals.withNumericColumnFromTemplate(
  name: "species_letters",
  template: "{species}",
  generator: (result) => result.length,
));
```

```text

.---.------------.-----------.---------------.------------.
|id |petal_length|petal_width|species_letters|species     |
:---+------------+-----------+---------------+------------:
|1  |1.4         |0.2        |6              |setosa      |
|2  |1.4         |0.2        |6              |setosa      |
|3  |1.3         |0.2        |6              |setosa      |
|4  |1.5         |0.2        |6              |setosa      |
|51 |4.7         |1.4        |10             |versicolor  |
|52 |4.5         |1.5        |10             |versicolor  |
|53 |4.9         |1.5        |10             |versicolor  |
|54 |4.0         |1.3        |10             |versicolor  |
|101|6.0         |2.5        |9              |virginica   |
|102|5.1         |1.9        |9              |virginica   |
|103|5.9         |2.1        |9              |virginica   |
|104|5.6         |1.8        |9              |virginica   |
'---'------------'-----------'---------------'------------'

[4542 μs]
```

### 2. Using formulas

A *formula* is a mathematical expression using the numeric column
names as variables. (For more about the mathematical expressions supported, see the [function tree library](https://github.com/ram6ler/function-tree).)

For example:

```dart
print(petals.withNumericColumnFromFormula(
  name: "log_petal_area",
  formula: "log(petal_length * petal_width)",
));
```

```text

.---.------------.-----------.-------------------.------------.
|id |petal_length|petal_width|log_petal_area     |species     |
:---+------------+-----------+-------------------+------------:
|1  |1.4         |0.2        |-1.2729656758128876|setosa      |
|2  |1.4         |0.2        |-1.2729656758128876|setosa      |
|3  |1.3         |0.2        |-1.3470736479666092|setosa      |
|4  |1.5         |0.2        |-1.203972804325936 |setosa      |
|51 |4.7         |1.4        |1.884034745337226  |versicolor  |
|52 |4.5         |1.5        |1.9095425048844386 |versicolor  |
|53 |4.9         |1.5        |1.9947003132247454 |versicolor  |
|54 |4.0         |1.3        |1.6486586255873816 |versicolor  |
|101|6.0         |2.5        |2.70805020110221   |virginica   |
|102|5.1         |1.9        |2.2710944259026746 |virginica   |
|103|5.9         |2.1        |2.516889695641051  |virginica   |
|104|5.6         |1.8        |2.3105532626432224 |virginica   |
'---'------------'-----------'-------------------'------------'

[10118 μs]
```

We can also create categorical columns using formulas:

```dart
print(petals.withCategoricColumnFromFormula(
  name: "description",
  formula: "petal_width / petal_length",
  generator: (result) => result < 0.3 ? "narrow" : "wide",
));
```

```text

.---.------------.-----------.------------.-----------.
|id |petal_length|petal_width|species     |description|
:---+------------+-----------+------------+-----------:
|1  |1.4         |0.2        |setosa      |narrow     |
|2  |1.4         |0.2        |setosa      |narrow     |
|3  |1.3         |0.2        |setosa      |narrow     |
|4  |1.5         |0.2        |setosa      |narrow     |
|51 |4.7         |1.4        |versicolor  |narrow     |
|52 |4.5         |1.5        |versicolor  |wide       |
|53 |4.9         |1.5        |versicolor  |wide       |
|54 |4.0         |1.3        |versicolor  |wide       |
|101|6.0         |2.5        |virginica   |wide       |
|102|5.1         |1.9        |virginica   |wide       |
|103|5.9         |2.1        |virginica   |wide       |
|104|5.6         |1.8        |virginica   |wide       |
'---'------------'-----------'------------'-----------'

[5802 μs]
```

### 3. Using row variables

```dart
print(petals.withCategoricColumnFromRowValues(
  name: "code",
  generator: (numeric, categoric) {
    final pre = categoric["species"]!.substring(0, 3),
        area = (numeric["petal_length"]! * numeric["petal_width"]!)
            .toStringAsFixed(2)
            .padLeft(5, "0");
    return "$pre-$area";
  },
));
```

```text

.---.------------.-----------.------------.-----------.
|id |petal_length|petal_width|species     |code       |
:---+------------+-----------+------------+-----------:
|1  |1.4         |0.2        |setosa      |set-00.28  |
|2  |1.4         |0.2        |setosa      |set-00.28  |
|3  |1.3         |0.2        |setosa      |set-00.26  |
|4  |1.5         |0.2        |setosa      |set-00.30  |
|51 |4.7         |1.4        |versicolor  |ver-06.58  |
|52 |4.5         |1.5        |versicolor  |ver-06.75  |
|53 |4.9         |1.5        |versicolor  |ver-07.35  |
|54 |4.0         |1.3        |versicolor  |ver-05.20  |
|101|6.0         |2.5        |virginica   |vir-15.00  |
|102|5.1         |1.9        |virginica   |vir-09.69  |
|103|5.9         |2.1        |virginica   |vir-12.39  |
|104|5.6         |1.8        |virginica   |vir-10.08  |
'---'------------'-----------'------------'-----------'

[3781 μs]
```

## Products

We can output data frames to several text representations, such as markdown, csv and html:

```dart
print(petals.toMarkdown());
```

```text

|id|petal_length|petal_width|species|
|:--|:--|:--|:--|
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

[2850 μs]
```

```dart
print(petals.toCsv());
```

```text
id,petal_length,petal_width,species
1,1.4,0.2,"setosa"
2,1.4,0.2,"setosa"
3,1.3,0.2,"setosa"
4,1.5,0.2,"setosa"
51,4.7,1.4,"versicolor"
52,4.5,1.5,"versicolor"
53,4.9,1.5,"versicolor"
54,4.0,1.3,"versicolor"
101,6.0,2.5,"virginica"
102,5.1,1.9,"virginica"
103,5.9,2.1,"virginica"
104,5.6,1.8,"virginica"

[2052 μs]
```

```dart
print(petals.toHtml());
```

```text

<div class="packhorse">
<table>
  <thead>
    <tr><th>id</th><th>petal_length</th><th>petal_width</th><th>species</th></tr>
  </thead>
  <tbody>
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
  </tbody>
</table>
</div>

[2702 μs]
```

```dart
print(sepals.withHead(2).toJsonAsMapOfLists());
```

```text
{"id":["3","4"],"sepal_length":["4.7","4.6"],"sepal_width":["3.2","3.1"]}

[2779 μs]
```

## Adding data

We can vertically combine two data frames that have the same columns.

```dart
final headAndTail = iris.withHead(5).withRowsAdded(iris.withTail(5));
print(headAndTail);
```

```text

.---.------------.-----------.------------.-----------.-----------.
|id |sepal_length|sepal_width|petal_length|petal_width|species    |
:---+------------+-----------+------------+-----------+-----------:
|1  |5.1         |3.5        |1.4         |0.2        |setosa     |
|2  |4.9         |3.0        |1.4         |0.2        |setosa     |
|3  |4.7         |3.2        |1.3         |0.2        |setosa     |
|4  |4.6         |3.1        |1.5         |0.2        |setosa     |
|5  |5.0         |3.6        |1.4         |0.3        |setosa     |
|146|6.7         |3.0        |5.2         |2.3        |virginica  |
|147|6.3         |2.5        |5.0         |1.9        |virginica  |
|148|6.5         |3.0        |5.2         |2.0        |virginica  |
|149|6.2         |3.4        |5.4         |2.3        |virginica  |
|150|5.9         |3.0        |5.1         |1.8        |virginica  |
'---'------------'-----------'------------'-----------'-----------'

[4059 μs]
```

## Joins

Data frames support joins:

```dart
print("Left (petals sample):");
print(petals);

print("\nRight (sepals sample):");
print(sepals);

print("\nLeft-join:");
print(petals.withLeftJoinOn(sepals, pivot: "id"));

print("\nLeft-outer-join:");
print(petals.withLeftOuterJoinOn(sepals, pivot: "id"));

print("\nRight-join:");
print(petals.withRightJoinOn(sepals, pivot: "id"));

print("\nRight-outer-join:");
print(petals.withRightOuterJoinOn(sepals, pivot: "id"));

print("\nFull-join:");
print(petals.withFullJoinOn(sepals, pivot: "id"));

print("\nInner-join:");
print(petals.withInnerJoinOn(sepals, pivot: "id"));

print("\nOuter-join:");
print(petals.withOuterJoinOn(sepals, pivot: "id"));
```

```text
Left (petals sample):

.---.------------.-----------.------------.
|id |petal_length|petal_width|species     |
:---+------------+-----------+------------:
|1  |1.4         |0.2        |setosa      |
|2  |1.4         |0.2        |setosa      |
|3  |1.3         |0.2        |setosa      |
|4  |1.5         |0.2        |setosa      |
|51 |4.7         |1.4        |versicolor  |
|52 |4.5         |1.5        |versicolor  |
|53 |4.9         |1.5        |versicolor  |
|54 |4.0         |1.3        |versicolor  |
|101|6.0         |2.5        |virginica   |
|102|5.1         |1.9        |virginica   |
|103|5.9         |2.1        |virginica   |
|104|5.6         |1.8        |virginica   |
'---'------------'-----------'------------'

Right (sepals sample):

.---.------------.-----------.
|id |sepal_length|sepal_width|
:---+------------+-----------:
|3  |4.7         |3.2        |
|4  |4.6         |3.1        |
|5  |5.0         |3.6        |
|6  |5.4         |3.9        |
|53 |6.9         |3.1        |
|54 |5.5         |2.3        |
|55 |6.5         |2.8        |
|56 |5.7         |2.8        |
|103|7.1         |3.0        |
|104|6.3         |2.9        |
|105|6.5         |3.0        |
|106|7.6         |3.0        |
'---'------------'-----------'

Left-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|1  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|2  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|3  |1.3         |0.2        |3       |4.7         |3.2        |setosa      |
|4  |1.5         |0.2        |4       |4.6         |3.1        |setosa      |
|51 |4.7         |1.4        |NaN     |NaN         |NaN        |versicolor  |
|52 |4.5         |1.5        |NaN     |NaN         |NaN        |versicolor  |
|53 |4.9         |1.5        |53      |6.9         |3.1        |versicolor  |
|54 |4.0         |1.3        |54      |5.5         |2.3        |versicolor  |
|101|6.0         |2.5        |NaN     |NaN         |NaN        |virginica   |
|102|5.1         |1.9        |NaN     |NaN         |NaN        |virginica   |
|103|5.9         |2.1        |103     |7.1         |3.0        |virginica   |
|104|5.6         |1.8        |104     |6.3         |2.9        |virginica   |
'---'------------'-----------'--------'------------'-----------'------------'

Left-outer-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|1  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|2  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|51 |4.7         |1.4        |NaN     |NaN         |NaN        |versicolor  |
|52 |4.5         |1.5        |NaN     |NaN         |NaN        |versicolor  |
|101|6.0         |2.5        |NaN     |NaN         |NaN        |virginica   |
|102|5.1         |1.9        |NaN     |NaN         |NaN        |virginica   |
'---'------------'-----------'--------'------------'-----------'------------'

Right-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|3  |1.3         |0.2        |3       |4.7         |3.2        |setosa      |
|4  |1.5         |0.2        |4       |4.6         |3.1        |setosa      |
|NaN|NaN         |NaN        |5       |5.0         |3.6        |<NA>        |
|NaN|NaN         |NaN        |6       |5.4         |3.9        |<NA>        |
|53 |4.9         |1.5        |53      |6.9         |3.1        |versicolor  |
|54 |4.0         |1.3        |54      |5.5         |2.3        |versicolor  |
|NaN|NaN         |NaN        |55      |6.5         |2.8        |<NA>        |
|NaN|NaN         |NaN        |56      |5.7         |2.8        |<NA>        |
|103|5.9         |2.1        |103     |7.1         |3.0        |virginica   |
|104|5.6         |1.8        |104     |6.3         |2.9        |virginica   |
|NaN|NaN         |NaN        |105     |6.5         |3.0        |<NA>        |
|NaN|NaN         |NaN        |106     |7.6         |3.0        |<NA>        |
'---'------------'-----------'--------'------------'-----------'------------'

Right-outer-join:

.---.------------.-----------.--------.------------.-----------.-------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species|
:---+------------+-----------+--------+------------+-----------+-------:
|NaN|NaN         |NaN        |5       |5.0         |3.6        |<NA>   |
|NaN|NaN         |NaN        |6       |5.4         |3.9        |<NA>   |
|NaN|NaN         |NaN        |55      |6.5         |2.8        |<NA>   |
|NaN|NaN         |NaN        |56      |5.7         |2.8        |<NA>   |
|NaN|NaN         |NaN        |105     |6.5         |3.0        |<NA>   |
|NaN|NaN         |NaN        |106     |7.6         |3.0        |<NA>   |
'---'------------'-----------'--------'------------'-----------'-------'

Full-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|1  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|2  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|3  |1.3         |0.2        |3       |4.7         |3.2        |setosa      |
|4  |1.5         |0.2        |4       |4.6         |3.1        |setosa      |
|51 |4.7         |1.4        |NaN     |NaN         |NaN        |versicolor  |
|52 |4.5         |1.5        |NaN     |NaN         |NaN        |versicolor  |
|53 |4.9         |1.5        |53      |6.9         |3.1        |versicolor  |
|54 |4.0         |1.3        |54      |5.5         |2.3        |versicolor  |
|101|6.0         |2.5        |NaN     |NaN         |NaN        |virginica   |
|102|5.1         |1.9        |NaN     |NaN         |NaN        |virginica   |
|103|5.9         |2.1        |103     |7.1         |3.0        |virginica   |
|104|5.6         |1.8        |104     |6.3         |2.9        |virginica   |
|NaN|NaN         |NaN        |5       |5.0         |3.6        |<NA>        |
|NaN|NaN         |NaN        |6       |5.4         |3.9        |<NA>        |
|NaN|NaN         |NaN        |55      |6.5         |2.8        |<NA>        |
|NaN|NaN         |NaN        |56      |5.7         |2.8        |<NA>        |
|NaN|NaN         |NaN        |105     |6.5         |3.0        |<NA>        |
|NaN|NaN         |NaN        |106     |7.6         |3.0        |<NA>        |
'---'------------'-----------'--------'------------'-----------'------------'

Inner-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|3  |1.3         |0.2        |3       |4.7         |3.2        |setosa      |
|4  |1.5         |0.2        |4       |4.6         |3.1        |setosa      |
|53 |4.9         |1.5        |53      |6.9         |3.1        |versicolor  |
|54 |4.0         |1.3        |54      |5.5         |2.3        |versicolor  |
|103|5.9         |2.1        |103     |7.1         |3.0        |virginica   |
|104|5.6         |1.8        |104     |6.3         |2.9        |virginica   |
'---'------------'-----------'--------'------------'-----------'------------'

Outer-join:

.---.------------.-----------.--------.------------.-----------.------------.
|id |petal_length|petal_width|right_id|sepal_length|sepal_width|species     |
:---+------------+-----------+--------+------------+-----------+------------:
|NaN|NaN         |NaN        |5       |5.0         |3.6        |<NA>        |
|NaN|NaN         |NaN        |6       |5.4         |3.9        |<NA>        |
|NaN|NaN         |NaN        |55      |6.5         |2.8        |<NA>        |
|NaN|NaN         |NaN        |56      |5.7         |2.8        |<NA>        |
|NaN|NaN         |NaN        |105     |6.5         |3.0        |<NA>        |
|NaN|NaN         |NaN        |106     |7.6         |3.0        |<NA>        |
|1  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|2  |1.4         |0.2        |NaN     |NaN         |NaN        |setosa      |
|51 |4.7         |1.4        |NaN     |NaN         |NaN        |versicolor  |
|52 |4.5         |1.5        |NaN     |NaN         |NaN        |versicolor  |
|101|6.0         |2.5        |NaN     |NaN         |NaN        |virginica   |
|102|5.1         |1.9        |NaN     |NaN         |NaN        |virginica   |
'---'------------'-----------'--------'------------'-----------'------------'

[8591 μs]
```

## Statistics

Several commonly used statistics are built into the `Numeric` and
`Categoric` classes.

```dart
final variable = "petal_length", petalLength = iris.numericColumns[variable]!;

print("Column: $variable");
print("Whole-sample-mean: ${petalLength.mean.toStringAsFixed(2)}");
print("By species:");

iris.groupedByCategory("species").forEach((species, data) {
  final petalLength = data.numericColumns[variable]!;
  print("  $species: ${petalLength.mean.toStringAsFixed(2)}");
});
```

```text
Column: petal_length
Whole-sample-mean: 3.76
By species:
  setosa: 1.46
  versicolor: 4.26
  virginica: 5.55

[2225 μs]
```

We can get statistical summaries of a columns:

```dart
print("Sepal width:\n");
iris.numericColumns["sepal_width"]!.summary.forEach((statistic, value) {
  print("  $statistic: ${value.toStringAsFixed(2)}");
});
```

```text
Sepal width:

  sum: 458.60
  sumOfSquares: 1430.40
  mean: 3.06
  variance: 0.19
  inferredVariance: 0.19
  standardDeviation: 0.43
  inferredStandardDeviation: 0.44
  skewness: 0.03
  meanAbsoluteDeviation: 0.34
  lowerQuartile: 2.80
  median: 3.00
  upperQuartile: 3.30
  interQuartileRange: 0.50
  maximum: 4.40
  maximumNonOutlier: 4.00
  minimum: 2.00
  minimumNonOutlier: 2.20
  range: 2.40

[4797 μs]
```

```dart
print("Species:\n");
iris.categoricColumns["species"]!.summary.forEach((statistic, value) {
  print("  $statistic: ${value.toStringAsFixed(3)}");
});
```

```text
Species:

  impurity: 0.667
  entropy: 1.099

[1959 μs]
```

A summary of an entire data frame is in the form of a map with the
column names as the keys and the individual summaries as the values:

```dart
print("Summary of iris data frame columns:");
iris.withColumnsDropped(["id"]).summary.forEach((column, summary) {
  print("\n$column:");
  summary.forEach((statistic, value) {
      print("  $statistic: ${value.toStringAsFixed(2)}");
  });
});
```

```text
Summary of iris data frame columns:

sepal_length:
  sum: 876.50
  sumOfSquares: 5223.85
  mean: 5.84
  variance: 0.68
  inferredVariance: 0.69
  standardDeviation: 0.83
  inferredStandardDeviation: 0.83
  skewness: 0.03
  meanAbsoluteDeviation: 0.69
  lowerQuartile: 5.10
  median: 5.80
  upperQuartile: 6.40
  interQuartileRange: 1.30
  maximum: 7.90
  maximumNonOutlier: 7.90
  minimum: 4.30
  minimumNonOutlier: 4.30
  range: 3.60

sepal_width:
  sum: 458.60
  sumOfSquares: 1430.40
  mean: 3.06
  variance: 0.19
  inferredVariance: 0.19
  standardDeviation: 0.43
  inferredStandardDeviation: 0.44
  skewness: 0.03
  meanAbsoluteDeviation: 0.34
  lowerQuartile: 2.80
  median: 3.00
  upperQuartile: 3.30
  interQuartileRange: 0.50
  maximum: 4.40
  maximumNonOutlier: 4.00
  minimum: 2.00
  minimumNonOutlier: 2.20
  range: 2.40

petal_length:
  sum: 563.70
  sumOfSquares: 2582.71
  mean: 3.76
  variance: 3.10
  inferredVariance: 3.12
  standardDeviation: 1.76
  inferredStandardDeviation: 1.77
  skewness: -0.02
  meanAbsoluteDeviation: 1.56
  lowerQuartile: 1.60
  median: 4.35
  upperQuartile: 5.10
  interQuartileRange: 3.50
  maximum: 6.90
  maximumNonOutlier: 6.90
  minimum: 1.00
  minimumNonOutlier: 1.00
  range: 5.90

petal_width:
  sum: 180.00
  sumOfSquares: 302.38
  mean: 1.20
  variance: 0.58
  inferredVariance: 0.58
  standardDeviation: 0.76
  inferredStandardDeviation: 0.76
  skewness: -0.01
  meanAbsoluteDeviation: 0.66
  lowerQuartile: 0.30
  median: 1.30
  upperQuartile: 1.80
  interQuartileRange: 1.50
  maximum: 2.50
  maximumNonOutlier: 2.50
  minimum: 0.10
  minimumNonOutlier: 0.10
  range: 2.40

species:
  impurity: 0.67
  entropy: 1.10

[9099 μs]
```

## Bootstraps

We can use `bootstrapConfidenceIntervals` to generate bootstrapped confidence intervals for each of the statistics associated with the column type:

```dart
final intervals = await iris["petal_length"].bootstrapConfidenceIntervals();

for (final MapEntry(:key, :value) in intervals.entries) {
  final (lower, upper) = value;
  print("$key: [${lower.toStringAsFixed(2)}, ${upper.toStringAsFixed(2)}]");
}
```

```text
sum: [524.88, 610.80]
sumOfSquares: [2307.62, 2909.78]
mean: [3.50, 4.07]
variance: [2.67, 3.45]
inferredVariance: [2.69, 3.48]
standardDeviation: [1.63, 1.86]
inferredStandardDeviation: [1.64, 1.86]
skewness: [-0.05, -0.00]
meanAbsoluteDeviation: [1.37, 1.71]
lowerQuartile: [1.50, 2.17]
median: [4.00, 4.60]
upperQuartile: [4.90, 5.47]
interQuartileRange: [3.10, 3.83]
maximum: [6.60, 6.90]
maximumNonOutlier: [6.60, 6.90]
minimum: [1.00, 1.20]
minimumNonOutlier: [1.00, 1.20]
range: [5.50, 5.90]

[127466 μs]
```

## Quantizing a category

Sometimes it's helpful to generate category indicators:

```dart
print(petals
    .withColumns(["id", "species"])
    .withCategoricColumnEnumerated("species"));
```

```text

.---.--------------.------------------.-----------------.------------.
|id |species_setosa|species_versicolor|species_virginica|species     |
:---+--------------+------------------+-----------------+------------:
|1  |1             |0                 |0                |setosa      |
|2  |1             |0                 |0                |setosa      |
|3  |1             |0                 |0                |setosa      |
|4  |1             |0                 |0                |setosa      |
|51 |0             |1                 |0                |versicolor  |
|52 |0             |1                 |0                |versicolor  |
|53 |0             |1                 |0                |versicolor  |
|54 |0             |1                 |0                |versicolor  |
|101|0             |0                 |1                |virginica   |
|102|0             |0                 |1                |virginica   |
|103|0             |0                 |1                |virginica   |
|104|0             |0                 |1                |virginica   |
'---'--------------'------------------'-----------------'------------'

[3683 μs]
```

## Categorizing a quantity

We can generate categories for a numeric column by binning:

```dart
print(petals.withColumns(["species", "petal_length"]).withNumericColumnBinned(
  "petal_length",
  decimalPlaces: 1,
));
```

```text

.------------.------------.----------------.
|petal_length|species     |petal_length_bin|
:------------+------------+----------------:
|1.4         |setosa      |[0.8, 2.2)      |
|1.4         |setosa      |[0.8, 2.2)      |
|1.3         |setosa      |[0.8, 2.2)      |
|1.5         |setosa      |[0.8, 2.2)      |
|4.7         |versicolor  |[3.6, 5.1)      |
|4.5         |versicolor  |[3.6, 5.1)      |
|4.9         |versicolor  |[3.6, 5.1)      |
|4.0         |versicolor  |[3.6, 5.1)      |
|6.0         |virginica   |[5.1, 6.5)      |
|5.1         |virginica   |[5.1, 6.5)      |
|5.9         |virginica   |[5.1, 6.5)      |
|5.6         |virginica   |[5.1, 6.5)      |
'------------'------------'----------------'

[3978 μs]
```

Thanks for your interest in this library. Please [file bugs, issues and requests here](https://github.com/ram6ler/packhorse/issues).
