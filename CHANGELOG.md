# Changelog

## 0.7.0

- **Long overdue overhaul, with *many breaking changes*.**

  Previous versions used null values to represent missing values. Missing values are now represented by `double.nan` for numeric data and `CategoricColumn.missingValueMarker` for categoric data (as opposed to `null`s in the days when we could misuse systems without blushing). Simplified a lot of the code and used some nice Dart 3 features.

- Renamed `Numeric` and `Categoric` to `NumericColumn` and `CategoricColumn` respectively. These classes no longer implement `List`; instead, many methods return vanilla lists rather than new instances of these classes for this level of manipulation; we can easily get generate respective columns from lists using the list extensions anyway.

- Stripped some redundant functionality to reduce the number of ways to do the same thing.

## 0.6.1

- One of the dependencies, function_tree, contained a serious bug which made interpretations of differences prone to errors; updated to depend on the fixed version.

## 0.6.0

- Documentation.
- Extensions to lists, maps, strings.
- Some housecleaning.

## 0.5.0

- Initial version.
