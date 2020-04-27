part of packhorse;

/// A convenience wrapper class for [List<num>], with
/// properties and methods commonly used in data analysis.
class Numeric extends _Column<num> {
  Numeric(Iterable<num> data) {
    _elements = [...data];
  }

  /// The [List<num>] wrapped by this numeric.
  List<num> _elements;

  /// A helper method for defining operations.
  Numeric _operator(Object that, num Function(num, num) f, String name) {
    if (that is num) {
      return Numeric(map((t) => f(t, that)));
    }

    if (that is List && that.first is num) {
      if (that.length != length) {
        throw Exception('Lengths do not match: \n  $this\n  $that');
      }
      return Numeric(indices.map((i) => f(this[i], that[i])));
    }

    throw Exception('Cannot apply $name to $that.');
  }

  /// Iteratively adds `that` to this numeric.
  ///
  /// If `that` is a num, its value is added to each element;
  /// if it is a list, its values are added to the respective
  /// values in this numeric.
  ///
  /// ```dart
  /// final numeric = Numeric([1, 2, 3]);
  ///
  /// print(numeric + Numeric([10, 11, 12]));
  /// print(numeric + [10, 11, 12]);
  /// print(numeric + 10);
  /// ```
  ///
  /// ```text
  /// Numeric [11, 13, 15]
  /// Numeric [11, 13, 15]
  /// Numeric [11, 12, 13]
  /// ```
  ///
  @override
  Numeric operator +(Object that) =>
      _operator(that, (a, b) => a + b, 'addition');

  /// Iteratively subtracts `that` from this numeric.
  ///
  /// If `that` is a num, its value is subtracted from each element;
  /// if it is a list, its values are subtracted the respective
  /// values in this numeric.
  ///
  /// ```dart
  /// final numeric = Numeric([1, 2, 3]);
  ///
  /// print(numeric - Numeric([10, 11, 12]));
  /// print(numeric - [10, 11, 12]);
  /// print(numeric - 10);
  /// ```
  ///
  /// ```text
  /// Numeric [-9, -9, -9]
  /// Numeric [-9, -9, -9]
  /// Numeric [-9, -8, -7]
  /// ```
  ///
  Numeric operator -(Object that) =>
      _operator(that, (a, b) => a - b, 'subtraction');

  /// Returns an iterative negation of the data in this numeric.
  ///
  /// ```dart
  /// final numeric = Numeric([1, 2, 3]);
  /// print(-numeric);
  /// ```
  ///
  /// ```text
  /// Numeric [-1, -2, -3]
  /// ```
  ///
  Numeric operator -() => Numeric(map((x) => x == null ? null : -x));

  /// Iteratively multiplies this numeric by `that`.
  ///
  /// If `that` is a num, each element is multiplied by it;
  /// if it is a list, each value is multiplied by each respective
  /// value in it. (Use `dot` for dot multiplication).
  ///
  /// ```dart
  /// final numeric = Numeric([1, 2, 3]);
  ///
  /// print(numeric * Numeric([10, 11, 12]));
  /// print(numeric * [10, 11, 12]);
  /// print(numeric * 10);
  /// ```
  ///
  /// ```text
  /// Numeric [10, 22, 36]
  /// Numeric [10, 22, 36]
  /// Numeric [10, 20, 30]
  /// ```
  ///
  Numeric operator *(Object that) =>
      _operator(that, (a, b) => a * b, 'multiplication');

  /// Iteratively divides this numeric by `that`.
  ///
  /// If `that` is a num, each element is divided by it;
  /// if it is a list, each value is divided by each respective
  /// value in it.
  ///
  /// ```dart
  /// final numeric = Numeric([1, 2, 3]);
  ///
  /// print(numeric / Numeric([10, 11, 12]));
  /// print(numeric / [10, 11, 12]);
  /// print(numeric / 10);
  /// ```
  ///
  /// ```text
  /// Numeric [0.1, 0.18181818181818182, 0.25]
  /// Numeric [0.1, 0.18181818181818182, 0.25]
  /// Numeric [0.1, 0.2, 0.3]
  /// ```
  ///
  Numeric operator /(Object that) =>
      _operator(that, (a, b) => a / b, 'division');

  /// Iteratively performs modular division of this numeric by `that`.
  ///
  /// If `that` is a num, each element is divided by it;
  /// if it is a list, each value is divided by each respective
  /// value in it.
  ///
  /// ```dart
  /// final numeric = Numeric([10, 11, 12]);
  ///
  /// print(numeric % Numeric([1, 2, 3]));
  /// print(numeric % [1, 2, 3]);
  /// print(numeric % 3);
  /// ```
  ///
  /// ```text
  /// Numeric [0, 1, 0]
  /// Numeric [0, 1, 0]
  /// Numeric [1, 2, 0]
  /// ```
  ///
  Numeric operator %(Object that) =>
      _operator(that, (a, b) => a % b, 'remainder');

  /// Iteratively performs whole division of this numeric by `that`.
  ///
  /// If `that` is a num, each element is divided by it;
  /// if it is a list, each value is divided by each respective
  /// value in it.
  ///
  /// ```dart
  /// final numeric = Numeric([10, 11, 12]);
  ///
  /// print(numeric ~/ Numeric([1, 2, 3]));
  /// print(numeric ~/ [1, 2, 3]);
  /// print(numeric ~/ 3);
  /// ```
  ///
  /// ```text
  /// Numeric [10, 5, 4]
  /// Numeric [10, 5, 4]
  /// Numeric [3, 3, 4]
  /// ```
  ///
  Numeric operator ~/(Object that) =>
      _operator(that, (a, b) => a ~/ b, 'whole division');

  Numeric operator >(Object that) =>
      _operator(that, (a, b) => a > b ? 1 : 0, 'greater than');

  Numeric operator >=(Object that) =>
      _operator(that, (a, b) => a >= b ? 1 : 0, 'at least');

  Numeric operator <(Object that) =>
      _operator(that, (a, b) => a < b ? 1 : 0, 'less than');

  Numeric operator <=(Object that) =>
      _operator(that, (a, b) => a <= b ? 1 : 0, 'at most');

  /// Returns the indices of the elements that meet a predicate.
  ///
  /// (Use `elementsWhere` to get the elements that meet a predicate.)
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([5, 12, 3, 2, 5, 6, 11]);
  /// bool isOdd(x) => x % 2 == 1;
  /// print(xs.indicesWhere(isOdd));
  /// ```
  ///
  /// ```text
  /// [0, 2, 4, 6]
  /// ```
  ///
  List<int> indicesWhere(bool Function(num) predicate) =>
      [...indices.where((i) => predicate(this[i]))];

  /// Returns the elements that meet a predicate.
  ///
  /// This is similar to `where` but returns a numeric.
  ///
  /// (Use `indicesWhere` to get the indices of elements that meet a predicate.)
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([5, 12, 3, 2, 5, 6, 11]);
  /// bool isOdd(x) => x % 2 == 1;
  /// print(xs.elementsWhere(isOdd));
  /// print(xs.where(isOdd));
  /// ```
  ///
  /// ```text
  /// Numeric [5, 3, 5, 11]
  /// (5, 3, 5, 11)
  /// ```
  ///
  Numeric elementsWhere(bool Function(num) predicate) =>
      Numeric(where(predicate));

  /// Returns the elements at specified indices.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// print(xs.elementsAtIndices([0, 0, 0, 2, 2, 2]));
  /// ```
  ///
  /// ```text
  /// Numeric [1, 1, 1, 3, 3, 3]
  /// ```
  ///
  @override
  Numeric elementsAtIndices(Iterable<int> indices) =>
      Numeric(indices.map((i) => this[i]));

  /// Returns a random sample of `n` elements as a numeric.
  ///
  /// Optionally set the `seed` to reproduce the results. To draw a
  /// sample without replacement, set `withReplacement` to `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final length in iris.nums['petal_length'].sample(5, seed: 0)) {
  ///     print(length);
  /// }
  /// ```
  ///
  /// ```text
  /// 6.6
  /// 3.9
  /// 3.6
  /// 1.4
  /// 1.4
  /// ```
  ///
  Numeric sample(int n, {bool withReplacement = true, int seed}) {
    if (n < 0) {
      throw Exception('Can only take a non negative number of instances.');
    }

    final rand = seed == null ? math.Random() : math.Random(seed);
    if (withReplacement) {
      return Numeric(sequence(n).map((_) => this[rand.nextInt(length)]));
    } else {
      if (n > length) {
        throw Exception(
            'With no replacement, can only take up to $length instances.');
      }
      final shuffledIndices = indices..shuffle(rand);
      return Numeric(shuffledIndices.sublist(0, n).map((i) => this[i]));
    }
  }

  /// The non null (and non [double.nan]) elements in this numeric.
  Numeric get _nullsOmitted =>
      Numeric(where((x) => x != null && x != double.nan));

  /// The sum of the elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].sum);
  /// ```
  ///
  num get sum =>
      _statistic(NumericStatistic.sum, (xs) => xs.fold(0, (a, b) => a + b));

  /// The sum of the squares of the elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].sumOfSquares);
  /// ```
  ///
  /// ```text
  /// 2582.7100000000005
  /// ```
  ///
  num get sumOfSquares => _statistic(NumericStatistic.sumOfSquares,
      (xs) => xs.map((x) => x * x).fold(0, (a, b) => a + b));

  /// The mean of the elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].mean);
  /// ```
  ///
  /// ```text
  /// 3.7580000000000027
  /// ```
  ///
  num get mean => _statistic(NumericStatistic.mean, (xs) => sum / xs.length);

  /// The variance of the elements, treating these elements as
  /// the population.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].variance);
  /// ```
  ///
  /// ```text
  /// 3.0955026666666674
  /// ```
  ///
  num get variance => _statistic(
      NumericStatistic.variance,
      (xs) =>
          xs.map((x) => math.pow(x - mean, 2)).fold(0, (a, b) => a + b) /
          xs.length);

  /// The unbiased estimate of the variance of the population
  /// these elements represent a sample of.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].inferredVariance);
  /// ```
  ///
  /// ```text
  /// 3.1162778523489942
  /// ```
  ///
  num get inferredVariance => _statistic(NumericStatistic.inferredVariance,
      (xs) => variance * xs.length / (xs.length - 1));

  /// The standard deviation of the elements, treating this
  /// data as the population.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].standardDeviation);
  /// ```
  ///
  /// ```text
  /// 1.7594040657753032
  /// ```
  ///
  num get standardDeviation => _statistic(
      NumericStatistic.standardDeviation, (_) => math.sqrt(variance));

  /// The unbiased estimate of the standard deviation
  /// of the population these elements represent a sample of.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].inferredStandardDeviation);
  /// ```
  ///
  /// ```text
  /// 1.7652982332594667
  /// ```
  ///
  num get inferredStandardDeviation => _statistic(
      NumericStatistic.inferredStandardDeviation,
      (_) => math.sqrt(inferredVariance));

  /// The unbiased estimate of the skewness of the population
  /// these elements represent a sample of.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].skewness);
  /// ```
  ///
  /// ```text
  /// -0.27121905735433716
  /// ```
  ///
  num get skewness => _statistic(NumericStatistic.skewness, (_) {
        final cubedResiduals =
                residuals.map((residual) => math.pow(residual, 3)),
            cubedResidualsMean = cubedResiduals.fold(0, (a, b) => a + b) /
                (cubedResiduals.length - 1);
        return cubedResidualsMean / math.pow(inferredVariance, 1.5);
      });

  /// The mean absolute deviation from the mean of these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].meanAbsoluteDeviation);
  /// ```
  ///
  /// ```text
  /// 1.5627466666666645
  /// ```
  ///
  num get meanAbsoluteDeviation => _statistic(
      NumericStatistic.meanAbsoluteDeviation,
      (xs) =>
          xs.map((x) => (x - mean).abs()).fold(0, (a, b) => a + b) / xs.length);

  /// The lower quartile of these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].lowerQuartile);
  /// ```
  ///
  /// ```text
  /// 1.3250000000000002
  /// ```
  ///
  num get lowerQuartile =>
      _statistic(NumericStatistic.lowerQuartile, (_) => quantile(0.25));

  /// The median of these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].median);
  /// ```
  ///
  /// ```text
  /// 4.35
  /// ```
  ///
  num get median => _statistic(NumericStatistic.median, (_) => quantile(0.5));

  /// The upper quartile of these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].upperQuartile);
  /// ```
  ///
  /// ```text
  /// 5.35
  /// ```
  ///
  num get upperQuartile =>
      _statistic(NumericStatistic.upperQuartile, (_) => quantile(0.75));

  /// The inter-quartile range of these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].interQuartileRange);
  /// ```
  ///
  /// ```text
  /// 4.0249999999999995
  /// ```
  ///
  num get interQuartileRange => _statistic(NumericStatistic.interQuartileRange,
      (_) => upperQuartile - lowerQuartile);

  /// The greatest value in these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].greatest);
  /// ```
  ///
  /// ```text
  /// 6.9
  /// ```
  ///
  num get greatest =>
      _statistic(NumericStatistic.greatest, (xs) => xs.reduce(math.max));

  /// The index of the greatest value in these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].indexOfGreatest);
  /// ```
  ///
  /// ```text
  /// 118
  /// ```
  ///
  int get indexOfGreatest => indexOf(greatest);

  /// The greatest non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies
  /// further than 1.5 inter-quartile ranges from the nearest inter-quartile
  /// range boundary.)
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].greatestNonOutlier);
  /// ```
  ///
  /// ```text
  /// 6.9
  /// ```
  ///
  num get greatestNonOutlier => _statistic(
      NumericStatistic.greatestNonOutlier,
      (xs) => xs
          .where((x) => x <= median + 1.5 * interQuartileRange)
          .reduce(math.max));

  /// The least value in these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].least);
  /// ```
  ///
  /// ```text
  /// 1.0
  /// ```
  ///
  num get least =>
      _statistic(NumericStatistic.least, (xs) => xs.reduce(math.min));

  /// The index of the least value in these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].indexOfLeast);
  /// ```
  ///
  /// ```text
  /// 22
  /// ```
  ///
  int get indexOfLeast => indexOf(least);

  /// The least non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies
  /// further than 1.5 interquartile ranges from the nearest interquartile
  /// range boundary.)
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].leastNonOutlier);
  /// ```
  ///
  /// ```text
  /// 1.0
  /// ```
  ///
  num get leastNonOutlier => _statistic(
      NumericStatistic.leastNonOutlier,
      (xs) => xs
          .where((x) => x >= median - 1.5 * interQuartileRange)
          .reduce(math.min));

  /// The range of the values of elements in this numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].range);
  /// ```
  ///
  /// ```text
  /// 5.9
  /// ```
  ///
  num get range => _statistic(NumericStatistic.range, (_) => greatest - least);

  /// Helper to generate a quantile.
  num _quantile(num p, Numeric ordered) {
    final position = p * (ordered.length - 1),
        i = position.floor(),
        j = position.ceil(),
        weight = position - i;
    return ordered[i] * weight + ordered[j] * (1 - weight);
  }

  /// The interpolated p-quantile of the data, with `p` in the range `[0, 1]`.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].quantile(0.99));
  /// ```
  ///
  /// ```text
  /// 5.298000000000002
  /// ```
  ///
  num quantile(num p) {
    if (p < 0 || p > 1) {
      throw Exception('Proportion should be in range [0, 1].');
    }

    return _quantile(p, _nullsOmitted..sort());
  }

  /// Interpolated p-quantiles of the data.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final quantile in iris.nums['petal_length'].quantiles(
  ///     [0, 0.2, 0.4, 0.6, 0.8, 1])) {
  ///     print(quantile.toStringAsFixed(3));
  /// }
  /// ```
  ///
  /// ```text
  /// 1.400
  /// 1.600
  /// 3.740
  /// 4.240
  /// 5.560
  /// 5.100
  /// ```
  ///
  Numeric quantiles(Iterable<num> ps) {
    if (ps.any((p) => p < 0 || p > 1)) {
      throw Exception('Proportion should be in range [0, 1].');
    }

    final ordered = _nullsOmitted..sort(); // Only sort once...

    return Numeric(ps.map((p) => _quantile(p, ordered)));
  }

  /// The pth percentile of the data, with `p` in the range `[0, 100]`.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.nums['petal_length'].percentile(99).toStringAsFixed(3));
  /// ```
  ///
  /// ```text
  /// 5.298
  /// ```
  ///
  num percentile(num p) {
    if (p < 0 || p > 100) {
      throw Exception('Expecting percent to be in range [0, 100].');
    }
    return quantile(p / 100);
  }

  /// The outliers in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies
  /// further than 1.5 inter-quartile ranges from the nearest inter-quartile
  /// range boundary.)
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final outlier in iris.nums['sepal_width'].outliers.take(5)) {
  ///     print(outlier);
  /// }
  /// ```
  ///
  /// ```text
  /// 3.5
  /// 3.0
  /// 3.2
  /// 3.1
  /// 3.6
  /// ```
  ///
  Numeric get outliers => Numeric(_nullsOmitted
      .where((x) => x < leastNonOutlier || x > greatestNonOutlier));

  /// The cumulative relative frequency associated with these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final pScore in sepals.nums['sepal_length'].pScores.take(5)) {
  ///     print(pScore.toStringAsFixed(3));
  /// }
  /// ```
  ///
  /// ```text
  /// 0.125
  /// 0.042
  /// 0.208
  /// 0.292
  /// 0.792
  /// ```
  ///
  Numeric get pScores => Numeric(indices.map((i) => (i + 0.5) / length))
      .elementsAtIndices(indexOrders);

  /// The theoretical cumulative relative frequency associated with
  /// these elements under the hypothesis of normal distribution.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final pScore in sepals.nums['sepal_length'].pScoresIfNormal.take(5)) {
  ///     print(pScore.toStringAsFixed(3));
  /// }
  /// ```
  ///
  /// ```text
  /// 0.095
  /// 0.079
  /// 0.157
  /// 0.275
  /// 0.826
  /// ```
  ///
  Numeric get pScoresIfNormal => Numeric(
      map((x) => Normal.cdf(x, mean: mean, variance: inferredVariance)));

  /// The z-scores, treating the data in this numeric as a population.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final z in sepals.nums['sepal_length'].zScores.take(5)) {
  ///     print(z.toStringAsFixed(2));
  /// }
  /// ```
  ///
  /// ```text
  /// -1.37
  /// -1.48
  /// -1.05
  /// -0.62
  /// 0.98
  /// ```
  ///
  Numeric get zScores => Numeric(map((x) =>
      x == null || x == double.nan ? null : (x - mean) / standardDeviation));

  /// The z-scores, relative to the population this numeric is treated as a sample from.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final z in sepals.nums['sepal_length'].inferredZScores.take(5)) {
  ///     print(z.toStringAsFixed(2));
  /// }
  /// ```
  ///
  /// ```text
  /// -1.31
  /// -1.41
  /// -1.01
  /// -0.60
  /// 0.94
  /// ```
  ///
  Numeric get inferredZScores => Numeric(map((x) => x == null || x == double.nan
      ? null
      : (x - mean) / inferredStandardDeviation));

  /// The z-scores, calculated from specified mean and standard deviation.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final z in sepals.nums['sepal_length']
  ///   .standardizedZScores(5.0, 2.5).take(5)) {
  ///     print(z.toStringAsFixed(2));
  /// }
  /// ```
  ///
  /// ```text
  /// -0.12
  /// -0.16
  /// 0.00
  /// 0.16
  /// 0.76
  /// ```
  ///
  Numeric standardizedZScores(num mu, num sigma) => Numeric(
      map((x) => x == null || x == double.nan ? null : (x - mu) / sigma));

  /// The residuals, or differences from the mean.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final r in sepals.nums['sepal_length'].residuals.take(5)) {
  ///     print(r.toStringAsFixed(2));
  /// }
  /// ```
  ///
  /// ```text
  /// -1.28
  /// -1.38
  /// -0.98
  /// -0.58
  /// 0.92
  /// ```
  ///
  Numeric get residuals =>
      Numeric(where((x) => x != null && x != double.nan).map((x) => x - mean));

  /// The squared residuals.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final r in sepals.nums['sepal_length'].squaredResiduals.take(5)) {
  ///     print(r.toStringAsFixed(2));
  /// }
  /// ```
  ///
  /// ```text
  /// 1.65
  /// 1.91
  /// 0.97
  /// 0.34
  /// 0.84
  /// ```
  ///
  Numeric get squaredResiduals => Numeric(map((x) => math.pow(x - mean, 2)));

  /// The counts, by value.
  ///
  /// Example:
  ///
  /// ```dart
  /// sepals.nums['sepal_width'].counts.forEach((value, count) {
  ///     print('$value: $count');
  /// });
  /// ```
  ///
  /// ```text
  /// 3.2: 1
  /// 3.1: 2
  /// 3.6: 1
  /// 3.9: 1
  /// 2.3: 1
  /// 2.8: 2
  /// 3.0: 3
  /// 2.9: 1
  /// ```
  ///
  Map<num, int> get counts =>
      {for (final x in toSet()) x: where((value) => value == x).length};

  /// The proportions, by value.
  ///
  /// Example:
  ///
  /// ```dart
  /// sepals.nums['sepal_width'].proportions.forEach((value, proportion) {
  ///     print('$value: ${proportion.toStringAsFixed(3)}');
  /// });
  /// ```
  ///
  /// ```text
  /// 3.2: 0.083
  /// 3.1: 0.167
  /// 3.6: 0.083
  /// 3.9: 0.083
  /// 2.3: 0.083
  /// 2.8: 0.167
  /// 3.0: 0.250
  /// 2.9: 0.083
  /// ```
  ///
  Map<num, double> get proportions => {
        for (final x in toSet()) x: where((value) => value == x).length / length
      };

  /// A summary of the statistics.
  Map<String, num> get summary => {
        for (final statistic in _numericStatisticGenerator.keys)
          statistic.toString().split('.').last:
              _numericStatisticGenerator[statistic](this)
      };

  /// The dot product with Numeric that.
  ///
  /// Example:
  ///
  /// ```dart
  /// final lengths = iris.nums['petal_length'], widths = iris.nums['petal_width'];
  /// print(lengths.dot(widths));
  /// ```
  ///
  /// ```text
  /// 869.25
  /// ```
  ///
  num dot(List<num> that) {
    if (that.length != length) {
      throw Exception('Dot product requires lengths to be the same.');
    }
    if ((any((x) => x == null || x == double.nan)) ||
        (that.any((x) => x == null || x == double.nan))) {
      return null;
    }
    return indices
        .map((index) => this[index] * that[index])
        .fold(0, (a, b) => a + b);
  }

  /// The Pearson correlation between the data in this and that column.
  ///
  /// Example:
  ///
  /// ```dart
  /// final lengths = iris.nums['petal_length'],
  ///   widths = iris.nums['petal_width'];
  ///
  /// print(lengths.correlation(widths));
  /// ```
  ///
  /// ```text
  /// 0.9627460246236469
  /// ```
  ///
  num correlation(List<num> that) {
    final thatVector = Numeric(that), thoseZScores = thatVector.zScores;
    return zScores.dot(thoseZScores) / length;
  }

  /// Returns a sample of measures for a specified statistic reaped
  /// from bootstrapping on these elements.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final mean in iris.nums['petal_length'].bootstrapSampled(
  ///     NumericStatistic.mean, samples: 10)) {
  ///         print(mean.toStringAsFixed(2));
  ///     }
  /// ```
  ///
  /// ```text
  /// 3.77
  /// 3.81
  /// 3.98
  /// 3.58
  /// 3.63
  /// 3.56
  /// 3.70
  /// 3.70
  /// 3.69
  /// 3.77
  /// ```
  ///
  Numeric bootstrapSampled(NumericStatistic statistic,
          {int samples = 100, int seed}) =>
      Numeric([
        ...sequence(samples)
            .map((_) => _numericStatisticGenerator[statistic](sample(length)))
      ]);

  /// A list of histogram bars for this data.
  ///
  /// Example:
  ///
  /// ```dart
  /// for (final bar in iris.nums['petal_length'].histogram(bins: 6)) {
  ///     print(bar);
  /// }
  /// ```
  ///
  /// ```text
  /// Bar from 0.4099999999999999 to 1.5899999999999999: 37.0
  /// Bar from 1.5899999999999999 to 2.7699999999999996: 13.0
  /// Bar from 2.7699999999999996 to 3.95: 11.0
  /// Bar from 3.95 to 5.13: 55.0
  /// Bar from 5.13 to 6.31: 29.0
  /// Bar from 6.31 to 7.49: 5.0
  /// ```
  ///
  List<HistogramBar> histogram(
      {int bins, List<num> breaks, bool density = false}) {
    if (breaks == null) {
      if (bins == null) {
        bins = math.sqrt(length).ceil();
      }
      final from = autoRange.from,
          to = autoRange.to,
          binWidth = (to - from) / bins;
      breaks = [for (final i in sequence(bins + 1)) from + i * binWidth];
    }
    breaks.sort();

    return [
      ...sequence(breaks.length - 1).map((i) => HistogramBar(
          breaks[i],
          breaks[i + 1],
          where((x) => x >= breaks[i] && x < breaks[i + 1]).length /
              (density ? length * (breaks[i + 1] - breaks[i]) : 1)))
    ];
  }

  /// A range containing all the data.
  AutoRange get autoRange => AutoRange.fromNumeric(this);

  /// A rough probability density function.
  num Function(num) density() {
    final from = autoRange.from,
        to = autoRange.to,
        gaps = 100,
        gap = (to - from) / gaps,
        bounds = [for (final i in sequence(gaps + 1)) from + i * gap],
        d = math.sqrt(gaps),
        normalSums = [
      ...bounds.map((bound) =>
          map<num>((x) => Normal.pdf(bound, mean: x, variance: variance / d))
              .fold<num>(0, (a, b) => a + b))
    ],
        trapezoidSum = [
      ...sequence(gaps)
          .map((i) => gap * (normalSums[i] + normalSums[i + 1]) / 2)
    ].fold(0, (a, b) => a + b),
        ys = [...normalSums.map((x) => x / trapezoidSum)];

    return (num x) {
      if (x <= from || x >= to) {
        return 0;
      }

      final c = (x - from) / (to - from) * gaps,
          index = c.floor(),
          part = c - index;

      return part * (ys[index + 1] - ys[index]) + ys[index];
    };
  }

  @override
  get length => _elements.length;

  @override
  num operator [](int index) => _elements[index % length];

  @override
  operator []=(int index, num value) {
    _elements[index % length] = value;
    _statsMemoization.clear();
  }

  @override
  void add(num element) {
    _statsMemoization.clear();
    _elements.add(element);
  }

  @override
  void addAll(Iterable<num> elements) {
    _statsMemoization.clear();
    _elements.addAll(elements);
  }

  @override
  set length(int newLength) {
    _statsMemoization.clear();
    if (_elements.length < length) {
      _elements.length = newLength;
    } else {
      _elements.addAll(List<num>.filled(newLength - length, null));
    }
  }

  @override
  bool remove(element) {
    _statsMemoization.clear();
    return _elements.remove(element);
  }

  @override
  num removeAt(int index) {
    _statsMemoization.clear();
    return _elements.removeAt(index);
  }

  @override
  num removeLast() {
    _statsMemoization.clear();
    return _elements.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    _statsMemoization.clear();
    _elements.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(num) predicate) {
    _statsMemoization.clear();
    _elements.removeWhere(predicate);
  }

  @override
  void retainWhere(bool Function(num) predicate) {
    _statsMemoization.clear();
    _elements.retainWhere(predicate);
  }

  @override
  String toString() => 'Numeric $_elements';

  /// A store for calculated statistics.
  Map<NumericStatistic, num> _statsMemoization = {};

  /// A helper method that looks up, calculates or stores statistics.
  num _statistic(NumericStatistic key, num f(Numeric xs)) =>
      _statsMemoization.containsKey(key)
          ? _statsMemoization[key]
          : _statsMemoization[key] = f(elementsAtIndices(nonNullIndices));
}
