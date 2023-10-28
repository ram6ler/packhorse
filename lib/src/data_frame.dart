import "dart:math" as math;
import "dart:convert" show json;

import "package:function_tree/function_tree.dart"
    show FunctionTreeStringMethods;

import 'error.dart' show PackhorseError;
import 'column.dart' show Column, NumericColumn, CategoricColumn;
import 'extensions.dart' show PackhorseStringMethods;

enum ColumnType {
  /// A column type for storing categorical data.
  categoric,

  /// A column type for storing numeric data.
  numeric;
}

enum MarkdownAlignment {
  /// Left markdown column alignment.
  left,

  /// Right markdown column alignment.
  right,

  /// Center markdown column alignment.
  center;

  String get mark =>
      switch (this) { left => ":--", right => "--:", center => ":--:" };
}

/// A representation of a frame (table) of data.
class DataFrame {
  /// Whether a column name is okay as a function tree variable.
  static bool _columnNameOkay(String name) =>
      RegExp(r"^[a-zA-Z][a-zA-Z0-9_]*$").hasMatch(name);

  DataFrame({
    required this.numericColumns,
    required this.categoricColumns,
    bool ignoreLengthMismatch = false,
  }) {
    final lengths = [
      ...[for (final k in numericColumns.keys) numericColumns[k]!.length],
      ...[for (final k in categoricColumns.keys) categoricColumns[k]!.length]
    ];
    if (lengths.toSet().length > 1 && !ignoreLengthMismatch) {
      throw PackhorseError.badStructure("Columns have different lengths."
          "Set ignoreLengthMismatch = true to accept row wrapping.");
    }
  }

  /// A copy of this data frame.
  DataFrame get copy {
    final numericColumns = {
          for (final MapEntry(:key, :value) in this.numericColumns.entries)
            key: NumericColumn(value.values)
        },
        categoricColumns = {
          for (final MapEntry(:key, :value) in this.categoricColumns.entries)
            key: CategoricColumn(value.values)
        };
    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A data frame built from a csv string.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromCsv("""
  ///  a,b,c
  ///  1,5.1,"red"
  ///  3,2.7,"green"
  ///  5,-0.9,"red"
  /// """);
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  factory DataFrame.fromCsv(
    String text, {
    String separator = ",",
    String quote = '"',
    Map<String, ColumnType>? types,
  }) {
    types = types ?? {};
    final splitPattern = RegExp(r"\r?\n"),
        itemPattern = RegExp("""^ *$quote?([^$quote$separator]*)$quote?,?"""),
        lines = [
          for (final line in text.split(splitPattern))
            if (line.trim().isNotEmpty) line.trim()
        ],
        numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{};

    List<String> getCells(String line) {
      final result = <String>[];
      while (line.isNotEmpty && itemPattern.hasMatch(line)) {
        final match = itemPattern.firstMatch(line)!;
        result.add(match.group(1)!.trim());
        line = line.substring(match.end);
      }
      return result;
    }

    final columnNames = getCells(lines.first),
        stringValues = {for (final k in columnNames) k: <String>[]};

    if (columnNames.any((name) => !_columnNameOkay(name))) {
      throw PackhorseError.badColumnName([
        for (final columnName in columnNames)
          "  '${columnName.padRight(20, ".")}' "
              "${_columnNameOkay(columnName) ? "okay" : "not okay"}"
      ].join("\n"));
    }

    for (final row in lines.sublist(1)) {
      final values = getCells(row);
      if (values.length != columnNames.length) {
        throw PackhorseError.badStructure(
            "Csv row with incorrect length:\n  $row");
      }
      for (var i = 0; i < columnNames.length; i++) {
        stringValues[columnNames[i]]!.add(values[i]);
      }
    }

    for (final columnName in columnNames) {
      if (types.containsKey(columnName)) {
        switch (types[columnName]!) {
          case ColumnType.categoric:
            categoricColumns[columnName] =
                CategoricColumn(stringValues[columnName]!);
          case ColumnType.numeric:
            numericColumns[columnName] = NumericColumn(stringValues[columnName]!
                .map((x) => num.tryParse(x) ?? double.nan));
        }
      } else {
        final firstParsedValue = num.tryParse(stringValues[columnName]!.first);
        if (firstParsedValue == null) {
          categoricColumns[columnName] =
              CategoricColumn(stringValues[columnName]!);
        } else {
          numericColumns[columnName] = NumericColumn(stringValues[columnName]!
              .map((x) => num.tryParse(x) ?? double.nan));
        }
      }
    }

    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A data frame built from a map of lists.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromMapOfLists({
  ///    "a": [1, 3, 5],
  ///    "b": [5.1, 2.7, -0.9],
  ///    "c": ["red", "green", "red"],
  /// });
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  factory DataFrame.fromMapOfLists(
    Map<String, List<Object>> data, {
    Map<String, ColumnType>? types,
  }) {
    types = types ?? {};
    final numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{};
    for (var MapEntry(key: key, value: xs) in data.entries) {
      if (types.containsKey(key)) {
        switch (types[key]!) {
          case ColumnType.numeric:
            numericColumns[key] = NumericColumn(
                xs.map((x) => num.tryParse(x.toString()) ?? double.nan));
          case ColumnType.categoric:
            categoricColumns[key] =
                CategoricColumn(xs.map((x) => x.toString()));
        }
      } else {
        final firstParsedValue = num.tryParse(xs.first.toString());
        if (firstParsedValue == null) {
          categoricColumns[key] = CategoricColumn(xs.map((x) => x.toString()));
        } else {
          numericColumns[key] = NumericColumn(
              xs.map((x) => num.tryParse(x.toString()) ?? double.nan));
        }
      }
    }

    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A data frame built from a json string representation of a map of lists.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromJsonAsMapOfLists("""
  ///   {
  ///     "a": [1, 3, 5],
  ///     "b": [5.1, 2.7, -0.9],
  ///     "c": ["red", "green", "red"]
  ///   }
  /// """);
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  factory DataFrame.fromJsonAsMapOfLists(
    String jsonString, {
    Map<String, ColumnType>? types,
  }) =>
      jsonString.parseAsMapOfLists(types: types ?? {});

  /// A data frame built from a list of maps.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromListOfMaps([
  ///   {"a": 1, "b": 5.1, "c": "red"},
  ///   {"a": 3, "b": 2.7, "c": "green"},
  ///   {"a": 5, "b": -0.9, "c": "red"},
  /// ]);
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  factory DataFrame.fromListOfMaps(
    List<Map<String, Object>> data, {
    Map<String, ColumnType>? types,
  }) {
    types = types ?? {};
    final numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{};
    for (final key in data.first.keys) {
      if (types.containsKey(key)) {
        switch (types[key]!) {
          case ColumnType.numeric:
            numericColumns[key] = NumericColumn([]);
          case ColumnType.categoric:
            categoricColumns[key] = CategoricColumn([]);
        }
      } else {
        final firstParsedValue = num.tryParse(data.first[key]!.toString());
        if (firstParsedValue == null) {
          types[key] = ColumnType.categoric;
          categoricColumns[key] = CategoricColumn([]);
        } else {
          types[key] = ColumnType.numeric;
          numericColumns[key] = NumericColumn([]);
        }
      }
    }
    for (final datum in data) {
      for (final key in datum.keys) {
        switch (types[key]!) {
          case ColumnType.numeric:
            numericColumns[key]!.add(
              num.tryParse(datum[key]!.toString()) ?? double.nan,
            );
          case ColumnType.categoric:
            categoricColumns[key]!.add(datum[key]!.toString());
        }
      }
    }
    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A data frame built from a json string representation of a list of maps.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromJsonAsListOfMaps(
  /// """
  /// [
  ///   {"a": 1, "b": 5.1, "c": "red"},
  ///   {"a": 3, "b": 2.7, "c": "green"},
  ///   {"a": 5, "b": -0.9, "c": "red"}
  /// ]
  /// """);
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  factory DataFrame.fromJsonAsListOfMaps(
    String jsonString, {
    Map<String, ColumnType>? types,
  }) =>
      jsonString.parseAsListOfMaps(types: types ?? {});

  /// The columns in this data frame containing categorical data.
  final Map<String, CategoricColumn> categoricColumns;

  /// The columns in this data frame containing numeric data.
  final Map<String, NumericColumn> numericColumns;

  /// A copy of the names of the columns in this data frame.
  List<String> get columnNames =>
      [...numericColumns.keys, ...categoricColumns.keys];

  /// The number of columns.
  int get columnNumber => numericColumns.length + categoricColumns.length;

  /// The umber of rows.
  int get rowNumber => [
        ...numericColumns.values.map((x) => x.length),
        ...categoricColumns.values.map((x) => x.length)
      ].reduce(math.max);

  Column operator [](String key) {
    if (numericColumns.containsKey(key)) {
      return numericColumns[key]!;
    }
    if (categoricColumns.containsKey(key)) {
      return categoricColumns[key]!;
    }
    throw PackhorseError.badArgument("Data frame has no column '$key'.");
  }

  /// A statistical summary of each column in this data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///     a,b
  ///     5,red
  ///     9,green
  ///     3,blue
  ///     2,red
  /// """.parseAsCsv();
  ///
  /// for (final MapEntry(:key, :value) in d.summary.entries) {
  ///   print("\nColumn '$key':");
  ///   for (final MapEntry(:key, :value) in value.entries) {
  ///     print("  $key: ${value.toStringAsFixed(2)}");
  ///   }
  /// }
  /// ```
  ///
  /// ```text
  /// Column 'a':
  ///   sum: 19.00
  ///   sumOfSquares: 119.00
  ///   mean: 4.75
  ///   variance: 7.19
  ///   inferredVariance: 9.58
  ///   standardDeviation: 2.68
  ///   inferredStandardDeviation: 3.10
  ///   skewness: 0.33
  ///   meanAbsoluteDeviation: 2.25
  ///   lowerQuartile: 2.75
  ///   median: 4.00
  ///   upperQuartile: 6.00
  ///   interQuartileRange: 3.25
  ///   maximum: 9.00
  ///   maximumNonOutlier: 9.00
  ///   minimum: 2.00
  ///   minimumNonOutlier: 2.00
  ///   range: 7.00
  /// Column 'b':
  ///   impurity: 0.63
  ///   entropy: 1.04
  /// ```
  ///
  Map<String, Map<String, num>> get summary => {
        for (final MapEntry(:key, :value) in numericColumns.entries)
          key: value.summary,
        for (final MapEntry(:key, :value) in categoricColumns.entries)
          key: value.summary,
      };

  /// A new data frame comprising the rows at `indices`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = DataFrame.fromCsv("""
  ///  a,b,c
  ///  1,5.1,"red"
  ///  3,2.7,"green"
  ///  5,-0.9,"red"
  /// """);
  ///
  /// print(d.withRowsAtIndices([2, 1, 0, 1, 2]));
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |5|-0.9|red    |
  /// |3|2.7 |green  |
  /// |1|5.1 |red    |
  /// |3|2.7 |green  |
  /// |5|-0.9|red    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  DataFrame withRowsAtIndices(Iterable<int> indices) =>
      DataFrame(numericColumns: {
        for (final MapEntry(:key, :value) in numericColumns.entries)
          key: NumericColumn(value.valuesAtIndices(indices))
      }, categoricColumns: {
        for (final MapEntry(:key, :value) in categoricColumns.entries)
          key: CategoricColumn(value.valuesAtIndices(indices))
      });

  /// A new data frame with only the first `n` rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withHead(3));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.--------.
  /// |id|petal_length|petal_width|species |
  /// :--+------------+-----------+--------:
  /// |1 |1.4         |0.2        |setosa  |
  /// |2 |1.4         |0.2        |setosa  |
  /// |3 |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'--------'
  ///
  /// ```
  ///
  DataFrame withHead([int n = 10]) {
    final numberOfRows = this.rowNumber;
    return withRowsAtIndices(
        [for (var i = 0; i < math.min(numberOfRows, n); i++) i]);
  }

  /// A new data frame with only the last `n` rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withTail(3));
  /// ```
  ///
  /// ```text
  ///
  /// .---.------------.-----------.-----------.
  /// |id |petal_length|petal_width|species    |
  /// :---+------------+-----------+-----------:
  /// |102|5.1         |1.9        |virginica  |
  /// |103|5.9         |2.1        |virginica  |
  /// |104|5.6         |1.8        |virginica  |
  /// '---'------------'-----------'-----------'
  ///
  /// ```
  ///
  DataFrame withTail([int n = 10]) {
    final numberOfRows = this.rowNumber;
    return withRowsAtIndices(
        [for (var i = math.max(0, numberOfRows - n); i < numberOfRows; i++) i]);
  }

  /// A new data frame with only the selected columns.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(3));
  /// print(iris.withHead(3).withColumns(["petal_length", "species"]));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// .------------.--------.
  /// |petal_length|species |
  /// :------------+--------:
  /// |1.4         |setosa  |
  /// |1.4         |setosa  |
  /// |1.3         |setosa  |
  /// '------------'--------'
  ///
  /// ```
  ///
  DataFrame withColumns(Iterable<String> columnNames) => DataFrame(
        numericColumns: {
          for (final MapEntry(:key, :value) in numericColumns.entries)
            if (columnNames.contains(key)) key: NumericColumn(value.values)
        },
        categoricColumns: {
          for (final MapEntry(:key, :value) in categoricColumns.entries)
            if (columnNames.contains(key)) key: CategoricColumn(value.values)
        },
      );

  /// A new data frame without the selected columns.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(3));
  /// print(iris.withHead(3).withColumnsDropped(["petal_length", "species"]));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// .--.------------.-----------.-----------.
  /// |id|sepal_length|sepal_width|petal_width|
  /// :--+------------+-----------+-----------:
  /// |1 |5.1         |3.5        |0.2        |
  /// |2 |4.9         |3.0        |0.2        |
  /// |3 |4.7         |3.2        |0.2        |
  /// '--'------------'-----------'-----------'
  ///
  /// ```
  ///
  DataFrame withColumnsDropped(Iterable<String> columnNames) => withColumns([
        ...numericColumns.keys
            .where((columnName) => !columnNames.contains(columnName)),
        ...categoricColumns.keys
            .where((columnName) => !columnNames.contains(columnName))
      ]);

  /// A new data frame with the column names changed.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(3));
  /// print(iris.withHead(3).withColumnNamesChanged({
  ///   "sepal_width": "sw",
  ///   "petal_width": "pw",
  /// }));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// .--.------------.---.------------.---.--------.
  /// |id|sepal_length|sw |petal_length|pw |species |
  /// :--+------------+---+------------+---+--------:
  /// |1 |5.1         |3.5|1.4         |0.2|setosa  |
  /// |2 |4.9         |3.0|1.4         |0.2|setosa  |
  /// |3 |4.7         |3.2|1.3         |0.2|setosa  |
  /// '--'------------'---'------------'---'--------'
  ///
  /// ```
  ///
  DataFrame withColumnNamesChanged(Map<String, String> changes) {
    final numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{};
    for (final MapEntry(:key, :value) in this.numericColumns.entries) {
      numericColumns[changes.containsKey(key) ? changes[key]! : key] =
          NumericColumn(value.values);
    }
    for (final MapEntry(:key, :value) in this.categoricColumns.entries) {
      categoricColumns[changes.containsKey(key) ? changes[key]! : key] =
          CategoricColumn(value.values);
    }
    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A new data frame with only the columns whose names meet predicate.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(3));
  /// print(iris.withHead(3).withColumnsWhere((c) => c.contains("sepal")));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// .------------.-----------.
  /// |sepal_length|sepal_width|
  /// :------------+-----------:
  /// |5.1         |3.5        |
  /// |4.9         |3.0        |
  /// |4.7         |3.2        |
  /// '------------'-----------'
  ///
  /// ```
  ///
  DataFrame withColumnsWhere(bool Function(String) predicate) => withColumns(
      [...numericColumns.keys, ...categoricColumns.keys].where(predicate));

  /// A new data frame with the rows ordered by the values in `columns`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   x,y,z
  ///   9,3,bat
  ///   3,6,zebra
  ///   7,4,moose
  ///   3,8,bat
  ///   8,4,zebra
  ///   6,5,bat,
  ///   1,7,zebra
  ///   3,9,moose
  /// """.parseAsCsv();
  ///
  /// print(d.withRowsOrderedBy(["z", "x"]));
  /// ```
  ///
  /// ```text
  ///
  /// .-.-.-------.
  /// |x|y|z      |
  /// :-+-+-------:
  /// |3|8|bat    |
  /// |6|5|bat    |
  /// |9|3|bat    |
  /// |3|9|moose  |
  /// |7|4|moose  |
  /// |1|7|zebra  |
  /// |3|6|zebra  |
  /// |8|4|zebra  |
  /// '-'-'-------'
  ///
  /// ```
  ///
  DataFrame withRowsOrderedBy(
    List<String> columns, {
    bool decreasing = false,
  }) {
    int compareLists(
      List<int> a,
      List<int> b, [
      int index = 0,
    ]) =>
        index == a.length
            ? 0
            : (a[index] > b[index]
                ? 1
                : (a[index] < b[index]
                    ? -1
                    : compareLists(
                        a,
                        b,
                        index + 1,
                      )));

    final orderCriterion = [
          for (var _ = 0; _ < rowNumber; _++)
            [for (var _ = 0; _ < columns.length; _++) 0]
        ],
        uniqueNumeric = {
          for (final MapEntry(:key, :value) in numericColumns.entries)
            key: NumericColumn(value.uniqueValues)
        },
        uniqueNumericIndexOrders = <String, Map<num, int>>{},
        uniqueCategoric = {
          for (final MapEntry(:key, :value) in categoricColumns.entries)
            key: CategoricColumn(value.uniqueValues)
        },
        uniqueCategoricIndexOrders = <String, Map<String, int>>{};

    for (final MapEntry(:key, :value) in uniqueNumeric.entries) {
      final indexOrders = value.indexOrders;
      uniqueNumericIndexOrders[key] = {};
      for (var i = 0; i < value.length; i++) {
        uniqueNumericIndexOrders[key]![value[i]] = indexOrders[i];
      }
    }

    for (final MapEntry(:key, :value) in uniqueCategoric.entries) {
      final indexOrders = value.indexOrders;
      uniqueCategoricIndexOrders[key] = {};
      for (var i = 0; i < value.length; i++) {
        uniqueCategoricIndexOrders[key]![value[i]] = indexOrders[i];
      }
    }

    void updateIndexOrders(List<int> indexOrders, int index) {
      for (var i = 0; i < rowNumber; i++) {
        orderCriterion[i][index] = indexOrders[i];
      }
    }

    for (var i = 0; i < columns.length; i++) {
      final columnName = columns[i];
      if (numericColumns.containsKey(columnName)) {
        updateIndexOrders([
          for (final x in numericColumns[columnName]!.values)
            uniqueNumericIndexOrders[columnName]![x]!
        ], i);
      } else if (categoricColumns.containsKey(columnName)) {
        updateIndexOrders([
          for (final x in categoricColumns[columnName]!.values)
            uniqueCategoricIndexOrders[columnName]![x]!
        ], i);
      } else {
        throw PackhorseError.badColumnName(columnName);
      }
    }

    final orderedIndices = [for (var i = 0; i < rowNumber; i++) i]
      ..sort((a, b) => compareLists(orderCriterion[a], orderCriterion[b]));

    return withRowsAtIndices(orderedIndices);
  }

  /// A new data frame comprising sampled rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(3));
  /// print(iris.withHead(3).withRowsSampled(
  ///   5, withReplacement: true, seed: 0));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// .--.------------.-----------.------------.-----------.--------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species |
  /// :--+------------+-----------+------------+-----------+--------:
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// |3 |4.7         |3.2        |1.3         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |2 |4.9         |3.0        |1.4         |0.2        |setosa  |
  /// |1 |5.1         |3.5        |1.4         |0.2        |setosa  |
  /// '--'------------'-----------'------------'-----------'--------'
  ///
  /// ```
  ///
  DataFrame withRowsSampled(
    int n, {
    bool withReplacement = false,
    int? seed,
  }) {
    final rand = math.Random(seed);
    if (withReplacement) {
      return withRowsAtIndices(
          [for (var _ = 0; _ < n; _++) rand.nextInt(rowNumber)]);
    }
    if (n > rowNumber) {
      throw PackhorseError.badArgument("Cannot sample $n rows from $rowNumber "
          "(DataFrame.withRowsSampled).");
    }
    return withRowsAtIndices(
        ([for (var i = 0; i < rowNumber; i++) i]..shuffle(rand)).sublist(n));
  }

  /// A helper function for generating results from a formula.
  List<num> _formulaResults(String formula) {
    final f = formula.toMultiVariableFunction([...numericColumns.keys]);

    num evaluate(index) {
      final arguments = {
        for (final key in numericColumns.keys) key: numericColumns[key]![index]
      };
      return f(arguments);
    }

    return [for (var i = 0; i < rowNumber; i++) evaluate(i)];
  }

  /// A helper function for generating results from a template.
  List<String> _templateResults(
    String template, {
    String startQuote = "{",
    String endQuote = "}",
  }) {
    String evaluate(index) {
      var result = template;
      for (final key in numericColumns.keys) {
        final pattern = RegExp("$startQuote *$key *$endQuote");
        result =
            result.replaceAll(pattern, numericColumns[key]![index].toString());
      }
      for (final key in categoricColumns.keys) {
        final pattern = RegExp("$startQuote *$key *$endQuote");
        result = result.replaceAll(pattern, categoricColumns[key]![index]);
      }
      return result;
    }

    return [for (var i = 0; i < rowNumber; i++) evaluate(i)];
  }

  /// A helper function for generating values from row values.
  List<num> _numericRowValueResults(
      num Function(Map<String, num> numericValues,
              Map<String, String> categoricValues)
          generator) {
    num evaluate(int index) {
      final numericValues = {
            for (final MapEntry(:key, :value) in numericColumns.entries)
              key: value[index]
          },
          categoricValues = {
            for (final MapEntry(:key, :value) in categoricColumns.entries)
              key: value[index]
          };
      return generator(numericValues, categoricValues);
    }

    return [for (var i = 0; i < rowNumber; i++) evaluate(i)];
  }

  /// A helper function for generating categories from row values.
  List<String> _categoricRowValueResults(
      String Function(Map<String, num> numericValues,
              Map<String, String> categoricValues)
          generator) {
    String evaluate(int index) {
      final numericValues = {
            for (final MapEntry(:key, :value) in numericColumns.entries)
              key: value[index]
          },
          categoricValues = {
            for (final MapEntry(:key, :value) in categoricColumns.entries)
              key: value[index]
          };
      return generator(numericValues, categoricValues);
    }

    return [for (var i = 0; i < rowNumber; i++) evaluate(i)];
  }

  /// A new data frame with a column calculated from a formula.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(sepals.withHead(5));
  /// print(sepals.withHead(5).withNumericColumnFromFormula(
  ///   name: "geom_mean",
  ///   formula: "sqrt(sepal_width * sepal_length)",
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.
  /// |id|sepal_length|sepal_width|
  /// :--+------------+-----------:
  /// |3 |4.7         |3.2        |
  /// |4 |4.6         |3.1        |
  /// |5 |5.0         |3.6        |
  /// |6 |5.4         |3.9        |
  /// |53|6.9         |3.1        |
  /// '--'------------'-----------'
  ///
  /// .--.------------.-----------.------------------.
  /// |id|sepal_length|sepal_width|geom_mean         |
  /// :--+------------+-----------+------------------:
  /// |3 |4.7         |3.2        |3.8781438859330635|
  /// |4 |4.6         |3.1        |3.776241517699841 |
  /// |5 |5.0         |3.6        |4.242640687119285 |
  /// |6 |5.4         |3.9        |4.589117562233507 |
  /// |53|6.9         |3.1        |4.624932431938871 |
  /// '--'------------'-----------'------------------'
  ///
  /// ```
  ///
  DataFrame withNumericColumnFromFormula({
    required String name,
    required String formula,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    return copy..numericColumns[name] = NumericColumn(_formulaResults(formula));
  }

  /// A new data frame with a categoric column generated from a formula.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withHead(5));
  /// print(petals.withHead(5).withCategoricColumnFromFormula(
  ///   name: "geom_mean",
  ///   formula: "sqrt(petal_width * petal_length)",
  ///   generator: (result) => result > 1 ? "large" : "small"
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.
  /// |id|petal_length|petal_width|species     |
  /// :--+------------+-----------+------------:
  /// |1 |1.4         |0.2        |setosa      |
  /// |2 |1.4         |0.2        |setosa      |
  /// |3 |1.3         |0.2        |setosa      |
  /// |4 |1.5         |0.2        |setosa      |
  /// |51|4.7         |1.4        |versicolor  |
  /// '--'------------'-----------'------------'
  ///
  /// .--.------------.-----------.------------.---------.
  /// |id|petal_length|petal_width|species     |geom_mean|
  /// :--+------------+-----------+------------+---------:
  /// |1 |1.4         |0.2        |setosa      |small    |
  /// |2 |1.4         |0.2        |setosa      |small    |
  /// |3 |1.3         |0.2        |setosa      |small    |
  /// |4 |1.5         |0.2        |setosa      |small    |
  /// |51|4.7         |1.4        |versicolor  |large    |
  /// '--'------------'-----------'------------'---------'
  ///
  /// ```
  ///
  DataFrame withCategoricColumnFromFormula({
    required String name,
    required String formula,
    required String Function(num) generator,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    return copy
      ..categoricColumns[name] =
          CategoricColumn(_formulaResults(formula).map(generator));
  }

  /// A new data frame with rows selected based on a formula's results.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withHead(5));
  /// print(petals.withHead(5).withRowsWhereFormula(
  ///   formula: "sqrt(petal_width * petal_length)",
  ///   predicate: (result) => result > 1,
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.
  /// |id|petal_length|petal_width|species     |
  /// :--+------------+-----------+------------:
  /// |1 |1.4         |0.2        |setosa      |
  /// |2 |1.4         |0.2        |setosa      |
  /// |3 |1.3         |0.2        |setosa      |
  /// |4 |1.5         |0.2        |setosa      |
  /// |51|4.7         |1.4        |versicolor  |
  /// '--'------------'-----------'------------'
  ///
  /// .--.------------.-----------.------------.
  /// |id|petal_length|petal_width|species     |
  /// :--+------------+-----------+------------:
  /// |51|4.7         |1.4        |versicolor  |
  /// '--'------------'-----------'------------'
  ///
  /// ```
  ///
  DataFrame withRowsWhereFormula({
    required String formula,
    required bool Function(num) predicate,
  }) {
    final values = _formulaResults(formula);
    return withRowsAtIndices([
      for (var i = 0; i < rowNumber; i++)
        if (predicate(values[i])) i
    ]);
  }

  /// A new data frame with a categoric column generated from a template.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withHead(5));
  /// print(petals.withHead(5).withCategoricColumnFromTemplate(
  ///   name: "marker",
  ///   template: "{species}-{id}",
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.
  /// |id|petal_length|petal_width|species     |
  /// :--+------------+-----------+------------:
  /// |1 |1.4         |0.2        |setosa      |
  /// |2 |1.4         |0.2        |setosa      |
  /// |3 |1.3         |0.2        |setosa      |
  /// |4 |1.5         |0.2        |setosa      |
  /// |51|4.7         |1.4        |versicolor  |
  /// '--'------------'-----------'------------'
  ///
  /// .--.------------.-----------.------------.---------------.
  /// |id|petal_length|petal_width|species     |marker         |
  /// :--+------------+-----------+------------+---------------:
  /// |1 |1.4         |0.2        |setosa      |setosa-1       |
  /// |2 |1.4         |0.2        |setosa      |setosa-2       |
  /// |3 |1.3         |0.2        |setosa      |setosa-3       |
  /// |4 |1.5         |0.2        |setosa      |setosa-4       |
  /// |51|4.7         |1.4        |versicolor  |versicolor-51  |
  /// '--'------------'-----------'------------'---------------'
  ///
  /// ```
  ///
  DataFrame withCategoricColumnFromTemplate({
    required String name,
    required String template,
    String startQuote = '{',
    String endQuote = '}',
    String Function(String)? generator,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    generator = generator ?? (x) => x;
    return copy
      ..categoricColumns[name] = CategoricColumn(
        _templateResults(
          template,
          startQuote: startQuote,
          endQuote: endQuote,
        ).map(generator),
      );
  }

  /// A new data frame with a numeric column generated from a template.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withHead(5));
  /// print(petals.withHead(5).withNumericColumnFromTemplate(
  ///   name: "letters",
  ///   template: "{species}",
  ///   generator: (result) => result.length,
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.------------.-----------.------------.
  /// |id|petal_length|petal_width|species     |
  /// :--+------------+-----------+------------:
  /// |1 |1.4         |0.2        |setosa      |
  /// |2 |1.4         |0.2        |setosa      |
  /// |3 |1.3         |0.2        |setosa      |
  /// |4 |1.5         |0.2        |setosa      |
  /// |51|4.7         |1.4        |versicolor  |
  /// '--'------------'-----------'------------'
  ///
  /// .--.------------.-----------.-------.------------.
  /// |id|petal_length|petal_width|letters|species     |
  /// :--+------------+-----------+-------+------------:
  /// |1 |1.4         |0.2        |6      |setosa      |
  /// |2 |1.4         |0.2        |6      |setosa      |
  /// |3 |1.3         |0.2        |6      |setosa      |
  /// |4 |1.5         |0.2        |6      |setosa      |
  /// |51|4.7         |1.4        |10     |versicolor  |
  /// '--'------------'-----------'-------'------------'
  ///
  /// ```
  ///
  DataFrame withNumericColumnFromTemplate({
    required String name,
    required String template,
    required num Function(String) generator,
    String startQuote = '{',
    String endQuote = '}',
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }

    return copy
      ..numericColumns[name] = NumericColumn(
        _templateResults(
          template,
          startQuote: startQuote,
          endQuote: endQuote,
        ).map(generator),
      );
  }

  /// A new data frame with the rows that meet a predicate based on a template.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   a,b,c
  ///  fu,5,n
  ///   f,3,ull
  ///   f,9,un
  ///  pu,3,n
  /// """.parseAsCsv();
  ///
  /// print(d.withRowsWhereTemplate(
  ///   template: "{a}{c}",
  ///   predicate: (result) => result == "fun",
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.----.
  /// |b|a   |c   |
  /// :-+----+----:
  /// |5|fu  |n   |
  /// |9|f   |un  |
  /// '-'----'----'
  ///
  /// ```
  ///
  DataFrame withRowsWhereTemplate({
    required String template,
    required bool Function(String) predicate,
    String startQuote = '{',
    String endQuote = '}',
  }) {
    final values = _templateResults(
      template,
      startQuote: startQuote,
      endQuote: endQuote,
    );
    return withRowsAtIndices([
      for (var i = 0; i < rowNumber; i++)
        if (predicate(values[i])) i
    ]);
  }

  /// A new data frame with a numeric column calculated from row values.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   number,base
  ///   FF,16
  ///   33,4
  ///   AA,12
  ///   10201,3
  /// """.parseAsCsv(types: {"number": ColumnType.categoric});
  /// print(d);
  /// print(d.withNumericColumnFromRowValues(
  ///   name: "decimal",
  ///   generator: (numeric, categoric) => int.tryParse(
  ///     categoric["number"]!,
  ///     radix: numeric["base"]!.toInt(),
  ///   )! as num,
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .----.-------.
  /// |base|number |
  /// :----+-------:
  /// |16  |FF     |
  /// |4   |33     |
  /// |12  |AA     |
  /// |3   |10201  |
  /// '----'-------'
  ///
  /// .----.-------.-------.
  /// |base|decimal|number |
  /// :----+-------+-------:
  /// |16  |255    |FF     |
  /// |4   |15     |33     |
  /// |12  |130    |AA     |
  /// |3   |100    |10201  |
  /// '----'-------'-------'
  ///
  /// ```
  ///
  DataFrame withNumericColumnFromRowValues({
    required String name,
    required num Function(
            Map<String, num> numericValues, Map<String, String> categoricValues)
        generator,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    return copy
      ..numericColumns[name] =
          NumericColumn(_numericRowValueResults(generator));
  }

  /// A new data frame with a categoric column generated based on row values.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   a,b
  ///   3,bat
  ///   5,sparrow
  ///  -3,stork
  ///  -5,squirrel
  /// """.parseAsCsv();
  /// print(d);
  /// print(d.withCategoricColumnFromRowValues(
  ///   name: "category",
  ///   generator: (numeric, categoric) =>
  ///     (numeric["a"]! >= 0 ? "positive" : "negative") +
  ///     (["bat", "squirrel"].contains(categoric["b"]!) ? "-mammal": "-bird"),
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .--.----------.
  /// |a |b         |
  /// :--+----------:
  /// |3 |bat       |
  /// |5 |sparrow   |
  /// |-3|stork     |
  /// |-5|squirrel  |
  /// '--'----------'
  ///
  /// .--.----------.-----------------.
  /// |a |b         |category         |
  /// :--+----------+-----------------:
  /// |3 |bat       |positive-mammal  |
  /// |5 |sparrow   |positive-bird    |
  /// |-3|stork     |negative-bird    |
  /// |-5|squirrel  |negative-mammal  |
  /// '--'----------'-----------------'
  ///
  /// ```
  ///
  DataFrame withCategoricColumnFromRowValues({
    required String name,
    required String Function(
            Map<String, num> numericValues, Map<String, String> categoricValues)
        generator,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    return copy
      ..categoricColumns[name] =
          CategoricColumn(_categoricRowValueResults(generator));
  }

  /// A new data frame with a numeric column added.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   a
  ///   1
  ///   2
  ///   3
  /// """.parseAsCsv();
  /// print(d);
  /// print(d.withNumeric(
  ///   name: "b",
  ///   column: NumericColumn([3, 4, 5]),
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .-.
  /// |a|
  /// :-:
  /// |1|
  /// |2|
  /// |3|
  /// '-'
  ///
  /// .-.-.
  /// |a|b|
  /// :-+-:
  /// |1|3|
  /// |2|4|
  /// |3|5|
  /// '-'-'
  ///
  /// ```
  ///
  DataFrame withNumeric({
    required String name,
    required NumericColumn column,
    bool ignoreLengthMismatch = false,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    if (!ignoreLengthMismatch && column.length != rowNumber) {
      throw PackhorseError.badStructure(
          "Adding column of length ${column.length} to data frame"
          "with $rowNumber rows.");
    }
    return copy..numericColumns[name] = column;
  }

  /// A new data frame with a categoric column added.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   a
  ///   1
  ///   2
  ///   3
  /// """.parseAsCsv();
  /// print(d);
  /// print(d.withCategoric(
  ///   name: "b",
  ///   column: CategoricColumn(["red", "green", "blue"]),
  /// ));
  /// ```
  ///
  /// ```text
  ///
  /// .-.
  /// |a|
  /// :-:
  /// |1|
  /// |2|
  /// |3|
  /// '-'
  ///
  /// .-.-------.
  /// |a|b      |
  /// :-+-------:
  /// |1|red    |
  /// |2|green  |
  /// |3|blue   |
  /// '-'-------'
  ///
  /// ```
  ///
  DataFrame withCategoric({
    required String name,
    required CategoricColumn column,
    bool ignoreLengthMismatch = false,
  }) {
    if (!_columnNameOkay(name)) {
      throw PackhorseError.badColumnName(name);
    }
    if (!ignoreLengthMismatch && column.length != rowNumber) {
      throw PackhorseError.badStructure(
          "Adding column of length ${column.length} to data frame"
          "with $rowNumber rows.");
    }
    return copy..categoricColumns[name] = column;
  }

  /// A new data frame with numeric columns added to identify each category.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = petals.withColumns(["species"]);
  /// print(d);
  /// print(d.withCategoricColumnEnumerated("species"));
  /// ```
  ///
  /// ```text
  ///
  /// .------------.
  /// |species     |
  /// :------------:
  /// |setosa      |
  /// |setosa      |
  /// |setosa      |
  /// |setosa      |
  /// |versicolor  |
  /// |versicolor  |
  /// |versicolor  |
  /// |versicolor  |
  /// |virginica   |
  /// |virginica   |
  /// |virginica   |
  /// |virginica   |
  /// '------------'
  ///
  /// .--------------.------------------.-----------------.------------.
  /// |species_setosa|species_versicolor|species_virginica|species     |
  /// :--------------+------------------+-----------------+------------:
  /// |1             |0                 |0                |setosa      |
  /// |1             |0                 |0                |setosa      |
  /// |1             |0                 |0                |setosa      |
  /// |1             |0                 |0                |setosa      |
  /// |0             |1                 |0                |versicolor  |
  /// |0             |1                 |0                |versicolor  |
  /// |0             |1                 |0                |versicolor  |
  /// |0             |1                 |0                |versicolor  |
  /// |0             |0                 |1                |virginica   |
  /// |0             |0                 |1                |virginica   |
  /// |0             |0                 |1                |virginica   |
  /// |0             |0                 |1                |virginica   |
  /// '--------------'------------------'-----------------'------------'
  ///
  /// ```
  ///
  DataFrame withCategoricColumnEnumerated(String name) {
    if (!categoricColumns.containsKey(name)) {
      throw PackhorseError.badArgument("No categoric column called '$name'.");
    }
    return copy
      ..numericColumns.addAll({
        for (final category in categoricColumns[name]!.categories)
          "${name}_$category": NumericColumn(
              categoricColumns[name]!.values.map((x) => x == category ? 1 : 0))
      });
  }

  /// A new data frame with a categoric column containing bins for values.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = petals.withColumns(["petal_width", "species"]);
  /// print(d);
  /// print(d.withNumericColumnBinned("petal_width"));
  /// ```
  ///
  /// ```text
  ///
  /// .-----------.------------.
  /// |petal_width|species     |
  /// :-----------+------------:
  /// |0.2        |setosa      |
  /// |0.2        |setosa      |
  /// |0.2        |setosa      |
  /// |0.2        |setosa      |
  /// |1.4        |versicolor  |
  /// |1.5        |versicolor  |
  /// |1.5        |versicolor  |
  /// |1.3        |versicolor  |
  /// |2.5        |virginica   |
  /// |1.9        |virginica   |
  /// |2.1        |virginica   |
  /// |1.8        |virginica   |
  /// '-----------'------------'
  ///
  /// .-----------.------------.-----------------.
  /// |petal_width|species     |petal_width_bin  |
  /// :-----------+------------+-----------------:
  /// |0.2        |setosa      |[-0.030, 0.660)  |
  /// |0.2        |setosa      |[-0.030, 0.660)  |
  /// |0.2        |setosa      |[-0.030, 0.660)  |
  /// |0.2        |setosa      |[-0.030, 0.660)  |
  /// |1.4        |versicolor  |[1.350, 2.040)   |
  /// |1.5        |versicolor  |[1.350, 2.040)   |
  /// |1.5        |versicolor  |[1.350, 2.040)   |
  /// |1.3        |versicolor  |[0.660, 1.350)   |
  /// |2.5        |virginica   |[2.040, 2.730)   |
  /// |1.9        |virginica   |[1.350, 2.040)   |
  /// |2.1        |virginica   |[2.040, 2.730)   |
  /// |1.8        |virginica   |[1.350, 2.040)   |
  /// '-----------'------------'-----------------'
  ///
  /// ```
  ///
  DataFrame withNumericColumnBinned(
    String name, {
    List<(num, num)> bins = const [],
    int decimalPlaces = 3,
  }) {
    if (!numericColumns.containsKey(name)) {
      throw PackhorseError.badArgument("No numeric column called '$name'.");
    }
    final column = numericColumns[name]!;
    if (bins.isEmpty) {
      final lower = column.minimum - 0.1 * column.range,
          upper = column.maximum + 0.1 * column.range,
          n = math.max(4, math.sqrt(upper - lower).round()),
          binWidth = (upper - lower) / n;
      bins = [
        for (var i = 0; i < n; i++)
          (lower + i * binWidth, lower + (i + 1) * binWidth)
      ];
    }
    String bin(num x) {
      for (final (a, b) in bins) {
        if (x >= a && x < b) {
          return "[${a.toStringAsFixed(decimalPlaces)}, "
              "${b.toStringAsFixed(decimalPlaces)})";
        }
      }
      return CategoricColumn.missingValueMarker;
    }

    return copy
      ..categoricColumns["${name}_bin"] =
          CategoricColumn(numericColumns[name]!.values.map(bin));
  }

  /// A new data frame with the rows of `that` added.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d1 = """
  ///   a,b
  ///   1,apple
  ///   2,ball
  ///   3,cat
  /// """.parseAsCsv(), d2 = """
  ///   a,b
  ///   4,dog
  ///   5,egg
  ///   6,fish
  /// """.parseAsCsv();
  /// print(d1.withRowsAdded(d2));
  /// ```
  ///
  /// ```text
  ///
  /// .-.-------.
  /// |a|b      |
  /// :-+-------:
  /// |1|apple  |
  /// |2|ball   |
  /// |3|cat    |
  /// |4|dog    |
  /// |5|egg    |
  /// |6|fish   |
  /// '-'-------'
  ///
  /// ```
  ///
  DataFrame withRowsAdded(DataFrame that) {
    if (numericColumns.keys
            .any((key) => !that.numericColumns.containsKey(key)) ||
        that.numericColumns.keys
            .any((key) => !numericColumns.containsKey(key)) ||
        categoricColumns.keys
            .any((key) => !that.categoricColumns.containsKey(key)) ||
        that.categoricColumns.keys
            .any((key) => !categoricColumns.containsKey(key))) {
      throw PackhorseError.badStructure(
          "Columns must match (DataFrame.withDataAdded).");
    }
    final result = copy;
    for (final MapEntry(:key, :value) in that.numericColumns.entries) {
      result.numericColumns[key]!.addAll(value.values);
    }
    for (final MapEntry(:key, :value) in that.categoricColumns.entries) {
      result.categoricColumns[key]!.addAll(value.values);
    }
    return result;
  }

  /// A helper function to identify rows with missing values.
  Set<int> _rowIndicesWithMissingValues(Iterable<String> columns) {
    final result = <int>{};
    for (final key in columns) {
      if (this.numericColumns.containsKey(key)) {
        result.addAll(this.numericColumns[key]!.indicesWithMissingValues);
      } else {
        result.addAll(this.categoricColumns[key]!.indicesWithMissingValues);
      }
    }
    return result;
  }

  /// A new data frame comprising the rows with at least one missing value.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///     a,b
  ///     1,apple
  ///     2,ball
  ///  <NA>,cat
  ///     4,<NA>
  ///     5,egg
  /// """.parseAsCsv();
  /// print(d);
  /// print(d.withMissingValues());
  /// ```
  ///
  /// ```text
  ///
  /// .---.-------.
  /// |a  |b      |
  /// :---+-------:
  /// |1  |apple  |
  /// |2  |ball   |
  /// |NaN|cat    |
  /// |4  |<NA>   |
  /// |5  |egg    |
  /// '---'-------'
  ///
  /// .---.------.
  /// |a  |b     |
  /// :---+------:
  /// |NaN|cat   |
  /// |4  |<NA>  |
  /// '---'------'
  ///
  /// ```
  ///
  DataFrame withMissingValues([Iterable<String>? columns]) {
    columns =
        columns ?? [...this.numericColumns.keys, ...this.categoricColumns.keys];

    if (columns.any((key) =>
        !this.numericColumns.containsKey(key) &&
        !this.categoricColumns.containsKey(key))) {
      throw PackhorseError.badArgument(
          "Bad column names $columns" "(DataFrame.withMissingValues).");
    }

    final numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{},
        indicesWithMissingValues = _rowIndicesWithMissingValues(columns);

    for (final MapEntry(:key, :value) in this.numericColumns.entries) {
      numericColumns[key] =
          NumericColumn(value.valuesAtIndices(indicesWithMissingValues));
    }

    for (final MapEntry(:key, :value) in this.categoricColumns.entries) {
      categoricColumns[key] =
          CategoricColumn(value.valuesAtIndices(indicesWithMissingValues));
    }

    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A new data frame comprising the rows without any missing values.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///     a,b
  ///     1,apple
  ///     2,ball
  ///  <NA>,cat
  ///     4,<NA>
  ///     5,egg
  /// """.parseAsCsv();
  /// print(d);
  /// print(d.withMissingValuesDropped());
  /// ```
  ///
  /// ```text
  ///
  /// .---.-------.
  /// |a  |b      |
  /// :---+-------:
  /// |1  |apple  |
  /// |2  |ball   |
  /// |NaN|cat    |
  /// |4  |<NA>   |
  /// |5  |egg    |
  /// '---'-------'
  ///
  /// .-.-------.
  /// |a|b      |
  /// :-+-------:
  /// |1|apple  |
  /// |2|ball   |
  /// |5|egg    |
  /// '-'-------'
  ///
  /// ```
  ///
  DataFrame withMissingValuesDropped([Iterable<String>? columns]) {
    columns =
        columns ?? [...this.numericColumns.keys, ...this.categoricColumns.keys];

    if (columns.any((key) =>
        !this.numericColumns.containsKey(key) &&
        !this.categoricColumns.containsKey(key))) {
      throw PackhorseError.badArgument(
          "Bad column names $columns" "(DataFrame.withMissingValuesDropped).");
    }

    final numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{},
        indicesWithMissingValues = _rowIndicesWithMissingValues(columns),
        indicesWithoutMissingValues = [
          for (var i = 0; i < rowNumber; i++)
            if (!indicesWithMissingValues.contains(i)) i
        ];

    for (final MapEntry(:key, :value) in this.numericColumns.entries) {
      numericColumns[key] =
          NumericColumn(value.valuesAtIndices(indicesWithoutMissingValues));
    }

    for (final MapEntry(:key, :value) in this.categoricColumns.entries) {
      categoricColumns[key] =
          CategoricColumn(value.valuesAtIndices(indicesWithoutMissingValues));
    }

    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
  }

  /// A map associating each category with a pure data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = petals.withColumns(["petal_length", "species"]),
  ///   grouped = d.groupedByCategory("species");
  /// print(d);
  /// for (final MapEntry(:key, :value) in grouped.entries) {
  ///   print("$key:");
  ///   print(value);
  /// }
  /// ```
  ///
  /// ```text
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |1.4         |setosa      |
  /// |1.4         |setosa      |
  /// |1.3         |setosa      |
  /// |1.5         |setosa      |
  /// |4.7         |versicolor  |
  /// |4.5         |versicolor  |
  /// |4.9         |versicolor  |
  /// |4.0         |versicolor  |
  /// |6.0         |virginica   |
  /// |5.1         |virginica   |
  /// |5.9         |virginica   |
  /// |5.6         |virginica   |
  /// '------------'------------'
  ///
  /// setosa:
  ///
  /// .------------.--------.
  /// |petal_length|species |
  /// :------------+--------:
  /// |1.4         |setosa  |
  /// |1.4         |setosa  |
  /// |1.3         |setosa  |
  /// |1.5         |setosa  |
  /// '------------'--------'
  ///
  /// versicolor:
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |4.7         |versicolor  |
  /// |4.5         |versicolor  |
  /// |4.9         |versicolor  |
  /// |4.0         |versicolor  |
  /// '------------'------------'
  ///
  /// virginica:
  ///
  /// .------------.-----------.
  /// |petal_length|species    |
  /// :------------+-----------:
  /// |6.0         |virginica  |
  /// |5.1         |virginica  |
  /// |5.9         |virginica  |
  /// |5.6         |virginica  |
  /// '------------'-----------'
  ///
  /// ```
  ///
  Map<String, DataFrame> groupedByCategory(String name) {
    if (!categoricColumns.containsKey(name)) {
      throw PackhorseError.badArgument("No categoric column called '$name'.");
    }
    final result = <String, DataFrame>{};
    for (final category in categoricColumns[name]!.categories) {
      result[category] = withRowsAtIndices(
          categoricColumns[name]!.indicesWhere((c) => c == category));
    }
    return result;
  }

  /// A map associating each value with a pure data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = petals.withColumns(["petal_length", "species"]),
  ///   grouped = d.groupedByNumeric("petal_length");
  /// print(d);
  /// for (final MapEntry(:key, :value) in grouped.entries) {
  ///   print("$key:");
  ///   print(value);
  /// }
  /// ```
  ///
  /// ```text
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |1.4         |setosa      |
  /// |1.4         |setosa      |
  /// |1.3         |setosa      |
  /// |1.5         |setosa      |
  /// |4.7         |versicolor  |
  /// |4.5         |versicolor  |
  /// |4.9         |versicolor  |
  /// |4.0         |versicolor  |
  /// |6.0         |virginica   |
  /// |5.1         |virginica   |
  /// |5.9         |virginica   |
  /// |5.6         |virginica   |
  /// '------------'------------'
  ///
  /// 1.4:
  ///
  /// .------------.--------.
  /// |petal_length|species |
  /// :------------+--------:
  /// |1.4         |setosa  |
  /// |1.4         |setosa  |
  /// '------------'--------'
  ///
  /// 1.3:
  ///
  /// .------------.--------.
  /// |petal_length|species |
  /// :------------+--------:
  /// |1.3         |setosa  |
  /// '------------'--------'
  ///
  /// 1.5:
  ///
  /// .------------.--------.
  /// |petal_length|species |
  /// :------------+--------:
  /// |1.5         |setosa  |
  /// '------------'--------'
  ///
  /// 4.7:
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |4.7         |versicolor  |
  /// '------------'------------'
  ///
  /// 4.5:
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |4.5         |versicolor  |
  /// '------------'------------'
  ///
  /// 4.9:
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |4.9         |versicolor  |
  /// '------------'------------'
  ///
  /// 4.0:
  ///
  /// .------------.------------.
  /// |petal_length|species     |
  /// :------------+------------:
  /// |4.0         |versicolor  |
  /// '------------'------------'
  ///
  /// 6.0:
  ///
  /// .------------.-----------.
  /// |petal_length|species    |
  /// :------------+-----------:
  /// |6.0         |virginica  |
  /// '------------'-----------'
  ///
  /// 5.1:
  ///
  /// .------------.-----------.
  /// |petal_length|species    |
  /// :------------+-----------:
  /// |5.1         |virginica  |
  /// '------------'-----------'
  ///
  /// 5.9:
  ///
  /// .------------.-----------.
  /// |petal_length|species    |
  /// :------------+-----------:
  /// |5.9         |virginica  |
  /// '------------'-----------'
  ///
  /// 5.6:
  ///
  /// .------------.-----------.
  /// |petal_length|species    |
  /// :------------+-----------:
  /// |5.6         |virginica  |
  /// '------------'-----------'
  ///
  /// ```
  ///
  Map<num, DataFrame> groupedByNumeric(String name) {
    if (!numericColumns.containsKey(name)) {
      throw PackhorseError.badArgument("No numeric column called '$name'.");
    }
    final result = <num, DataFrame>{};
    for (final value in {...numericColumns[name]!.values}) {
      result[value] = withRowsAtIndices(
          numericColumns[name]!.indicesWhere((v) => v == value));
    }
    return result;
  }

  /// A helper to perform a generalized join operation.
  static DataFrame _join(
    DataFrame left,
    DataFrame right,
    String leftPivot,
    String rightPivot,
    Set<Object> ids,
  ) {
    if (![left.categoricColumns.keys, left.numericColumns.keys]
        .any((keys) => keys.contains(leftPivot))) {
      throw PackhorseError.badArgument("Pivot '$leftPivot' not recognized.");
    }
    if (![right.categoricColumns.keys, right.numericColumns.keys]
        .any((keys) => keys.contains(rightPivot))) {
      throw PackhorseError.badArgument("Pivot '$rightPivot' not recognized.");
    }

    final variablesMap =
            <T>(Iterable<String> keys) => {for (final key in keys) key: <T>[]},
        leftCategoricColumns = variablesMap<String>(left.categoricColumns.keys),
        rightCategoricColumns =
            variablesMap<String>(right.categoricColumns.keys),
        leftNumericColumns = variablesMap<num>(left.numericColumns.keys),
        rightNumericColumns = variablesMap<num>(right.numericColumns.keys);

    for (final id in ids) {
      final
          // Rows in left that match id:
          leftIndices = id is String
              ? left.categoricColumns[leftPivot]!
                  .indicesWhere((value) => value == id)
              : left.numericColumns[leftPivot]!
                  .indicesWhere((value) => value == id),
          // Rows in right that match id:
          rightIndices = id is String
              ? right.categoricColumns[rightPivot]!
                  .indicesWhere((value) => value == id)
              : right.numericColumns[rightPivot]!
                  .indicesWhere((value) => value == id);

      if (leftIndices.isEmpty && rightIndices.isEmpty) {
        // Don't add any rows to the join.
      } else if (leftIndices.isEmpty) {
        for (final index in rightIndices) {
          // Fill left with missing values...
          for (final key in leftCategoricColumns.keys) {
            leftCategoricColumns[key]!.add(CategoricColumn.missingValueMarker);
          }
          for (final key in leftNumericColumns.keys) {
            leftNumericColumns[key]!.add(double.nan);
          }
          // ... and right with values.
          for (final key in rightCategoricColumns.keys) {
            rightCategoricColumns[key]!
                .add(right.categoricColumns[key]![index]);
          }
          for (final key in rightNumericColumns.keys) {
            rightNumericColumns[key]!.add(right.numericColumns[key]![index]);
          }
        }
      } else if (rightIndices.isEmpty) {
        for (final index in leftIndices) {
          // Fill left with values...
          for (final key in leftCategoricColumns.keys) {
            leftCategoricColumns[key]!.add(left.categoricColumns[key]![index]);
          }
          for (final key in leftNumericColumns.keys) {
            leftNumericColumns[key]!.add(left.numericColumns[key]![index]);
          }
          // ... and right with missing values.
          for (final key in rightCategoricColumns.keys) {
            rightCategoricColumns[key]!.add(CategoricColumn.missingValueMarker);
          }
          for (final key in rightNumericColumns.keys) {
            rightNumericColumns[key]!.add(double.nan);
          }
        }
      } else {
        for (final leftIndex in leftIndices) {
          for (final rightIndex in rightIndices) {
            // Fill left with values...
            for (final key in leftCategoricColumns.keys) {
              leftCategoricColumns[key]!
                  .add(left.categoricColumns[key]![leftIndex]);
            }
            for (final key in leftNumericColumns.keys) {
              leftNumericColumns[key]!
                  .add(left.numericColumns[key]![leftIndex]);
            }
            // ... and right with values.
            for (final key in rightCategoricColumns.keys) {
              rightCategoricColumns[key]!
                  .add(right.categoricColumns[key]![rightIndex]);
            }
            for (final key in rightNumericColumns.keys) {
              rightNumericColumns[key]!
                  .add(right.numericColumns[key]![rightIndex]);
            }
          }
        }
      }
    }

    final categoricColumns = {
          for (final MapEntry(:key, :value) in leftCategoricColumns.entries)
            key: CategoricColumn(value),
          for (final MapEntry(:key, :value) in rightCategoricColumns.entries)
            (leftCategoricColumns.containsKey(key) ? "right_$key" : key):
                CategoricColumn(value),
        },
        numericColumns = {
          for (final MapEntry(:key, :value) in leftNumericColumns.entries)
            key: NumericColumn(value),
          for (final MapEntry(:key, :value) in rightNumericColumns.entries)
            (leftNumericColumns.containsKey(key) ? "right_$key" : key):
                NumericColumn(value),
        };

    return DataFrame(
      categoricColumns: categoricColumns,
      numericColumns: numericColumns,
    );
  }

  /// A new data frame representing a left join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Left Join:");
  /// print(left.withLeftJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Left Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |1  |1.4         |NaN     |NaN         |
  /// |2  |1.4         |NaN     |NaN         |
  /// |3  |1.3         |3       |4.7         |
  /// |4  |1.5         |4       |4.6         |
  /// |51 |4.7         |NaN     |NaN         |
  /// |52 |4.5         |NaN     |NaN         |
  /// |53 |4.9         |53      |6.9         |
  /// |54 |4.0         |54      |5.5         |
  /// |101|6.0         |NaN     |NaN         |
  /// |102|5.1         |NaN     |NaN         |
  /// |103|5.9         |103     |7.1         |
  /// |104|5.6         |104     |6.3         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withLeftJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final ids = categoricColumns.containsKey(pivot)
        ? {...categoricColumns[pivot]!.values}
        : {...numericColumns[pivot]!.values};
    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing a right join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Right Join:");
  /// print(left.withRightJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Right Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |3  |1.3         |3       |4.7         |
  /// |4  |1.5         |4       |4.6         |
  /// |NaN|NaN         |5       |5.0         |
  /// |NaN|NaN         |6       |5.4         |
  /// |53 |4.9         |53      |6.9         |
  /// |54 |4.0         |54      |5.5         |
  /// |NaN|NaN         |55      |6.5         |
  /// |NaN|NaN         |56      |5.7         |
  /// |103|5.9         |103     |7.1         |
  /// |104|5.6         |104     |6.3         |
  /// |NaN|NaN         |105     |6.5         |
  /// |NaN|NaN         |106     |7.6         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withRightJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final ids = that.categoricColumns.containsKey(pivot)
        ? {...that.categoricColumns[pivot]!.values}
        : {...that.numericColumns[pivot]!.values};

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing an inner join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Inner Join:");
  /// print(left.withInnerJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Inner Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |3  |1.3         |3       |4.7         |
  /// |4  |1.5         |4       |4.6         |
  /// |53 |4.9         |53      |6.9         |
  /// |54 |4.0         |54      |5.5         |
  /// |103|5.9         |103     |7.1         |
  /// |104|5.6         |104     |6.3         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withInnerJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final a = categoricColumns.containsKey(pivot)
            ? {...categoricColumns[pivot]!.values}
            : {...numericColumns[pivot]!.values},
        b = that.categoricColumns.containsKey(pivot)
            ? {...that.categoricColumns[pivot]!.values}
            : {...that.numericColumns[pivot]!.values},
        ids = a.intersection(b);

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing a full join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Full Join:");
  /// print(left.withFullJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Full Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |1  |1.4         |NaN     |NaN         |
  /// |2  |1.4         |NaN     |NaN         |
  /// |3  |1.3         |3       |4.7         |
  /// |4  |1.5         |4       |4.6         |
  /// |51 |4.7         |NaN     |NaN         |
  /// |52 |4.5         |NaN     |NaN         |
  /// |53 |4.9         |53      |6.9         |
  /// |54 |4.0         |54      |5.5         |
  /// |101|6.0         |NaN     |NaN         |
  /// |102|5.1         |NaN     |NaN         |
  /// |103|5.9         |103     |7.1         |
  /// |104|5.6         |104     |6.3         |
  /// |NaN|NaN         |5       |5.0         |
  /// |NaN|NaN         |6       |5.4         |
  /// |NaN|NaN         |55      |6.5         |
  /// |NaN|NaN         |56      |5.7         |
  /// |NaN|NaN         |105     |6.5         |
  /// |NaN|NaN         |106     |7.6         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withFullJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final a = categoricColumns.containsKey(pivot)
            ? {...categoricColumns[pivot]!.values}
            : {...numericColumns[pivot]!.values},
        b = that.categoricColumns.containsKey(pivot)
            ? {...that.categoricColumns[pivot]!.values}
            : {...that.numericColumns[pivot]!.values},
        ids = a.union(b);

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing a left outer join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Left Outer Join:");
  /// print(left.withLeftOuterJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Left Outer Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |1  |1.4         |NaN     |NaN         |
  /// |2  |1.4         |NaN     |NaN         |
  /// |51 |4.7         |NaN     |NaN         |
  /// |52 |4.5         |NaN     |NaN         |
  /// |101|6.0         |NaN     |NaN         |
  /// |102|5.1         |NaN     |NaN         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withLeftOuterJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final a = categoricColumns.containsKey(pivot)
            ? {...categoricColumns[pivot]!.values}
            : {...numericColumns[pivot]!.values},
        b = that.categoricColumns.containsKey(pivot)
            ? {...that.categoricColumns[pivot]!.values}
            : {...that.numericColumns[pivot]!.values},
        ids = a.difference(b);

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing a right outer join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Right Outer Join:");
  /// print(left.withRightOuterJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Right Outer Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |NaN|NaN         |5       |5.0         |
  /// |NaN|NaN         |6       |5.4         |
  /// |NaN|NaN         |55      |6.5         |
  /// |NaN|NaN         |56      |5.7         |
  /// |NaN|NaN         |105     |6.5         |
  /// |NaN|NaN         |106     |7.6         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withRightOuterJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final a = categoricColumns.containsKey(pivot)
            ? {...categoricColumns[pivot]!.values}
            : {...numericColumns[pivot]!.values},
        b = that.categoricColumns.containsKey(pivot)
            ? {...that.categoricColumns[pivot]!.values}
            : {...that.numericColumns[pivot]!.values},
        ids = b.difference(a);

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A new data frame representing an outer join on `that`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final left = petals.withColumns(["id", "petal_length"]),
  ///   right = sepals.withColumns(["id", "sepal_length"]);
  /// print("Left: $left");
  /// print("Right: $right");
  /// print("Outer Join:");
  /// print(left.withOuterJoinOn(right, pivot: "id"));
  /// ```
  ///
  /// ```text
  /// Left:
  /// .---.------------.
  /// |id |petal_length|
  /// :---+------------:
  /// |1  |1.4         |
  /// |2  |1.4         |
  /// |3  |1.3         |
  /// |4  |1.5         |
  /// |51 |4.7         |
  /// |52 |4.5         |
  /// |53 |4.9         |
  /// |54 |4.0         |
  /// |101|6.0         |
  /// |102|5.1         |
  /// |103|5.9         |
  /// |104|5.6         |
  /// '---'------------'
  ///
  /// Right:
  /// .---.------------.
  /// |id |sepal_length|
  /// :---+------------:
  /// |3  |4.7         |
  /// |4  |4.6         |
  /// |5  |5.0         |
  /// |6  |5.4         |
  /// |53 |6.9         |
  /// |54 |5.5         |
  /// |55 |6.5         |
  /// |56 |5.7         |
  /// |103|7.1         |
  /// |104|6.3         |
  /// |105|6.5         |
  /// |106|7.6         |
  /// '---'------------'
  ///
  /// Outer Join:
  ///
  /// .---.------------.--------.------------.
  /// |id |petal_length|right_id|sepal_length|
  /// :---+------------+--------+------------:
  /// |NaN|NaN         |5       |5.0         |
  /// |NaN|NaN         |6       |5.4         |
  /// |NaN|NaN         |55      |6.5         |
  /// |NaN|NaN         |56      |5.7         |
  /// |NaN|NaN         |105     |6.5         |
  /// |NaN|NaN         |106     |7.6         |
  /// |1  |1.4         |NaN     |NaN         |
  /// |2  |1.4         |NaN     |NaN         |
  /// |51 |4.7         |NaN     |NaN         |
  /// |52 |4.5         |NaN     |NaN         |
  /// |101|6.0         |NaN     |NaN         |
  /// |102|5.1         |NaN     |NaN         |
  /// '---'------------'--------'------------'
  ///
  /// ```
  ///
  DataFrame withOuterJoinOn(
    DataFrame that, {
    required String pivot,
    String? thatPivot,
  }) {
    thatPivot = thatPivot ?? pivot;
    final b = (that.categoricColumns.containsKey(pivot)
            ? {...that.categoricColumns[pivot]!.values}
            : {...that.numericColumns[pivot]!.values}),
        a = (categoricColumns.containsKey(pivot)
            ? {...categoricColumns[pivot]!.values}
            : {...numericColumns[pivot]!.values}),
        ids = b.union(a).difference(b.intersection(a));

    return _join(this, that, pivot, thatPivot, ids);
  }

  /// A conversion of this data frame to a map of lists.
  Map<String, List<String>> toMapOfLists({
    Map<String, int> fixedPlaces = const {},
  }) =>
      {
        for (final MapEntry(:key, :value) in numericColumns.entries)
          key: [
            for (final x in value.values)
              fixedPlaces.containsKey(key)
                  ? x.toStringAsFixed(fixedPlaces[key]!)
                  : x.toString()
          ],
        for (final MapEntry(:key, :value) in categoricColumns.entries)
          key: [for (final x in value.values) '"$x"']
      };

  /// A conversion of this data frame to a list of maps.
  List<Map<String, String>> toListOfMaps({
    Map<String, int> fixedPlaces = const {},
  }) =>
      [
        for (var i = 0; i < rowNumber; i++)
          {
            for (final MapEntry(:key, :value) in numericColumns.entries)
              key: fixedPlaces.containsKey(key)
                  ? value[i].toStringAsFixed(fixedPlaces[key]!)
                  : value[i].toString(),
            for (final MapEntry(:key, :value) in categoricColumns.entries)
              key: '"${value[i]}"'
          }
      ];

  /// A conversion of this data frame to a csv representation.
  String toCsv({
    String separator = ",",
    Iterable<String>? columns,
    Map<String, int> fixedPlaces = const {},
  }) {
    columns = columns ?? [...numericColumns.keys, ...categoricColumns.keys];
    if (columns.any((column) =>
        !numericColumns.containsKey(column) &&
        !categoricColumns.containsKey(column))) {
      throw PackhorseError.badArgument("Bad column name in $columns.");
    }

    final table = toListOfMaps(fixedPlaces: fixedPlaces),
        sb = StringBuffer()..writeln(columns.join(separator));

    for (final row in table) {
      sb.writeln(columns.map((c) => row[c]!).join(","));
    }

    return sb.toString();
  }

  /// A conversion of this data frame to a markdown table.
  String toMarkdown({
    Map<String, MarkdownAlignment> alignment = const {},
    Iterable<String>? columns,
    Map<String, int> fixed = const {},
  }) {
    columns = columns ?? [...numericColumns.keys, ...categoricColumns.keys];
    if (columns.any((column) =>
        !numericColumns.containsKey(column) &&
        !categoricColumns.containsKey(column))) {
      throw PackhorseError.badArgument("Bad column name in $columns.");
    }

    final table = toListOfMaps(),
        row = (Iterable<String> cells) => "|${cells.join("|")}|",
        sb = StringBuffer("\n")
          ..writeln("|${columns.join("|")}|")
          ..writeln(row(columns.map((key) => alignment.containsKey(key)
              ? alignment[key]!.mark
              : MarkdownAlignment.left.mark)));

    for (final r in table) {
      sb.writeln(row(columns.map((key) => r[key]!
          .replaceAll('"', "")
          .replaceAll("<", "&lt;")
          .replaceAll(">", "&gt;"))));
    }

    return sb.toString();
  }

  /// A conversion of this data frame to a json list of maps string.
  String toJsonAsListOfMaps({Map<String, int> fixedPlaces = const {}}) =>
      json.encode(toListOfMaps(fixedPlaces: fixedPlaces));

  /// A conversion of this data frame to a json map of lists string.
  String toJsonAsMapOfLists({Map<String, int> fixedPlaces = const {}}) =>
      json.encode(toMapOfLists(fixedPlaces: fixedPlaces));

  /// A conversion of this data frame to an html table.
  String toHtml({
    Iterable<String>? columns,
    Map<String, int> fixedPlaces = const {},
  }) {
    columns = columns ?? [...numericColumns.keys, ...categoricColumns.keys];
    if (columns.any((column) =>
        !numericColumns.containsKey(column) &&
        !categoricColumns.containsKey(column))) {
      throw PackhorseError.badArgument("Bad column name in $columns.");
    }

    final table = toListOfMaps(),
        row = (Iterable<String> cells) =>
            "    <tr><td>${cells.join("</td><td>")}</td></tr>",
        sb = StringBuffer("\n")
          ..writeln('<div class="packhorse">\n<table>\n  <thead>')
          ..writeln("    <tr><th>${columns.join("</th><th>")}</th></tr>")
          ..writeln("  </thead>\n  <tbody>");

    for (final r in table) {
      sb.writeln(row(columns.map((key) => r[key]!
          .replaceAll('"', "")
          .replaceAll("<", "&lt;")
          .replaceAll(">", "&gt;"))));
    }

    sb.writeln("  </tbody>\n</table>\n</div>");

    return sb.toString();
  }

  @override
  String toString() {
    final columns = [...numericColumns.keys, ...categoricColumns.keys],
        table = toListOfMaps(),
        maxWidths = {
          for (final key in columns)
            key: [
              key.length,
              ...[for (final row in table) row[key]!.length]
            ].reduce(math.max)
        },
        line = (String edge, String connect) =>
            edge +
            [for (final column in columns) "-" * maxWidths[column]!]
                .join(connect) +
            edge,
        row = (Iterable<String> cells) => "|${cells.join("|")}|",
        sb = StringBuffer("\n")
          ..writeln(line(".", "."))
          ..writeln(row(columns.map((key) => key.padRight(maxWidths[key]!))))
          ..writeln(line(":", "+"));

    for (final r in table) {
      sb.writeln(row(columns.map(
          (key) => r[key]!.replaceAll('"', "").padRight(maxWidths[key]!))));
    }

    sb.writeln(line("'", "'"));

    return sb.toString();
  }
}
