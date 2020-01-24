part of packhorse;

class Categoric extends Column<String> {
  Categoric(Iterable<String> data, {List<String> withCategories}) {
    _categories = withCategories == null
        ? ([
            ...{...data.where((value) => value != null)}
          ]..sort())
        : [
            ...{...withCategories}
          ];

    _categoryIndices = [...data.map((datum) => _categories.indexOf(datum))];
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
    final categoryList = [
      ...{...categories}
    ];
    _categoryIndices = [...map((datum) => categoryList.indexOf(datum))];
    _categories = List<String>.from(categoryList);
  }

  /// Adds categories to the existing categories.
  void addCategories(List<String> newCategories) {
    final categories = [
      ...{..._categories, ...newCategories}
    ]..sort();
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
  /// for (final species in iris.cats['species'].sample(5)) {
  ///     print(species);
  /// }
  /// ```
  ///
  /// ```text
  /// setosa
  /// setosa
  /// setosa
  /// virginica
  /// setosa
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
      return Categoric(
          [for (final index in shuffledIndices.sublist(0, n)) this[index]],
          withCategories: categories);
    }
  }

  /// The counts, by category.
  ///
  /// Example:
  ///
  /// ```dart
  /// iris.cats['species'].counts.forEach((species, count) {
  ///    print('$species: $count');
  /// });
  ///
  /// ```
  ///
  /// ```text
  /// setosa: 50
  /// versicolor: 50
  /// virginica: 50
  /// ```
  ///
  Map<String, int> get counts => Map<String, int>.fromIterable(_categories,
      value: (category) => where((c) => c == category).length);

  /// # `proportions`
  ///
  /// The proportions, by category.
  ///
  /// Example:
  ///
  /// ```dart
  /// iris.cats['species'].proportions.forEach((species, proportion) {
  ///    print('$species: $proportion');
  /// });
  ///
  /// ```
  ///
  /// ```text
  /// setosa: 0.3333333333333333
  /// versicolor: 0.3333333333333333
  /// virginica: 0.3333333333333333
  /// ```
  ///
  Map<String, double> get proportions =>
      Map<String, double>.fromIterable(_categories,
          value: (category) => where((c) => c == category).length / length);

  /// Returns the indices of elements that match a specified predicate.
  ///
  /// (Use `elementsWhere` to get elements that match a predicate.)
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final index in iris.cats['species'].indicesWhere(
  ///     (species) => species.contains('color')).take(5)) {
  ///         print(index);
  ///     }
  /// ```
  ///
  /// ```text
  /// 50
  /// 51
  /// 52
  /// 53
  /// 54
  /// ```
  ///
  List<int> indicesWhere(bool predicate(String value)) =>
      [...indices.where((index) => predicate(this[index]))];

  /// Returns the elements at the specified indices.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final species in iris.cats['species'].elementsAtIndices([0, 50, 100])) {
  ///     print(species);
  /// }
  /// ```
  ///
  /// ```text
  /// setosa
  /// versicolor
  /// virginica
  /// ```
  ///
  @override
  Categoric elementsAtIndices(Iterable<int> indices) => Categoric(
      indices.map((index) => _categoryIndices[index] == -1
          ? null
          : _categories[_categoryIndices[index]]),
      withCategories: categories);

  /// Returns the elements that match a predicate.
  ///
  /// This is similar to 'where' but, whereas 'where' returns an iterable, 'elementsWhere' returns a categoric.
  ///
  /// (Use `indicesWhere` to get the indices of the elements.)
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final element in iris.cats['species'].elementsWhere(
  ///     (species) => species.contains('color')).take(5)) {
  ///         print(element);
  ///     }
  /// ```
  ///
  /// ```text
  /// versicolor
  /// versicolor
  /// versicolor
  /// versicolor
  /// versicolor
  /// ```
  ///
  Categoric elementsWhere(bool predicate(String datum)) =>
      Categoric(where(predicate), withCategories: categories);

  /// The Gini impurity.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.cats['species'].impurity);
  /// ```
  ///
  /// ```text
  /// 0.6666666666666667
  /// ```
  ///
  num get impurity => _statistic(CategoricStatistic.impurity, (data) {
        final proportions = data.proportions;
        return proportions.values
            .map((p) => p * (1 - p))
            .fold(0, (a, b) => a + b);
      });

  /// The entropy (in nats).
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.cats['species'].entropy);
  /// ```
  ///
  /// ```text
  /// 1.0986122886681096
  /// ```
  ///
  num get entropy => _statistic(CategoricStatistic.entropy, (data) {
        final proportions = data.proportions;
        return -proportions.values
            .map((p) => p == 0 ? 0 : p * math.log(p))
            .fold(0, (a, b) => a + b);
      });

  /// A summary of the stistics associated with this data.
  Map<String, num> get summary => {
        for (final statistic in _categoricStatisticGenerator.keys)
          statistic.toString().split('.').last:
              _categoricStatisticGenerator[statistic](this)
      };

  /// Returns a sample of measures for a specified statistic reaped
  /// from bootstrapping on these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final entropy in iris.cats['species'].bootstrapSampled(
  ///   CategoricStatistic.entropy, samples: 10)) {
  ///     print(entropy.toStringAsFixed(4));
  /// }
  /// ```
  ///
  /// ```text
  /// 1.0970
  /// 1.0904
  /// 1.0969
  /// 1.0958
  /// 1.0805
  /// 1.0985
  /// 1.0936
  /// 1.0958
  /// 1.0948
  /// 1.0985
  /// ```
  ///
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
    final wrappedIndex = index % length,
        categoryIndex = _categoryIndices[wrappedIndex];
    return categoryIndex == -1 ? null : _categories[categoryIndex];
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
  String toString() => 'Categoric ${[...sequence(length).map((i) => this[i])]}';

  /// A store for calculated statistics.
  Map<CategoricStatistic, num> _statsMemoization = {};

  /// A helper method that looks up, calculates or stores statistics.
  num _statistic(CategoricStatistic key, num f(Categoric xs)) =>
      _statsMemoization.containsKey(key)
          ? _statsMemoization[key]
          : _statsMemoization[key] = f(elementsAtIndices(nonNullIndices));
}
