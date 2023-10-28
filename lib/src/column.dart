import "dart:math" as math;

import 'package:normal/normal.dart' show Normal;

import "error.dart";

enum NumericStat {
  /// The sum.
  sum,

  /// The sum of the squares.
  sumOfSquares,

  /// The mean.
  mean,

  /// The variance in the data.
  variance,

  /// The estimated variance in the sampled population.
  inferredVariance,

  /// The standard deviation in the data.
  standardDeviation,

  /// The estimated standard deviation in the sampled population.
  inferredStandardDeviation,

  /// Fisher's moment coefficient of skewness.
  skewness,

  /// The mean absolute deviation from the mean.
  meanAbsoluteDeviation,

  /// The lower quartile.
  lowerQuartile,

  /// The median.
  median,

  /// The upper quartile.
  upperQuartile,

  /// The inter-quartile range.
  interQuartileRange,

  /// The greatest value
  maximum,

  /// The greatest value that is not an outlier.
  maximumNonOutlier,

  /// The least value.
  minimum,

  /// The least value that is not an outlier.
  minimumNonOutlier,

  /// The range of stored values.
  range;

  String get name => this.toString().split(".")[1];
}

enum CategoricStat {
  /// Gini impurity; sum p(1-p).
  impurity,

  /// Entropy; sum (-p log(p)).
  entropy;

  String get name => this.toString().split(".")[1];
}

/// Base class for numeric and categoric columns.
abstract class Column<Internal extends Comparable,
    External extends Comparable> {
  Column(this._data);

  /// Internal representation of data.
  List<Internal> _data;

  /// A copy of this column.
  Column get copy;

  /// A bootstrap sample from this column.
  Column bootstrap({int? seed});

  /// Bootstrap confidence intervals for statistics.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final petalWidth = petals.numericColumns["petal_width"]!,
  ///   species = petals.categoricColumns["species"]!;
  /// 
  /// print("Petal width:");
  /// for (final MapEntry(:key, :value) in
  ///   (await petalWidth.bootstrapConfidenceIntervals(
  ///      simulations: 10000,
  ///      confidence: 0.9,
  ///    )).entries) {
  ///   final (lower, upper) = value;
  ///   print("$key: "
  ///     "(${lower.toStringAsFixed(2)}, ${upper.toStringAsFixed(2)})");
  /// }
  /// 
  /// print("\nSpecies:");
  /// for (final MapEntry(:key, :value) in
  ///   (await species.bootstrapConfidenceIntervals(
  ///      simulations: 10000,
  ///      confidence: 0.9,
  ///    )).entries) {
  ///   final (lower, upper) = value;
  ///   print("$key: "
  ///     "(${lower.toStringAsFixed(2)}, ${upper.toStringAsFixed(2)})");
  /// }
  /// ```
  /// 
  /// ```text
  /// Petal width:
  /// sum: (10.30, 19.40)
  /// sumOfSquares: (15.34, 37.10)
  /// mean: (0.86, 1.62)
  /// variance: (0.32, 0.83)
  /// inferredVariance: (0.35, 0.91)
  /// standardDeviation: (0.57, 0.91)
  /// inferredStandardDeviation: (0.59, 0.95)
  /// skewness: (-0.30, 0.15)
  /// meanAbsoluteDeviation: (0.41, 0.84)
  /// lowerQuartile: (0.20, 1.45)
  /// median: (0.20, 1.80)
  /// upperQuartile: (1.42, 2.10)
  /// interQuartileRange: (0.40, 1.85)
  /// maximum: (1.90, 2.50)
  /// maximumNonOutlier: (1.80, 2.50)
  /// minimum: (0.20, 0.20)
  /// minimumNonOutlier: (0.20, 1.40)
  /// range: (1.70, 2.30)
  /// 
  /// Species:
  /// impurity: (0.49, 0.67)
  /// entropy: (0.82, 1.10)
  /// ```
  /// 
  Future<Map<String, (num, num)>> bootstrapConfidenceIntervals({
    int simulations = 1000,
    num confidence = 0.95,
  }) async {
    final sample = {
      for (final key in (this is NumericColumn
          ? NumericStat.values
          : CategoricStat.values))
        key.name: NumericColumn([])
    };
    while (simulations > 0) {
      for (final MapEntry(:key, :value) in bootstrap().summary.entries) {
        sample[key]!.add(value);
      }
      simulations--;
    }
    if (confidence > 1) {
      confidence /= 100;
    }
    if (confidence < 0 || confidence > 1) {
      throw PackhorseError.badArgument("Confidence $confidence expected to be"
          "a proportion in [0, 1] or a percentage in [0, 100]");
    }

    final lower = (1 - confidence) / 2, upper = 1 - lower;
    return {
      for (final MapEntry(:key, :value) in sample.entries)
        key: (value.tile(lower), value.tile(upper)),
    };
  }

  /// The number of elements in this column.
  int get length => _data.length;

  /// A statistical summary of this column.
  Map<String, num> get summary;

  /// A copy of the data stored in this column..
  List<External> get values => [for (var i = 0; i < length; i++) this[i]];

  /// The unique values stored in this column.
  Set<External> get uniqueValues => {for (var i = 0; i < length; i++) this[i]};

  /// The values stored at `indices` in this column.
  List<External> valuesAtIndices(Iterable<int> indices) =>
      [for (final i in indices) this[i]];

  External operator [](int index);

  void operator []=(int index, External value);

  /// Adds `element` to this column.
  void add(External element);

  /// Adds all values in `elements` to this column.
  void addAll(Iterable<External> elements);

  /// The indices that would order the data.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final xs = [1, 5, 3, 2, 10, 6].toNumericColumn(),
  ///     indices = xs.orderedIndices;
  /// print(xs);
  /// print(indices);
  /// print(xs.valuesAtIndices(indices));
  /// ```
  /// 
  /// ```text
  /// NumericColumn [1, 5, 3, 2, 10, 6]
  /// [0, 3, 2, 1, 5, 4]
  /// [1, 2, 3, 5, 6, 10]
  /// ```
  /// 
  /// Output:
  /// 
  List<int> get orderedIndices => [for (var i = 0; i < length; i++) i]
    ..sort((a, b) => this[a].compareTo(this[b]));

  /// The indices the respective elements would move to upon ordering.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final xs = [1, 5, 3, 2, 10, 6].toNumericColumn(),
  ///       blank = <num>[0, 0, 0, 0, 0, 0],
  ///       indices = xs.indexOrders;
  /// for (var i = 0; i < 6; i++) {
  ///   blank[indices[i]] = xs[i];
  /// }
  /// print(xs);
  /// print(blank);
  /// ```
  /// 
  /// ```text
  /// NumericColumn [1, 5, 3, 2, 10, 6]
  /// [1, 2, 3, 5, 6, 10]
  /// ```
  /// 
  /// Output:
  /// 
  List<int> get indexOrders {
    final indices = orderedIndices;
    return [for (var i = 0; i < length; i++) i]
      ..sort((a, b) => indices[a].compareTo(indices[b]));
  }

  /// The indices of the values that meet `predicate`.
  List<int> indicesWhere(bool Function(External) predicate) => [
        for (var i = 0; i < length; i++)
          if (predicate(this[i])) i
      ];

  /// The number of times each value occurs in this column.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final petalWidth = iris.numericColumns["petal_length"]!,
  ///   counts = petalWidth.counts,
  ///   orderedKeys = [...counts.keys]..sort();
  /// for (final key in orderedKeys) {
  ///   print("$key " + "|" * counts[key]!);
  /// }
  /// ```
  /// 
  /// ```text
  /// 1.0 |
  /// 1.1 |
  /// 1.2 ||
  /// 1.3 |||||||
  /// 1.4 |||||||||||||
  /// 1.5 |||||||||||||
  /// 1.6 |||||||
  /// 1.7 ||||
  /// 1.9 ||
  /// 3.0 |
  /// 3.3 ||
  /// 3.5 ||
  /// 3.6 |
  /// 3.7 |
  /// 3.8 |
  /// 3.9 |||
  /// 4.0 |||||
  /// 4.1 |||
  /// 4.2 ||||
  /// 4.3 ||
  /// 4.4 ||||
  /// 4.5 ||||||||
  /// 4.6 |||
  /// 4.7 |||||
  /// 4.8 ||||
  /// 4.9 |||||
  /// 5.0 ||||
  /// 5.1 ||||||||
  /// 5.2 ||
  /// 5.3 ||
  /// 5.4 ||
  /// 5.5 |||
  /// 5.6 ||||||
  /// 5.7 |||
  /// 5.8 |||
  /// 5.9 ||
  /// 6.0 ||
  /// 6.1 |||
  /// 6.3 |
  /// 6.4 |
  /// 6.6 |
  /// 6.7 ||
  /// 6.9 |
  /// ```
  /// 
  Map<External, int> get counts {
    final values = this.values;
    return {
      for (final v in {...values}) v: values.where((x) => x == v).length
    };
  }

  /// The proportion of this column made up by each value.
  /// 
  /// Example:
  /// 
  /// ```dart
  /// final species = iris.categoricColumns["species"]!;
  /// for (final MapEntry(:key, :value) in species.proportions.entries) {
  ///   print("$key: $value");
  /// }
  /// ```
  /// 
  /// ```text
  /// setosa: 0.3333333333333333
  /// versicolor: 0.3333333333333333
  /// virginica: 0.3333333333333333
  /// ```
  /// 
  Map<External, num> get proportions {
    final values = this.values;
    return {
      for (final v in {...values})
        v: values.where((x) => x == v).length / length
    };
  }

  /// The indices where data is missing.
  List<int> get indicesWithMissingValues;

  /// The indices where data is present.
  List<int> get indicesWithValues;

  @override
  String toString() => "$runtimeType [${[
        for (var i = 0; i < length; i++) this[i].toString()
      ].join(", ")}]";
}

class NumericColumn extends Column<num, num> {
  NumericColumn(Iterable<num> xs) : super(xs.toList());

  @override
  num operator [](int index) => _data[index % length];

  @override
  void operator []=(int index, num value) {
    _statsCache.clear();
    _data[index % length] = value;
  }

  @override
  NumericColumn get copy => NumericColumn(this.values);

  @override
  NumericColumn bootstrap({int? seed}) {
    final rand = math.Random(seed);
    return NumericColumn(
        [for (var _ = 0; _ < length; _++) this[rand.nextInt(length)]]);
  }

  @override
  List<int> get indicesWithValues => [
        for (var i = 0; i < length; i++)
          if (!this[i].isNaN) i
      ];

  @override
  List<int> get indicesWithMissingValues => [
        for (var i = 0; i < length; i++)
          if (this[i].isNaN) i
      ];

  @override
  void add(num element) {
    _statsCache.clear();
    _data.add(element);
  }

  @override
  void addAll(Iterable<num> elements) {
    _statsCache.clear();
    _data.addAll(elements);
  }

  @override
  Map<String, num> get summary => {
        for (final key in NumericStat.values)
          key.name: switch (key) {
            NumericStat.sum => sum,
            NumericStat.sumOfSquares => sumOfSquares,
            NumericStat.mean => mean,
            NumericStat.variance => variance,
            NumericStat.inferredVariance => inferredVariance,
            NumericStat.standardDeviation => standardDeviation,
            NumericStat.inferredStandardDeviation => inferredStandardDeviation,
            NumericStat.skewness => skewness,
            NumericStat.meanAbsoluteDeviation => meanAbsoluteDeviation,
            NumericStat.lowerQuartile => lowerQuartile,
            NumericStat.median => median,
            NumericStat.upperQuartile => upperQuartile,
            NumericStat.interQuartileRange => interQuartileRange,
            NumericStat.minimum => minimum,
            NumericStat.maximum => maximum,
            NumericStat.range => range,
            NumericStat.minimumNonOutlier => minimumNonOutlier,
            NumericStat.maximumNonOutlier => maximumNonOutlier,
          }
      };

  /// A cache for calculated statistics.
  final Map<NumericStat, num> _statsCache = {};

  /// A convenience function for checking the cache and calculating statistics.
  num _getStat(NumericStat stat) {
    if (!_statsCache.containsKey(stat)) {
      _statsCache[stat] = switch (stat) {
        NumericStat.sum => values.fold<num>(0, (a, b) => a + b),
        NumericStat.sumOfSquares =>
          values.map((x) => math.pow(x, 2)).fold<num>(0, (a, b) => a + b),
        NumericStat.mean => sum / length,
        NumericStat.variance => values
                .map((x) => math.pow(x - mean, 2))
                .fold<num>(0, (a, b) => a + b) /
            length,
        NumericStat.inferredVariance => variance * length / (length - 1),
        NumericStat.standardDeviation => math.sqrt(variance),
        NumericStat.inferredStandardDeviation => math.sqrt(inferredVariance),
        NumericStat.skewness =>
          residuals.map((x) => math.pow(x, 3)).fold<num>(0, (a, b) => a + b) /
              math.pow(
                  residuals
                      .map((x) => math.pow(x, 2))
                      .fold<num>(0, (a, b) => a + b),
                  3 / 2),
        NumericStat.meanAbsoluteDeviation =>
          values.map((x) => (x - mean).abs()).fold<num>(0, (a, b) => a + b) /
              length,
        NumericStat.lowerQuartile => tile(0.25),
        NumericStat.median => tile(0.50),
        NumericStat.upperQuartile => tile(0.75),
        NumericStat.interQuartileRange => upperQuartile - lowerQuartile,
        NumericStat.minimum => values.reduce(math.min),
        NumericStat.maximum => values.reduce(math.max),
        NumericStat.range => maximum - minimum,
        NumericStat.minimumNonOutlier => values
            .where((x) => x >= lowerQuartile - 1.5 * interQuartileRange)
            .reduce(math.min),
        NumericStat.maximumNonOutlier => values
            .where((x) => x <= upperQuartile + 1.5 * interQuartileRange)
            .reduce(math.max),
      };
    }
    return _statsCache[stat]!;
  }

  /// The p-tile of the stored data, where 0 ≤ p ≤ 1.
  /// 
  /// For example, `lowerQuartile` is equivalent to `tile(0.25)`.
  num tile(num p) {
    if (p > 1) {
      p /= 100;
    }

    if (p < 0 || p > 1) {
      throw PackhorseError.badArgument(
          "p = $p should be in [0, 1] or [0, 100].");
    }
    final d = p * (length - 1),
        index = d.toInt(),
        r = d - index,
        sortedValues = values..sort(),
        dy = sortedValues[index + 1] - sortedValues[index];
    return sortedValues[index] + r * dy;
  }

  /// The sum of the stored data.
  num get sum => _getStat(NumericStat.sum);

  /// The sum of the squares of the stored data.
  num get sumOfSquares => _getStat(NumericStat.sumOfSquares);

  /// The mean of the stored data.
  num get mean => _getStat(NumericStat.mean);

  /// The variance in the stored data.
  num get variance => _getStat(NumericStat.variance);

  /// The estimated variance in the population the stored data was sampled from.
  num get inferredVariance => _getStat(NumericStat.inferredVariance);

  /// The standard deviation in the data.
  num get standardDeviation => _getStat(NumericStat.standardDeviation);

  /// The estimated standard deviation in the population the stored data
  /// was sampled from.
  num get inferredStandardDeviation =>
      _getStat(NumericStat.inferredStandardDeviation);

  /// Fisher's moment coefficient of skewness of the stored data.
  num get skewness => _getStat(NumericStat.skewness);

  /// The mean absolute deviation from the mean of the stored data.
  num get meanAbsoluteDeviation => _getStat(NumericStat.meanAbsoluteDeviation);

  /// The lower quartile of the stored data.
  num get lowerQuartile => _getStat(NumericStat.lowerQuartile);

  /// The median of the stored data.
  num get median => _getStat(NumericStat.median);

  /// The upper quartile of the stored data.
  num get upperQuartile => _getStat(NumericStat.upperQuartile);

  /// The inter-quartile range of the stored data.
  num get interQuartileRange => _getStat(NumericStat.interQuartileRange);

  /// The greatest value in the stored data.
  num get maximum => _getStat(NumericStat.maximum);

  /// The greatest value on the stored data that is not an outlier.
  num get maximumNonOutlier => _getStat(NumericStat.maximumNonOutlier);

  /// The least value in the stored data.
  num get minimum => _getStat(NumericStat.minimum);

  /// The least value in the stored data that is not an outlier.
  num get minimumNonOutlier => _getStat(NumericStat.minimumNonOutlier);

  /// The range of stored values.
  num get range => _getStat(NumericStat.range);

  /// The quantiles associated with the stored values.
  List<num> get quantiles {
    final points = [for (var i = 0; i < length; i++) (i + 0.5) / length];
    return [for (final i in indexOrders) points[i]];
  }

  /// The theoretical quantiles associated with the stored values under
  /// the assumption that the sampled population is normal.
  List<num> get quantilesIfNormal {
    final d = Normal(mean, inferredVariance);
    return [for (var i = 0; i < length; i++) d.cdf(this[i])];
  }

  /// The number of standard deviations each stored value is from the mean.
  List<num> get zScores =>
      [for (var i = 0; i < length; i++) (this[i] - mean) / standardDeviation];

  /// The number of estimated standard deviations of the sampled population
  /// each stored value is from the mean.
  List<num> get zScoresInferred => [
        for (var i = 0; i < length; i++)
          (this[i] - mean) / inferredStandardDeviation
      ];

  /// The difference between each stored value and the mean.
  List<num> get residuals => [for (var i = 0; i < length; i++) this[i] - mean];

  /// The squared difference between each stored value and the mean.
  List<num> get squaredResiduals =>
      [for (var i = 0; i < length; i++) math.pow(this[i] - mean, 2)];

  /// The z score associated with each value under the assumption the
  /// sampled population has mean μ and standard deviation σ.
  List<num> standardizedZScores(num mu, num sigma) =>
      [for (var i = 0; i < length; i++) (this[i] - mu) / sigma];

  /// The dot product of this and `that`.
  num dot(NumericColumn that) {
    if (that.length != length) {
      throw PackhorseError.badStructure(
          "Dot product on columns with different lengths.");
    }

    if ((values.any((x) => x.isNaN)) || (that.values.any((x) => x.isNaN))) {
      throw PackhorseError.badStructure(
          "Dot product on columns with missing values.");
    }
    return [for (var i = 0; i < length; i++) this[i] * that[i]]
        .fold<num>(0, (a, b) => a + b);
  }

  /// The correlation between the values stored in this and those in `that`.
  num correlation(NumericColumn that) {
    if (that.length != length) {
      throw PackhorseError.badStructure(
          "Correlation between columns with different lengths.");
    }
    final thisVector = NumericColumn(zScores),
        thatVector = NumericColumn(that.zScores);
    return thisVector.dot(thatVector);
  }

  /// An approximate, nonparametric kernel density function.
  num Function(num) get kernelDensityFunction {
    // Based on smooth Parzen estimate; see ESL p. 208-209.
    final n = 100,
        gap = (maximum - minimum) / n,
        distributions = [...values.map((x) => Normal(x, gap))];

    return (num x) =>
        distributions.map((d) => d.pdf(x) / length).fold(0.0, (a, b) => a + b);
  }

  /// An approximate density function assuming the data is normally distributed.
  num Function(num) get densityFunctionIfNormal => Normal(mean, variance).pdf;
}

class CategoricColumn extends Column<int, String> {
  /// A string to represent missing data.
  static const missingValueMarker = "<NA>";

  CategoricColumn(Iterable<String> xs)
      : _categories = [
          ...{
            for (final x in xs)
              if (x.toUpperCase() != missingValueMarker) x
          }
        ],
        super([]) {
    _data.addAll(xs.map((x) => _categories.indexOf(x)));
  }

  /// Internal representation of the categories.
  final List<String> _categories;

  /// A copy of the categories of stored data.
  List<String> get categories => [for (final c in _categories) c];

  @override
  String operator [](int index) => _data[index % length] == -1
      ? missingValueMarker
      : _categories[_data[index % length]];

  @override
  void operator []=(int index, String value) {
    _statsCache.clear();
    if (value.toUpperCase() == missingValueMarker) {
      _data[index % length] = -1;
    } else {
      if (!_categories.contains(value)) {
        _categories.add(value);
      }
      _data[index % length] = _categories.indexOf(value);
    }
  }

  @override
  CategoricColumn get copy =>
      CategoricColumn(this.values)..resetCategories(_categories);

  @override
  CategoricColumn bootstrap({int? seed}) {
    final rand = math.Random(seed);
    return CategoricColumn(
        [for (var _ = 0; _ < length; _++) this[rand.nextInt(length)]])
      ..resetCategories(_categories);
  }

  @override
  List<int> get indicesWithValues => [
        for (var i = 0; i < length; i++)
          if (_data[i] != -1) i
      ];

  @override
  List<int> get indicesWithMissingValues => [
        for (var i = 0; i < length; i++)
          if (_data[i] == -1) i
      ];

  @override
  void add(String element) {
    _statsCache.clear();
    if (element.toUpperCase() == missingValueMarker) {
      _data.add(-1);
    } else {
      if (!_categories.contains(element)) {
        _categories.add(element);
      }
      _data.add(_categories.indexOf(element));
    }
  }

  @override
  void addAll(Iterable<String> elements) {
    _statsCache.clear();
    for (final element in elements) {
      add(element);
    }
  }

  @override
  Map<String, num> get summary => {
        for (final key in CategoricStat.values)
          key.name: switch (key) {
            CategoricStat.entropy => entropy,
            CategoricStat.impurity => impurity
          }
      };

  /// A cache for calculated statistics.
  final Map<CategoricStat, num> _statsCache = {};

  /// A helper function for checking the cache and calculating statistics.
  num _getStat(CategoricStat stat) {
    if (!_statsCache.containsKey(stat)) {
      _statsCache[stat] = switch (stat) {
        CategoricStat.impurity => proportions.values
            .map((p) => p * (1 - p))
            .fold<num>(0, (a, b) => a + b),
        CategoricStat.entropy => proportions.values
            .map((p) => p == 0 ? 0 : -p * math.log(p))
            .fold<num>(0, (a, b) => a + b)
      };
    }
    return _statsCache[stat]!;
  }

  /// The Gini impurity of the stored data.
  num get impurity => _getStat(CategoricStat.impurity);

  /// A measure of the entropy of the stored data.
  num get entropy => _getStat(CategoricStat.entropy);

  /// Resets the categories; for example, if we would like the categories
  /// of two categoric columns to match.
  void resetCategories(Iterable<String> categories) {
    final newCategories = [
      ...{
        for (final c in categories)
          if (c.toUpperCase() != missingValueMarker) c
      }
    ];
    for (var i = 0; i < length; i++) {
      final value = this[i];
      _data[i] =
          value == missingValueMarker ? -1 : newCategories.indexOf(value);
    }
    this._categories
      ..clear()
      ..addAll(categories);
  }
}
