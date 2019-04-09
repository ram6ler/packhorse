part of packhorse;

abstract class Statistic {
  static const sum = "sum",
      sumOfSquares = "sumOfSquares",
      mean = "mean",
      variance = "variance",
      inferredVariance = "inferredVariance",
      standardDeviation = "standardDeviation",
      inferredStandardDeviation = "inferredStandardDeviation",
      meanAbsoluteDeviation = "meanAbsoluteDeviation",
      lowerQuartile = "lowerQuartile",
      median = "median",
      upperQuartile = "upperQuartile",
      interquartileRange = "interquartileRange",
      greatest = "greatest",
      greatestNonOutlier = "greatestNonOutlier",
      least = "least",
      leastNonOutlier = "leastNonOutlier",
      range = "range";
}

/// A convenience wrapper class for [List<num>], with
/// properties and methods commonly used in data analysis.
class Numeric extends Column<num> {
  Numeric(Iterable<num> data) {
    _elements = List.from(data);
  }

  /// The [List<num>] wrapped by this numeric.
  List<num> _elements;

  Map<String, num> _statsMemoization = {};

  /// A helper method for defining operations.
  Numeric _operator(Object that, num Function(num, num) f, String name) {
    if (that is num) {
      return Numeric(map((t) => f(t, that)));
    }

    if (that is List && that.first is num) {
      return Numeric(indices.map((i) => f(this[i], that[i])));
    }

    throw Exception("Cannot apply $name to $that.");
  }

  /// Iteratively adds [that] to this numeric.
  ///
  /// If [that] is a num, its value is added to each element;
  /// if it is a List<num>, its values are added to the respective
  /// values in this numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4]);
  /// print(xs + 5);
  /// // [6, 7, 8, 9]
  /// print(xs + [5, 6, 7, 8]);
  /// // [6, 8, 10, 12]
  /// print(xs + xs);
  /// // [2, 4, 6, 8]
  /// ```
  ///
  @override
  Numeric operator +(Object that) =>
      _operator(that, (a, b) => a + b, "addition");

  /// Iteratively subtracts [that] from this numeric.
  ///
  /// If [that] is a num, its value is subtracted from
  /// each element; if it is a List<num>, its values are
  /// subtracted from the respective values in this numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4]);
  /// print(xs - 5);
  /// // -4, -3, -2, -1]
  /// print(xs - [5, 6, 7, 8]);
  /// // [-4, -4, -4, -4]
  /// print(xs - xs);
  /// // [0, 0, 0, 0]
  /// ```
  ///
  Numeric operator -(Object that) =>
      _operator(that, (a, b) => a - b, "subtraction");

  /// Iteratively negates each element in this numeric.
  Numeric operator -() => Numeric(map((x) => x == null ? null : -x));

  /// Iteratively multiplies this numeric by [that].
  ///
  /// If [that] is a num, its value is multiplied by each
  /// element; if it is a List<num>, its values are multiplied
  /// by the respective values in this numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4]);
  /// print(xs * 5);
  /// // [5, 10, 15, 20]
  /// print(xs * [5, 6, 7, 8]);
  /// // [5, 12, 21, 32]
  /// print(xs * xs);
  /// // [1, 4, 9, 16]
  /// ```
  ///
  /// (Use [dot] for dot multiplication.)
  ///
  Numeric operator *(Object that) =>
      _operator(that, (a, b) => a * b, "multiplication");

  /// Iteratively divides this numeric by [that].
  ///
  /// If [that] is a num, each value in this numeric is
  /// divided by it; if it is a List<num>, the values in
  /// this numeric are divided by the respective values
  /// in it.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4]);
  /// print(xs / 5);
  /// // [0.2, 0.4, 0.6, 0.8]
  /// print(xs / [5, 6, 7, 8]);
  /// // [0.2, 0.3333333333333333, 0.42857142857142855, 0.5]
  /// print(xs / xs);
  /// // [1.0, 1.0, 1.0, 1.0]
  /// ```
  ///
  Numeric operator /(Object that) =>
      _operator(that, (a, b) => a / b, "division");

  /// Iteratively performs modular division by [that].
  ///
  /// If [that] is a num, each value in this numeric is
  /// divided by it; if it is a List<num>, the values in
  /// this numeric are divided by the respective values
  /// in it.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([11, 12, 13, 14]);
  /// print(xs % 5);
  /// // [1, 2, 3, 4]
  /// print(xs % [5, 6, 7, 8]);
  /// // [1, 0, 6, 6]
  /// print(xs % xs);
  /// // [0, 0, 0, 0]
  /// ```
  ///
  Numeric operator %(Object that) =>
      _operator(that, (a, b) => a % b, "remainder");

  /// Gives the indices of the elements that meet [predicate].
  ///
  /// Example:
  ///
  /// ```dart
  /// final xs = Numeric([1, 2, 3, 4, 5]);
  /// bool isOdd(x) => x % 2 == 1;
  /// print("Indices of odd values:");
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
  /// print("Elements with odd values:");
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
  Numeric sample(int n, {bool replace: true, int seed}) {
    if (n < 0) {
      throw Exception("Can only take a non negative number of instances.");
    }

    final rand = seed == null ? math.Random() : math.Random(seed);
    if (replace) {
      return Numeric(List<num>.generate(n, (_) => this[rand.nextInt(length)]));
    } else {
      if (n > length) {
        throw Exception(
            "With no replacement, can only take up to $length instances.");
      }
      final shuffledIndices = indices..shuffle(rand);
      return Numeric(shuffledIndices.sublist(0, n).map((i) => this[i]));
    }
  }

  /// The non null (and non [double.nan]) elements in this numeric.
  Numeric get _nullsOmitted =>
      Numeric(where((x) => x != null && x != double.nan));

  /// A helper method that looks up, calculates or stores statistics.
  num _statistic(String key, num f(Iterable<num> xs)) =>
      _statsMemoization.containsKey(key)
          ? _statsMemoization[key]
          : _statsMemoization[key] = f(_nullsOmitted);

  /// The sum of the elements.
  num get sum => _statistic(Statistic.sum, (xs) => xs.fold(0, (a, b) => a + b));

  /// The sum of the squares of the elements.
  num get sumOfSquares => _statistic(Statistic.sumOfSquares,
      (xs) => xs.map((x) => x * x).fold(0, (a, b) => a + b));

  /// The mean of the elements.
  num get mean => _statistic(Statistic.mean, (xs) => sum / xs.length);

  /// The variance of the elements, treating these elements as
  /// the population.
  num get variance => _statistic(
      Statistic.variance,
      (xs) =>
          xs.map((x) => math.pow(x - mean, 2)).fold(0, (a, b) => a + b) /
          xs.length);

  /// The unbiased estimate of the variance of the population
  /// these elements represents a sample of.
  num get inferredVariance => _statistic(Statistic.inferredVariance,
      (xs) => variance * xs.length / (xs.length - 1));

  /// The standard deviation of the elements, treating this
  /// data as the population.
  num get standardDeviation =>
      _statistic(Statistic.standardDeviation, (_) => math.sqrt(variance));

  /// The unbiased estimate of the standard deviation
  /// of the population these elements represents a sample of.
  num get inferredStandardDeviation => _statistic(
      Statistic.inferredStandardDeviation, (_) => math.sqrt(inferredVariance));

  /// The mean absolute deviation from the mean of these elements.
  num get meanAbsoluteDeviation => _statistic(
      Statistic.meanAbsoluteDeviation,
      (xs) =>
          xs.map((x) => (x - mean).abs()).fold(0, (a, b) => a + b) / xs.length);

  /// The lower quartile of these elements, calculated by interpolating the 0.25 quantile.
  num get lowerQuartile =>
      _statistic(Statistic.lowerQuartile, (_) => quantile(0.25));

  /// The median of these elements, calculated by interpolating the 0.5 quantile.
  num get median => _statistic(Statistic.median, (_) => quantile(0.5));

  /// The upper quartile of these elements, calculated by interpolating the 0.75 quantile.
  num get upperQuartile =>
      _statistic(Statistic.upperQuartile, (_) => quantile(0.75));

  /// The interquartile range of these elements.
  num get interquartileRange => _statistic(
      Statistic.interquartileRange, (_) => upperQuartile - lowerQuartile);

  /// The greatest value in these elements.
  num get greatest =>
      _statistic(Statistic.greatest, (xs) => xs.reduce(math.max));

  /// The greatest non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies further than 1.5
  /// interquartile ranges from the nearest interquartile range boundary.)
  ///
  num get greatestNonOutlier => _statistic(
      Statistic.greatestNonOutlier,
      (xs) => xs
          .where((x) => x <= median + 1.5 * interquartileRange)
          .reduce(math.max));

  /// The least value in these elements.
  num get least => _statistic(Statistic.least, (xs) => xs.reduce(math.min));

  /// The least non outlier in these elements.
  ///
  /// (Uses the convention that an outlier is any data point that lies further than 1.5
  /// interquartile ranges from the nearest interquartile range boundary.)
  ///
  num get leastNonOutlier => _statistic(
      Statistic.leastNonOutlier,
      (xs) => xs
          .where((x) => x >= median - 1.5 * interquartileRange)
          .reduce(math.min));

  /// The range of the values of elements in this numeric.
  num get range => _statistic(Statistic.range, (_) => greatest - least);

  /// The p-quantile of the data.
  num quantile(num p) {
    if (p < 0 || p > 1) {
      throw Exception("Proportion should be in range [0, 1].");
    }
    final temp = List.from(_nullsOmitted)..sort(),
        position = p * (temp.length - 1),
        i = position.floor(),
        j = position.ceil(),
        weight = position - i;
    return temp[i] * weight + temp[j] * (1 - weight);
  }

  /// The pth percentile of the data.
  num percentile(num p) {
    if (p < 0 || p > 100) {
      throw Exception("Expecting percent to be in range [0, 100].");
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
  Numeric get residuals => Numeric(map((x) => x - mean));

  /// The squared residuals.
  Numeric get squaredResiduals => Numeric(map((x) => math.pow(x - mean, 2)));

  /// The residuals with respect to the values predicted by model [f].
  Numeric residualsFromModel(num f(num x)) => Numeric(map((x) => x - f(x)));

  /// The squared residuals with respect to the values predicted by model [f].
  Numeric squaredResidualsFromModel(num f(num x)) =>
      Numeric(map((x) => math.pow(x - f(x), 2)));

  /// The indices of all null values or non numbers.
  List<int> get nullIndices => indices
      .where((index) => this[index] == null || this[index] == double.nan)
      .toList();

  /// The counts, by value.
  Map<num, int> get counts => Map<num, int>.fromIterable(toSet(),
      value: (value) => where((x) => x == value).length);

  /// The proportions, by value.
  Map<num, double> get proportions => Map<num, double>.fromIterable(toSet(),
      value: (value) => where((x) => x == value).length / length);

  /// A summary of these elements.
  Map<String, Object> get summary => {
        "Sum": sum,
        "Sum Of Squares": sumOfSquares,
        "Mean": mean,
        "Variance": inferredVariance,
        "Standard Deviation": inferredStandardDeviation,
        "Median": median,
        "Lower Quartile": lowerQuartile,
        "Upper Quartile": upperQuartile,
        "Least Non Outlier": leastNonOutlier,
        "Greatest Non Outlier": greatestNonOutlier,
        "Least": least,
        "Greatest": greatest,
        "Outliers": outliers
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
      throw Exception("Dot product requires lengths to be the same.");
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

  /// Gives a least-squares linear predictor of [that].
  ///
  /// Returns a map containing the *gradient*, *intercept* and callable *model* of
  /// a linear least squares regression function.
  ///
  /// Example:
  ///
  /// ```dart
  /// final rand = math.Random(0),
  ///   points = 20,
  ///   trueGradient = 2,
  ///   trueIntercept = 1,
  ///   trueModel = (num x) => trueGradient * x + trueIntercept,
  ///   noise = () => rand.nextDouble() * 2 - 1,
  ///   xs = Numeric(List<num>.generate(points, (_) => rand.nextDouble() * 10)),
  ///   ys = Numeric(xs.map((x) => trueModel(x) + noise())),
  ///   f = xs.leastSquaresLinearPredictorOf(ys);
  ///
  /// print("True gradient: $trueGradient; model: ${f["gradient"]}");
  /// // True gradient: 2; model: 2.049357033271854
  /// print("True intercept: $trueIntercept; model: ${f["intercept"]}");
  /// // True intercept: 1; model: 0.636168176423368
  /// print(
  ///   "Example x: ${xs.first}, y: ${ys.first}, predicted: ${f["model"](xs.first)}");
  /// // Example x: 8.255140718871703, y: 16.975375781784862, predicted: 17.55389886929196
  /// ```
  ///
  Map<String, dynamic> leastSquaresLinearPredictorOf(List<num> that) {
    final thatVector = Numeric(that),
        a = correlationWith(thatVector) *
            thatVector.standardDeviation /
            standardDeviation,
        b = thatVector.mean - a * mean;

    return {"model": (num x) => a * x + b, "gradient": a, "intercept": b};
  }

  num bootStrapStandardError(String statistic, {int n: 1000, int seed}) {
    final f = <String, Function(Numeric)>{
      Statistic.sum: (x) => x.sum,
      Statistic.sumOfSquares: (x) => x.sumOfSquares,
      Statistic.mean: (x) => x.mean,
      Statistic.variance: (x) => x.variance,
      Statistic.inferredVariance: (x) => x.inferredVariance,
      Statistic.standardDeviation: (x) => x.standardDeviation,
      Statistic.inferredStandardDeviation: (x) => x.inferredStandardDeviation,
      Statistic.meanAbsoluteDeviation: (x) => x.meanAbsoluteDeviation,
      Statistic.lowerQuartile: (x) => x.lowerQuartile,
      Statistic.median: (x) => x.median,
      Statistic.upperQuartile: (x) => x.upperQuartile,
      Statistic.interquartileRange: (x) => x.interquartileRange,
      Statistic.greatest: (x) => x.greatest,
      Statistic.greatestNonOutlier: (x) => x.greatestNonOutlier,
      Statistic.least: (x) => x.least,
      Statistic.leastNonOutlier: (x) => x.leastNonOutlier,
      Statistic.range: (x) => x.range,
    }[statistic];
    return Numeric(List<num>.generate(n, (_) => f(sample(length))))
        .inferredStandardDeviation;
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
