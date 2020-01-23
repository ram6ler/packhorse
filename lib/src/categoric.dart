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

  /// Returns a random sample of `n` elements as a numeric.
  ///
  /// Optionally set the `seed` to reproduce the results. To draw a
  /// sample without replacement, set `withReplacement` to `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Categoric(['a', 'b', 'c', 'd', 'e']);
  /// print(xs.sample(10, seed: 0));
  /// ```
  ///
  Categoric sample(int n, {bool withReplacement = true, int seed}) {
    if (n < 0) {
      throw Exception('Can only take a non negative number of instances.');
    }

    final rand = seed == null ? math.Random() : math.Random(seed);
    if (withReplacement) {
      return Categoric(sequence(n).map((_) => this[rand.nextInt(length)]),
          withCategories: categories);
    } else {
      if (n > length) {
        throw Exception(
            'With no replacement, can only take up to $length instances.');
      }
      final shuffledIndices = indices..shuffle(rand);
      return Categoric(shuffledIndices.sublist(0, n).map((i) => this[i]),
          withCategories: categories);
    }
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
  Categoric elementsAtIndices(Iterable<int> indices) => Categoric(
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
  num get impurity => _statistic(CategoricStatistic.impurity, (data) {
        final proportions = data.proportions;
        return proportions.values
            .map((p) => p * (1 - p))
            .fold(0, (a, b) => a + b);
      });

  /// The entropy (in nats).
  num get entropy => _statistic(CategoricStatistic.entropy, (data) {
        final proportions = data.proportions;
        return -proportions.values
            .map((p) => p == 0 ? 0 : p * math.log(p))
            .fold(0, (a, b) => a + b);
      });

  Map<String, Object> get summary => {
        for (final statistic in CategoricStatistic.values)
          statistic.toString().split('.').last:
              _categoricStatisticGenerator[statistic](this)
      };

  Numeric bootstrapSampled(CategoricStatistic statistic,
          {int samples = 100, int seed}) =>
      Numeric([
        ...sequence(samples)
            .map((_) => _categoricStatisticGenerator[statistic](sample(length)))
      ]);

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

  @override
  String toString() => 'Categoric ${elementsAtIndices(indices)}';

  /// A store for calculated statistics.
  Map<CategoricStatistic, num> _statsMemoization = {};

  /// A helper method that looks up, calculates or stores statistics.
  num _statistic(CategoricStatistic key, num f(Categoric xs)) =>
      _statsMemoization.containsKey(key)
          ? _statsMemoization[key]
          : _statsMemoization[key] = f(elementsAtIndices(nonNullIndices));
}
