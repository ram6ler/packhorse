part of packhorse;

/// A convenience wrapper class for [List<num>], with
/// properties and methods commonly used in data analysis.
class Numeric extends Column<num> {
  Numeric(Iterable<num> data) {
    _elements = List.from(data);
  }

  /// The [List<num>] wrapped by this numeric.
  List<num> _elements;

  /// A helper method for defining operations.
  Numeric _operator(Object that, num Function(num, num) f, String name) {
    if (that is num) {
      return Numeric(map((t) => f(t, that)));
    }

    if (that is List && that.first is num) {
      return Numeric(indices.map((i) => f(this[i], that[i])));
    }

    throw Exception('Cannot apply $name to $that.');
  }

  /// Iteratively adds [that] to this numeric.
  ///
  /// If [that] is a num, its value is added to each element;
  /// if it is a List<num>, its values are added to the respective
  /// values in this numeric.
  ///
  ///
  @override
  Numeric operator +(Object that) =>
      _operator(that, (a, b) => a + b, 'addition');

  /// Iteratively subtracts [that] from this numeric.
  ///
  /// If [that] is a num, its value is subtracted from
  /// each element; if it is a List<num>, its values are
  /// subtracted from the respective values in this numeric.
  ///
  Numeric operator -(Object that) =>
      _operator(that, (a, b) => a - b, 'subtraction');

  /// Iteratively negates each element in this numeric.
  Numeric operator -() => Numeric(map((x) => x == null ? null : -x));

  /// Iteratively multiplies this numeric by [that].
  ///
  /// If [that] is a num, its value is multiplied by each
  /// element; if it is a List<num>, its values are multiplied
  /// by the respective values in this numeric.
  ///
  Numeric operator *(Object that) =>
      _operator(that, (a, b) => a * b, 'multiplication');

  /// Iteratively divides this numeric by [that].
  ///
  /// If [that] is a num, each value in this numeric is
  /// divided by it; if it is a List<num>, the values in
  /// this numeric are divided by the respective values
  /// in it.
  ///
  Numeric operator /(Object that) =>
      _operator(that, (a, b) => a / b, 'division');

  /// Iteratively performs modular division by [that].
  ///
  /// If [that] is a num, each value in this numeric is
  /// divided by it; if it is a List<num>, the values in
  /// this numeric are divided by the respective values
  /// in it.
  ///
  Numeric operator %(Object that) =>
      _operator(that, (a, b) => a % b, 'remainder');

  /// Iteratively performs whole division by [that].
  ///
  /// If [that] is a num, each value in this numeric is
  /// divided by it; if it is a List<num>, the values in
  /// this numeric are divided by the respective values
  /// in it.
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

  /// Gives the indices of the elements that meet [predicate].
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// bool isOdd(x) => x % 2 == 1;
  /// print('Indices of odd values:');
  /// print(xs.indicesWhere(isOdd));
  /// // [0, 2, 4]
  /// ```
  ///
  /// (Compare [elementsWhere].)
  ///
  List<int> indicesWhere(bool Function(num) predicate) =>
      indices.where((i) => predicate(this[i])).toList();

  /// Gives the elements that meet [predicate].
  ///
  /// This is similar to [where] (which also works on this numeric) but, whereas
  /// [where] only returns an iterable, returns a categoric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// bool isOdd(x) => x % 2 == 1;
  /// print('Elements with odd values:');
  /// print(xs.elementsWhere(isOdd));
  /// // [1, 3, 5]
  /// print(xs.where(isOdd));
  /// // (1, 3, 5)
  /// ```
  ///
  /// (Compare [indicesWhere].)
  ///
  Numeric elementsWhere(bool Function(num) predicate) =>
      Numeric(where(predicate).toList());

  /// Gives the elements at specified indices.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// print(xs.elementsAtIndices([0, 0, 0, 2, 2, 2]));
  /// // [1, 1, 1, 3, 3, 3]
  /// ```
  ///
  @override
  Numeric elementsAtIndices(List<int> indices) =>
      Numeric(indices.map((i) => this[i]).toList());

  /// Takes a random sample of [n] elements.
  ///
  /// Optionally set the seed to reproduce the results.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// print(xs.sample(10, seed: 0));
  /// // [1, 5, 5, 5, 2, 2, 5, 2, 2, 5]
  /// ```
  ///
  Numeric sample(int n, {bool replace = true, int seed}) {
    if (n < 0) {
      throw Exception('Can only take a non negative number of instances.');
    }

    final rand = seed == null ? math.Random() : math.Random(seed);
    if (replace) {
      return Numeric(List<num>.generate(n, (_) => this[rand.nextInt(length)]));
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
  num get sum =>
      _statistic(NumericStatistic.sum, (xs) => xs.fold(0, (a, b) => a + b));

  /// The sum of the squares of the elements.
  num get sumOfSquares => _statistic(NumericStatistic.sumOfSquares,
      (xs) => xs.map((x) => x * x).fold(0, (a, b) => a + b));

  /// The mean of the elements.
  num get mean => _statistic(NumericStatistic.mean, (xs) => sum / xs.length);

  /// The variance of the elements, treating these elements as
  /// the population.
  num get variance => _statistic(
      NumericStatistic.variance,
      (xs) =>
          xs.map((x) => math.pow(x - mean, 2)).fold(0, (a, b) => a + b) /
          xs.length);

  /// The unbiased estimate of the variance of the population
  /// these elements represent a sample of.
  num get inferredVariance => _statistic(NumericStatistic.inferredVariance,
      (xs) => variance * xs.length / (xs.length - 1));

  /// The standard deviation of the elements, treating this
  /// data as the population.
  num get standardDeviation => _statistic(
      NumericStatistic.standardDeviation, (_) => math.sqrt(variance));

  /// The unbiased estimate of the standard deviation
  /// of the population these elements represent a sample of.
  num get inferredStandardDeviation => _statistic(
      NumericStatistic.inferredStandardDeviation,
      (_) => math.sqrt(inferredVariance));

  /// The unbiased estimate of the skewness of the population
  /// these elements represent a sample of.
  num get skewness => _statistic(NumericStatistic.skewness, (_) {
        final cubedResiduals =
                residuals.map((residual) => math.pow(residual, 3)),
            cubedResidualsMean = cubedResiduals.fold(0, (a, b) => a + b) /
                (cubedResiduals.length - 1);
        return cubedResidualsMean / math.pow(inferredVariance, 1.5);
      });

  /// The mean absolute deviation from the mean of these elements.
  num get meanAbsoluteDeviation => _statistic(
      NumericStatistic.meanAbsoluteDeviation,
      (xs) =>
          xs.map((x) => (x - mean).abs()).fold(0, (a, b) => a + b) / xs.length);

  /// The lower quartile of these elements, calculated by interpolating the 0.25 quantile.
  num get lowerQuartile =>
      _statistic(NumericStatistic.lowerQuartile, (_) => quantile(0.25));

  /// The median of these elements, calculated by interpolating the 0.5 quantile.
  num get median => _statistic(NumericStatistic.median, (_) => quantile(0.5));

  /// The upper quartile of these elements, calculated by interpolating the 0.75 quantile.
  num get upperQuartile =>
      _statistic(NumericStatistic.upperQuartile, (_) => quantile(0.75));

  /// The interquartile range of these elements.
  num get interquartileRange => _statistic(NumericStatistic.interquartileRange,
      (_) => upperQuartile - lowerQuartile);

  /// The greatest value in these elements.
  num get greatest =>
      _statistic(NumericStatistic.greatest, (xs) => xs.reduce(math.max));

  /// The index of the greatest value in these elements.
  int get greatestIndex => indexOf(greatest);

  /// The greatest non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies further than 1.5
  /// interquartile ranges from the nearest interquartile range boundary.)
  ///
  num get greatestNonOutlier => _statistic(
      NumericStatistic.greatestNonOutlier,
      (xs) => xs
          .where((x) => x <= median + 1.5 * interquartileRange)
          .reduce(math.max));

  /// The least value in these elements.
  num get least =>
      _statistic(NumericStatistic.least, (xs) => xs.reduce(math.min));

  /// The index of the least value in these elements.
  int get leastIndex => indexOf(least);

  /// The least non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies further than 1.5
  /// interquartile ranges from the nearest interquartile range boundary.)
  ///
  num get leastNonOutlier => _statistic(
      NumericStatistic.leastNonOutlier,
      (xs) => xs
          .where((x) => x >= median - 1.5 * interquartileRange)
          .reduce(math.min));

  /// The range of the values of elements in this numeric.
  num get range => _statistic(NumericStatistic.range, (_) => greatest - least);

  Numeric _quantiles(List<num> ps, Numeric ordered) => Numeric(ps.map((p) {
        final position = p * (ordered.length - 1),
            i = position.floor(),
            j = position.ceil(),
            weight = position - i;
        return ordered[i] * weight + ordered[j] * (1 - weight);
      }));

  /// The interpolated p-quantile of the data.
  num quantile(num p) {
    if (p < 0 || p > 1) {
      throw Exception('Proportion should be in range [0, 1].');
    }
    return _quantiles([p], _nullsOmitted..sort()).first;
  }

  /// The interpolated p-quantiles of the data.
  Numeric quantiles(List<num> ps) {
    if (ps.any((p) => p < 0 || p > 1)) {
      throw Exception('Proportion should be in range [0, 1].');
    }
    return _quantiles(ps, _nullsOmitted..sort());
  }

  /// The pth percentile of the data.
  num percentile(num p) {
    if (p < 0 || p > 100) {
      throw Exception('Expecting percent to be in range [0, 100].');
    }
    return quantile(p / 100);
  }

  /// The outliers in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies further than 1.5
  /// interquartile ranges from the nearest interquartile range boundary.)
  ///
  Numeric get outliers => Numeric(_nullsOmitted
      .where((x) => x < leastNonOutlier || x > greatestNonOutlier));

  /// The cumulative relative frequency associated with these elements.
  Numeric get pScores => Numeric(indices.map((i) => (i + 0.5) / length))
      .elementsAtIndices(indexOrders);

  /// The theoretical cumulative relative frequency associated with
  /// these elements under the hypothesis of normal distribution.
  Numeric get pScoresIfNormal => Numeric(
      map((x) => Normal.cdf(x, mean: mean, variance: inferredVariance)));

  /// The z-scores, treating the data in this numeric as a population.
  Numeric get zScores => Numeric(map((x) =>
      x == null || x == double.nan ? null : (x - mean) / standardDeviation));

  /// The z-scores, relative to the population this numeric is treated as a sample from.
  Numeric get inferredZScores => Numeric(map((x) => x == null || x == double.nan
      ? null
      : (x - mean) / inferredStandardDeviation));

  /// The z-scores, calculated from a provided mean [mu] and standard deviation [sigma].
  Numeric standardizedZScores(num mu, num sigma) => Numeric(
      map((x) => x == null || x == double.nan ? null : (x - mu) / sigma));

  /// The residuals.
  Numeric get residuals =>
      Numeric(where((x) => x != null && x != double.nan).map((x) => x - mean));

  /// The squared residuals.
  Numeric get squaredResiduals => Numeric(map((x) => math.pow(x - mean, 2)));

  /// The residuals with respect to the values predicted by model [f].
  Numeric residualsFromModel(num f(num x)) => Numeric(map((x) => x - f(x)));

  /// The squared residuals with respect to the values predicted by model [f].
  Numeric squaredResidualsFromModel(num f(num x)) =>
      Numeric(map((x) => math.pow(x - f(x), 2)));

  /// The counts, by value.
  Map<num, int> get counts => Map<num, int>.fromIterable(toSet(),
      value: (value) => where((x) => x == value).length);

  /// The proportions, by value.
  Map<num, double> get proportions => Map<num, double>.fromIterable(toSet(),
      value: (value) => where((x) => x == value).length / length);

  @override
  Map<String, Object> get summary => {
        NumericStatistic.numberOfInstances: length,
        NumericStatistic.sum: sum,
        NumericStatistic.sumOfSquares: sumOfSquares,
        NumericStatistic.mean: mean,
        NumericStatistic.variance: variance,
        NumericStatistic.inferredVariance: inferredVariance,
        NumericStatistic.standardDeviation: standardDeviation,
        NumericStatistic.inferredStandardDeviation: inferredStandardDeviation,
        NumericStatistic.median: median,
        NumericStatistic.lowerQuartile: lowerQuartile,
        NumericStatistic.upperQuartile: upperQuartile,
        NumericStatistic.leastNonOutlier: leastNonOutlier,
        NumericStatistic.greatestNonOutlier: greatestNonOutlier,
        NumericStatistic.least: least,
        NumericStatistic.greatest: greatest,
        NumericStatistic.outliers: outliers
      };

  /// The dot product with Numeric that.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]), ys = Numeric([1, 0, 2, 0, 3]);
  /// print(xs.dot(ys));
  /// // 22
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
  /// final xs = Numeric([1, 2, 3, 4, 5]), ys = Numeric([1, 0, 2, 0, 3]);
  /// print(xs.correlationWith(ys));
  /// // 0.4850712500726658
  /// ```
  ///
  num correlationWith(List<num> that) {
    final thatVector = Numeric(that), thoseZScores = thatVector.zScores;
    return zScores.dot(thoseZScores) / length;
  }

  // TODO:
  num bootStrap(String statistic, {int n = 1000, int seed}) {
    final f = <String, Function(Numeric)>{
      NumericStatistic.sum: (x) => x.sum,
      NumericStatistic.sumOfSquares: (x) => x.sumOfSquares,
      NumericStatistic.mean: (x) => x.mean,
      NumericStatistic.variance: (x) => x.variance,
      NumericStatistic.inferredVariance: (x) => x.inferredVariance,
      NumericStatistic.standardDeviation: (x) => x.standardDeviation,
      NumericStatistic.inferredStandardDeviation: (x) =>
          x.inferredStandardDeviation,
      NumericStatistic.meanAbsoluteDeviation: (x) => x.meanAbsoluteDeviation,
      NumericStatistic.lowerQuartile: (x) => x.lowerQuartile,
      NumericStatistic.median: (x) => x.median,
      NumericStatistic.upperQuartile: (x) => x.upperQuartile,
      NumericStatistic.interquartileRange: (x) => x.interquartileRange,
      NumericStatistic.greatest: (x) => x.greatest,
      NumericStatistic.greatestNonOutlier: (x) => x.greatestNonOutlier,
      NumericStatistic.least: (x) => x.least,
      NumericStatistic.leastNonOutlier: (x) => x.leastNonOutlier,
      NumericStatistic.range: (x) => x.range,
    }[statistic];
    return Numeric(List<num>.generate(n, (_) => f(sample(length))))
        .inferredStandardDeviation;
  }

  /// A list of histogram bars for this data.
  List<HistogramBar> histogram(
      {int bins, List<num> breaks, bool density = false}) {
    if (breaks == null) {
      if (bins == null) {
        bins = math.sqrt(length).ceil();
      }
      final from = autoRange.from,
          to = autoRange.to,
          binWidth = (to - from) / bins;
      breaks = List<num>.generate(bins + 1, (i) => from + i * binWidth);
    }
    breaks.sort();
    return sequence(breaks.length - 1)
        .map((i) => HistogramBar(
            breaks[i],
            breaks[i + 1],
            where((x) => x >= breaks[i] && x < breaks[i + 1]).length /
                (density ? length * (breaks[i + 1] - breaks[i]) : 1)))
        .toList();
  }

  /// A range containing all the data.
  AutoRange get autoRange => AutoRange.fromNumeric(this);

  /// A rough estimate of the generating probability density function.
  num Function(num) density() {
    final from = autoRange.from,
        to = autoRange.to,
        gaps = 100,
        gap = (to - from) / gaps,
        bounds = List<num>.generate(gaps + 1, (i) => from + i * gap),
        d = math.sqrt(gaps),
        normalSums = bounds
            .map((bound) =>
                map((x) => Normal.pdf(bound, mean: x, variance: variance / d))
                    .fold(0, (a, b) => a + b))
            .toList(),
        trapezoidSum = sequence(gaps)
            .map((i) => gap * (normalSums[i] + normalSums[i + 1]) / 2)
            .fold(0, (a, b) => a + b),
        ys = normalSums.map((x) => x / trapezoidSum).toList();

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
}
