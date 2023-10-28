import "dart:convert" show json;

import "column.dart" show NumericColumn, CategoricColumn;
import 'data_frame.dart' show DataFrame, ColumnType;

extension PackhorseStringMethods on String {
  /// Creates a data frame from a csv string.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   a,b,c
  ///   1,3.2,apple
  ///   2,-5.6,ball
  ///   3,0.0,cat
  /// """.parseAsCsv();
  /// print(d);
  /// print(d["hello"]);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|3.2 |apple  |
  /// |2|-5.6|ball   |
  /// |3|0.0 |cat    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  DataFrame parseAsCsv({
    String separator = ",",
    String quote = '"',
    Map<String, ColumnType>? types,
  }) =>
      DataFrame.fromCsv(
        this,
        separator: separator,
        quote: quote,
        types: types,
      );

  /// Creates a data frame from a json string representing a map of lists.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   {
  ///     "a": [1, 2, 3],
  ///     "b": [3.2, -5.6, 0.0],
  ///     "c": ["apple", "ball", "cat"]
  ///   }
  /// """.parseAsMapOfLists();
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|3.2 |apple  |
  /// |2|-5.6|ball   |
  /// |3|0.0 |cat    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  DataFrame parseAsMapOfLists({Map<String, ColumnType>? types}) {
    final data = <String, List<Object>>{};
    // Hack: convert json.decode value...
    for (final MapEntry(:key, :value) in json.decode(this).entries) {
      data[key] = [...value];
    }
    return DataFrame.fromMapOfLists(
      data,
      types: types,
    );
  }

  /// Creates a data frame from a json string representing a list of maps.
  ///
  /// Example:
  ///
  /// ```dart
  /// final d = """
  ///   [
  ///     {"a": 1, "b": 3.2, "c": "apple"},
  ///     {"a": 2, "b": -5.6, "c": "ball"},
  ///     {"a": 3, "b": 0.0, "c": "cat"}
  ///   ]
  /// """.parseAsListOfMaps();
  /// print(d);
  /// ```
  ///
  /// ```text
  ///
  /// .-.----.-------.
  /// |a|b   |c      |
  /// :-+----+-------:
  /// |1|3.2 |apple  |
  /// |2|-5.6|ball   |
  /// |3|0.0 |cat    |
  /// '-'----'-------'
  ///
  /// ```
  ///
  DataFrame parseAsListOfMaps({Map<String, ColumnType>? types}) {
    types = types ?? {};
    final data = json.decode(this),
        firstDatum = data.first,
        columnNames = <String>[...firstDatum.keys],
        numericColumns = <String, NumericColumn>{},
        categoricColumns = <String, CategoricColumn>{};

    for (final column in columnNames) {
      if (!types.containsKey(column)) {
        final parseFirst = num.tryParse(firstDatum[column]!.toString());
        types[column] =
            parseFirst == null ? ColumnType.categoric : ColumnType.numeric;
      }
      if (types[column]! == ColumnType.numeric) {
        numericColumns[column] = NumericColumn([]);
      } else {
        categoricColumns[column] = CategoricColumn([]);
      }
    }

    for (final datum in data) {
      for (final column in numericColumns.keys) {
        final value = datum.containsKey(column)
            ? num.tryParse(datum[column]!.toString()) ?? double.nan
            : double.nan;
        numericColumns[column]!.add(value);
      }
      for (final column in categoricColumns.keys) {
        final value = datum.containsKey(column)
            ? datum[column]!.toString()
            : CategoricColumn.missingValueMarker;
        categoricColumns[column]!.add(value);
      }
    }

    return DataFrame(
      numericColumns: numericColumns,
      categoricColumns: categoricColumns,
    );
    // if only...
    // return DataFrame.fromListOfMaps(
    //   List<Map<String, Object>>.from(json.decode(this)),
    //   types: types,
    // );
  }
}

extension PackhorseNumericListMethods on List<num> {
  NumericColumn toNumericColumn() => NumericColumn(this);
}

extension PackhorseStringListMethods on List<String> {
  CategoricColumn toCategoricColumn() => CategoricColumn(this);
}

extension PackhorseMapOfListsMethods on Map<String, List<Object>> {
  DataFrame toDataFrame() => DataFrame.fromMapOfLists(this);
}

extension PackhorseListOfMapsMethods on List<Map<String, Object>> {
  DataFrame toDataFrame() => DataFrame.fromListOfMaps(this);
}
