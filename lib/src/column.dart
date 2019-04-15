part of packhorse;

abstract class Column<T extends Comparable> extends ListBase<T> {
  List<int> get indices => List<int>.generate(length, (index) => index);

  List<int> get orderedIndices => indices
    ..sort((a, b) {
      if (this[a] == null) {
        return -1;
      } else if (this[b] == null) {
        return 1;
      } else {
        return this[a].compareTo(this[b]);
      }
    });

  /// The indices of all null values.
  List<int> get nullIndices =>
      indices.where((index) => this[index] == null).toList();

  /// The indices of all non null values.
  List<int> get nonNullIndices =>
      indices.where((index) => this[index] != null).toList();

  Map<String, num> _statsMemoization = {};

  Column elementsAtIndices(List<int> indices);

  /// A helper method that looks up, calculates or stores statistics.
  num _statistic(String key, num f(Column<T> xs)) =>
      _statsMemoization.containsKey(key)
          ? _statsMemoization[key]
          : _statsMemoization[key] = f(elementsAtIndices(nonNullIndices));
}
