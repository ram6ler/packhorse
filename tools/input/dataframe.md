
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

If we're interested in the value counts of the categoric column *species*:

```dart
petals.cats["species"].counts.forEach((species, count) {
  print("$species: $count");
});
```

### Presenting the data

There are several methods for generating a presentation of the data contained in a `Dataframe` instance, including `toHtml` and `toMarkdown`. In this document we're just going to implicitly use the `toString` method to generate presentations:

```dart
print(petals);
```

```dart
print(sepals);
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

### Templates and formulas

The packhorse library provides the user a high level of control in data manipulation via *templates* and *formulas*.

#### Templates

A *template* is a string such as `"{species}-{id}"` that is used to generate *strings* from the values in each row of a data frame, which can then be used as a filter or to generate new columns. Although numeric variable names can be included in a template (for example *id* might be a numeric column), templates are generally intended for generating strings from categories.

For example, say we want to only see the rows in `petals` for which the species is *versicolor*:

```dart
print(petals.withRowsWhereTemplate(
      "{species}", (templateValue) => templateValue == "versicolor"));
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

#### Formulas

A *formula* is a string such as `"(log(petal_width) + log(petal_length)) / 2"` that is used to generate numeric values from the numeric values in row of a data frame, which can then be used as a filter or to generate new columns, in much the same way as templates. Note that only numeric column names are recognized in a formula.

For example, say we are just interested in the instances whose petal length-to-width ratio is greater than 3:

```dart
print(petals.withRowsWhereFormula(
      "petal_length / petal_width", (formulaResult) => formulaResult > 3));
```

We can be pretty free with our formulas; in general, if the expression is allowed in Dart the expression should be allowed as a formula (see package [function_tree](https://bitbucket.org/ram6ler/function-tree/wiki/Home) for further details). For example, let's create a new column that stores the mean of the logarithms of the sepal and petal lengths:

```dart
print(petals
  .withNumericFromFormula("mean_log",
    "(log(petal_width) + log(petal_length)) / 2"));
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

### Enumerating categoric data

We can use the `withCategoricEnumerated` method to create binary numeric columns from a categoric column. For example, let's enumerate the column *species*:

```dart
print(petals.withColumns(["species"]).withCategoricEnumerated("species"));
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

A left join, on the other hand, would be:

```dart
print(petals.withLeftJoin(sepals, "id"));
```