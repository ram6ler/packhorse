# Packhorse

[Home](Home.md) | [Numeric](numeric.md) | [Categoric](categoric.md) | [Dataframe](dataframe.md) | [About](about.md)



## Dataframe

The `Dataframe` class is a representation of a data frame or table of records. Each column represents a variable and each row represents an instance for which the variables were measured or assessed.

In the examples that follow, we'll be using the following toy data sets taken from the famous [Fisher iris data set](https://en.wikipedia.org/wiki/Iris_flower_data_set):

### `petals`

|  id   | petal_length | petal_width |  species   |
| :---: | :----------: | :---------: | :--------: |
|   1   |     1.4      |     0.2     |   setosa   |
|   2   |     1.4      |     0.2     |   setosa   |
|   3   |     1.3      |     0.2     |   setosa   |
|   4   |     1.5      |     0.2     |   setosa   |
|  51   |     4.7      |     1.4     | versicolor |
|  52   |     4.5      |     1.5     | versicolor |
|  53   |     4.9      |     1.5     | versicolor |
|  54   |     4.0      |     1.3     | versicolor |
|  101  |     6.0      |     2.5     | virginica  |
|  102  |     5.1      |     1.9     | virginica  |
|  103  |     5.9      |     2.1     | virginica  |
|  104  |     5.6      |     1.8     | virginica  |

### `sepals`

|  id   | sepal_length | sepal_width |
| :---: | :----------: | :---------: |
|   3   |     4.7      |     3.2     |
|   4   |     4.6      |     3.1     |
|   5   |     5.0      |     3.6     |
|   6   |     5.4      |     3.9     |
|  53   |     6.9      |     3.1     |
|  54   |     5.5      |     2.3     |
|  55   |     6.5      |     2.8     |
|  56   |     5.7      |     2.8     |
|  103  |     7.1      |     3.0     |
|  104  |     6.3      |     2.9     |
|  105  |     6.5      |     3.0     |
|  106  |     7.6      |     3.0     |

### Reading the data

There are several ways to read the data into a `Dataframe` instance, including directly from a csv string through the `Dataframe.fromCsv` constructor:

```dart
final petals = Dataframe.fromCsv(await File("iris_petals_sample.csv").readAsString()),
      sepals = Dataframe.fromCsv(await File("iris_sepals_sample.csv").readAsString());
```

### Accessing the data

The data frame is a collection of instances of `Categoric`s and `Numeric`s that can be interpreted as a table with the instances as rows and the measures or categories as columns. The main way of accessing the columns of the data frame is via the maps `cats` and `nums` for categoric and numeric columns respectively. For example, let's say we're interested in finding the mean of the numeric column *petal_length* in the data frame `petals`:

```dart
print(petals.nums["petal_length"].mean);
```

```text
3.858333333333334

```

If we're interested in the value counts of the categoric column *species*:

```dart
petals.cats["species"].counts.forEach((species, count) {
  print("$species: $count");
});
```

```text
setosa: 4
versicolor: 4
virginica: 4

```

### Presenting the data

There are several methods for generating a presentation of the data contained in a `Dataframe` instance, including `toHtml` and `toMarkdown`. In this document we're just going to implicitly use the `toString` method to generate presentations:

```dart
print(petals);
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


```

```dart
print(sepals);
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

### Grouping the data

The `groupedByCategoric` and `groupedByNumeric` methods exist to split a data frame into sub data frames that are pure in terms of a specified column. For example, let's say that we would like to group the data in *petals* by *species*:

```dart
final mapOfDataframes = petals.groupedByCategoric("species");

mapOfDataframes.forEach((species, data) {
  print("$species:");
  print(data);
});
```

```text
setosa:
.--.-------.------------.-----------.
|id|species|petal_length|petal_width|
:--+-------+------------+-----------:
| 1| setosa|         1.4|        0.2|
| 2| setosa|         1.4|        0.2|
| 3| setosa|         1.3|        0.2|
| 4| setosa|         1.5|        0.2|
'--'-------'------------'-----------'

versicolor:
.--.----------.------------.-----------.
|id|   species|petal_length|petal_width|
:--+----------+------------+-----------:
|51|versicolor|         4.7|        1.4|
|52|versicolor|         4.5|        1.5|
|53|versicolor|         4.9|        1.5|
|54|versicolor|         4.0|        1.3|
'--'----------'------------'-----------'

virginica:
.---.---------.------------.-----------.
| id|  species|petal_length|petal_width|
:---+---------+------------+-----------:
|101|virginica|         6.0|        2.5|
|102|virginica|         5.1|        1.9|
|103|virginica|         5.9|        2.1|
|104|virginica|         5.6|        1.8|
'---'---------'------------'-----------'


```

### Templates and formulas

The packhorse library provides the user a high level of control in data manipulation via *templates* and *formulas*.

#### Templates

A *template* is a string such as `"{species}-{id}"` that is used to generate *strings* from the values in each row of a data frame, which can then be used as a filter or to generate new columns. Although numeric variable names can be included in a template (for example *id* might be a numeric column), templates are generally intended for generating strings from categories.

For example, say we want to only see the rows in `petals` for which the species is *versicolor*:

```dart
print(petals.withRowsWhereTemplate(
      "{species}", (templateValue) => templateValue == "versicolor"));
```

```text
.--.----------.------------.-----------.
|id|   species|petal_length|petal_width|
:--+----------+------------+-----------:
|51|versicolor|         4.7|        1.4|
|52|versicolor|         4.5|        1.5|
|53|versicolor|         4.9|        1.5|
|54|versicolor|         4.0|        1.3|
'--'----------'------------'-----------'


```

Say we want to create a new column that contains a code for each individual based on its *id* and *species*:

```dart
print(petals.withCategoricFromTemplate("code", "{species}:{id}",
  generator: (templateValue) {
    final datum = templateValue.split(":"),
      species = datum.first,
      id = datum.last;
    return "${species.substring(0, 3)}-${id.padLeft(3, "0")}";
  }));
```

```text
.---.----------.-------.------------.-----------.
| id|   species|   code|petal_length|petal_width|
:---+----------+-------+------------+-----------:
|  1|    setosa|set-001|         1.4|        0.2|
|  2|    setosa|set-002|         1.4|        0.2|
|  3|    setosa|set-003|         1.3|        0.2|
|  4|    setosa|set-004|         1.5|        0.2|
| 51|versicolor|ver-051|         4.7|        1.4|
| 52|versicolor|ver-052|         4.5|        1.5|
| 53|versicolor|ver-053|         4.9|        1.5|
| 54|versicolor|ver-054|         4.0|        1.3|
|101| virginica|vir-101|         6.0|        2.5|
|102| virginica|vir-102|         5.1|        1.9|
|103| virginica|vir-103|         5.9|        2.1|
|104| virginica|vir-104|         5.6|        1.8|
'---'----------'-------'------------'-----------'


```

#### Formulas

A *formula* is a string such as `"(log(petal_width) + log(petal_length)) / 2"` that is used to generate numeric values from the numeric values in row of a data frame, which can then be used as a filter or to generate new columns, in much the same way as templates. Note that only numeric column names are recognized in a formula.

For example, say we are just interested in the instances whose petal length-to-width ratio is greater than 3:

```dart
print(petals.withRowsWhereFormula(
      "petal_length / petal_width", (formulaResult) => formulaResult > 3));
```

```text
.---.----------.------------.-----------.
| id|   species|petal_length|petal_width|
:---+----------+------------+-----------:
|  1|    setosa|         1.4|        0.2|
|  2|    setosa|         1.4|        0.2|
|  3|    setosa|         1.3|        0.2|
|  4|    setosa|         1.5|        0.2|
| 51|versicolor|         4.7|        1.4|
| 53|versicolor|         4.9|        1.5|
| 54|versicolor|         4.0|        1.3|
|104| virginica|         5.6|        1.8|
'---'----------'------------'-----------'


```

We can be pretty free with our formulas; in general, if the expression is allowed in Dart the expression should be allowed as a formula (see package [function_tree](https://bitbucket.org/ram6ler/function-tree/wiki/Home) for further details). For example, let's create a new column that stores the mean of the logarithms of the sepal and petal lengths:

```dart
print(petals
  .withNumericFromFormula("mean_log",
    "(log(petal_width) + log(petal_length)) / 2"));
```

```text
.---.----------.------------.-----------.-------------------.
| id|   species|petal_length|petal_width|           mean_log|
:---+----------+------------+-----------+-------------------:
|  1|    setosa|         1.4|        0.2|-0.6364828379064437|
|  2|    setosa|         1.4|        0.2|-0.6364828379064437|
|  3|    setosa|         1.3|        0.2|-0.6735368239833046|
|  4|    setosa|         1.5|        0.2| -0.601986402162968|
| 51|versicolor|         4.7|        1.4|  0.942017372668613|
| 52|versicolor|         4.5|        1.5| 0.9547712524422193|
| 53|versicolor|         4.9|        1.5| 0.9973501566123727|
| 54|versicolor|         4.0|        1.3| 0.8243293127936908|
|101| virginica|         6.0|        2.5|  1.354025100551105|
|102| virginica|         5.1|        1.9| 1.1355472129513373|
|103| virginica|         5.9|        2.1| 1.2584448478205257|
|104| virginica|         5.6|        1.8| 1.1552766313216112|
'---'----------'------------'-----------'-------------------'


```

We can use templates and formulas to generate categoric or numerical columns for our data frame using the methods:

* `withCategoricFromTemplate`
* `withNumericFromTemplate`
* `withCategoricFromFormula`
* `withNumericFromFormula`
* `withCategoricFromTemplateAndFormula`
* `withNumericFromTemplateAndFormula`

All of these methods use a template and/or a formula to generate results and a *generator* to process the values thus obtained to produce the final column.

Similarly, methods `withCategoricFromRowValues` and `withNumericFromRowValues` exist to create columns based on the respective row values, but without using templates or formulas. For example, let's create a category that specifies whether a petal is *long* (longer than the respective species mean) or *short* (otherwise).

```dart

var speciesMeans = Map<String, num>();

// Populate speciesMeans with the mean for each species.
petals.groupedByCategoric("species").forEach((species, data) {
  speciesMeans[species] = data.nums["petal_length"].mean;
});

print(petals
  .withColumns(["species", "petal_length"])
  // Create a categoric column that depends on both species and petal_length.
  .withCategoricFromRowValues(
    "petal_adjective",
    (cats, nums) {
      final species = cats["species"], petalLength = nums["petal_length"];
      if (petalLength > speciesMeans[species]) {
        return "long";
      }
      return "short";
    }));

```

```text
.----------.---------------.------------.
|   species|petal_adjective|petal_length|
:----------+---------------+------------:
|    setosa|          short|         1.4|
|    setosa|          short|         1.4|
|    setosa|          short|         1.3|
|    setosa|           long|         1.5|
|versicolor|           long|         4.7|
|versicolor|          short|         4.5|
|versicolor|           long|         4.9|
|versicolor|          short|         4.0|
| virginica|           long|         6.0|
| virginica|          short|         5.1|
| virginica|           long|         5.9|
| virginica|          short|         5.6|
'----------'---------------'------------'


```

### Enumerating categoric data

We can use the `withCategoricEnumerated` method to create binary numeric columns from a categoric column. For example, let's enumerate the column *species*:

```dart
print(petals.withColumns(["species"]).withCategoricEnumerated("species"));
```

```text
.----------.--------------.------------------.-----------------.
|   species|species_setosa|species_versicolor|species_virginica|
:----------+--------------+------------------+-----------------:
|    setosa|             1|                 0|                0|
|    setosa|             1|                 0|                0|
|    setosa|             1|                 0|                0|
|    setosa|             1|                 0|                0|
|versicolor|             0|                 1|                0|
|versicolor|             0|                 1|                0|
|versicolor|             0|                 1|                0|
|versicolor|             0|                 1|                0|
| virginica|             0|                 0|                1|
| virginica|             0|                 0|                1|
| virginica|             0|                 0|                1|
| virginica|             0|                 0|                1|
'----------'--------------'------------------'-----------------'


```

### Joins

This library also provides support for data frame joins through the following methods:

* `withLeftJoin`
* `withRightJoin`
* `withInnerJoin`
* `withFullJoin`
* `withLeftOuterJoin`
* `withRightOuterJoin`
* `withOuterJoin`

For example, let's perform an inner join on the data frames *petals* and *sepals*:

```dart
print(petals.withInnerJoin(sepals, "id"));
```

```text
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

A left join, on the other hand, would be:

```dart
print(petals.withLeftJoin(sepals, "id"));
```

```text
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
