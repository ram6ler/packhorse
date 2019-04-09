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
}
