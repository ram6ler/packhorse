part of packhorse;

abstract class Column<T extends Comparable> extends ListBase<T> {
  List<int> get indices => sequence(length);

  /// The indices that order the data.
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

  /// The indices the data would be sent to upon ordering.
  List<int> get indexOrders => Numeric(orderedIndices).orderedIndices;

  /// The indices of all null values.
  List<int> get nullIndices =>
      [...indices.where((index) => this[index] == null)];

  /// The indices of all non null values.
  List<int> get nonNullIndices =>
      [...indices.where((index) => this[index] != null)];

  Column elementsAtIndices(Iterable<int> indices);
}
