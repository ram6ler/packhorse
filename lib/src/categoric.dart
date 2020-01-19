part of packhorse;

class Categoric extends Column<String> {
  Categoric(Iterable<String> data, {List<String> withCategories}) {
    _categories = withCategories == null
        ? (data.where((value) => value != null).toSet().toList()..sort())
        : _categories = withCategories.toSet().toList();

    _categoryIndices = data.map((datum) => _categories.indexOf(datum)).toList();
  }

  /// The internal list of categories in this categoric.
  List<String> _categories;

  /// The list of categories in this categoric.
  List<String> get categories => List<String>.from(_categories);

  /// The internal data, as indices in [_categories].
  List<int> _categoryIndices;

  /// The internal data, as indices in [categories].
  List<int> get categoryIndices => List.from(_categoryIndices);

  /// Redefines the categories.
  ///
  /// (Values that do not lie in the new category definition will be lost.)
  void recategorize(List<String> categories) {
    final categoryList = categories.toSet().toList();
    _categoryIndices = map((datum) => categoryList.indexOf(datum)).toList();
    _categories = List<String>.from(categoryList);
  }

  /// Adds categories to the existing categories.
  void addCategories(List<String> newCategories) {
    final categories = (List<String>.from(_categories)..addAll(newCategories))
        .toSet()
        .toList()
          ..sort();
    recategorize(categories);
  }

  /// The counts, by category.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// colors.counts.forEach((color, count) {
  ///   print('$color: $count');
  /// });
  /// // blue: 1
  /// // green: 2
  /// // red: 3
  /// ```
  ///
  Map<String, int> get counts => Map<String, int>.fromIterable(_categories,
      value: (category) => where((c) => c == category).length);

  /// The proportions, by category.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// colors.proportions.forEach((color, p) {
  ///   print('$color: ${p.toStringAsFixed(2)}');
  /// });
  /// // blue: 0.17
  /// // green: 0.33
  /// // red: 0.50
  /// ```
  ///
  Map<String, double> get proportions =>
      Map<String, double>.fromIterable(_categories,
          value: (category) => where((c) => c == category).length / length);

  /// The frequencies, by category.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// colors.proportions.forEach((color, f) {
  ///   print('$color: $f');
  /// });
  /// // blue: 1
  /// // green: 2
  /// // red: 3
  /// ```
  ///
  Map<String, int> get frequencies => Map<String, int>.fromIterable(_categories,
      value: (category) => where((c) => c == category).length);

  /// Gets the indices where [predicate] holds.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// print(colors.indicesWhere((color) => color.contains('re')));
  /// // [0, 1, 2, 3, 5]
  /// ```
  ///
  List<int> indicesWhere(bool predicate(String value)) =>
      indices.where((index) => predicate(this[index])).toList();

  /// Gets the elements at the specified indices.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// print(colors.elementsAtIndices([4, 4, 5, 5, 0]));
  /// // [blue, blue, green, green, red]
  /// ```
  /// (Compare [elementsWhere].)
  ///
  @override
  Categoric elementsAtIndices(List<int> indices) => Categoric(
      indices.map((index) => _categoryIndices[index] == -1
          ? null
          : _categories[_categoryIndices[index]]),
      withCategories: categories);

  /// Gets the elements that match [predicate].
  ///
  /// This is similar to [where] (which also works on this categoric) but, whereas
  /// [where] only returns an iterable, [elementsWhere] returns a categoric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
  /// print(colors.elementsWhere((color) => color.contains('re')));
  /// // [red, red, green, red, green]
  /// print(colors.where((color) => color.contains('re')));
  /// // (red, red, green, red, green)
  /// ```
  ///
  /// (Compare [indicesWhere].)
  ///
  Categoric elementsWhere(bool predicate(String datum)) =>
      Categoric(where(predicate), withCategories: categories);

  /// The Gini impurity.
  num get impurity => _statistic(CategoricStatistic.impurity, (xs) {
        final data = xs as Categoric, proportions = data.proportions;
        return proportions.values
            .map((p) => p * (1 - p))
            .fold(0, (a, b) => a + b);
      });

  /// The entropy (in nats).
  num get entropy => _statistic(CategoricStatistic.entropy, (xs) {
        final data = xs as Categoric, proportions = data.proportions;
        return -proportions.values
            .map((p) => p == 0 ? 0 : p * math.log(p))
            .fold(0, (a, b) => a + b);
      });

  @override
  Map<String, Object> get summary => {
        CategoricStatistic.numberOfInstances: length,
        CategoricStatistic.counts: counts,
        CategoricStatistic.proportions: proportions,
        CategoricStatistic.impurity: impurity,
        CategoricStatistic.entropy: entropy
      };

  @override
  get length => _categoryIndices.length;

  @override
  String operator [](int index) {
    final wrappedIndex = index % length;
    return _categoryIndices[wrappedIndex] == -1
        ? null
        : _categories[_categoryIndices[wrappedIndex]];
  }

  @override
  operator []=(int index, String category) {
    if (!categories.contains(category)) {
      throw Exception(
          'Unrecognized category: "$category". (Use addCategories to add a category.)');
    }
    _categoryIndices[index % length] = _categories.indexOf(category);
  }

  @override
  void add(String element) {
    if (!_categories.contains(element)) {
      recategorize(categories..add(element));
    }
    _categoryIndices.add(_categories.indexOf(element));
  }

  @override
  void addAll(Iterable<String> elements) {
    if (!elements.every(_categories.contains)) {
      recategorize(categories..addAll(elements));
    }
    _categoryIndices.addAll(elements.map(_categories.indexOf));
  }

  @override
  set length(int newLength) {
    if (newLength < length) {
      _categoryIndices.length = newLength;
    } else {
      _categoryIndices.addAll(List<int>.filled(newLength - length, -1));
    }
  }

  @override
  bool remove(element) {
    final index = indexOf(element);
    if (index == -1) {
      return false;
    } else {
      _categoryIndices.removeAt(index);
      return true;
    }
  }

  @override
  String removeAt(int index) {
    final value = this[index];
    _categoryIndices.removeAt(index);
    return value;
  }

  @override
  String removeLast() {
    final value = last;
    _categoryIndices.removeLast();
    return value;
  }

  @override
  void removeRange(int start, int end) {
    _categoryIndices.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(String) predicate) {
    _categoryIndices.removeWhere((index) => predicate(this[index]));
  }

  @override
  void retainWhere(bool Function(String) predicate) {
    _categoryIndices.retainWhere((index) => predicate(this[index]));
  }
}
