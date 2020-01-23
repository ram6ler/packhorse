part of packhorse;

enum NumericStatistic {
  numberOfInstances,
  sum,
  sumOfSquares,
  mean,
  variance,
  inferredVariance,
  standardDeviation,
  inferredStandardDeviation,
  skewness,
  meanAbsoluteDeviation,
  lowerQuartile,
  median,
  upperQuartile,
  interquartileRange,
  greatest,
  greatestNonOutlier,
  least,
  leastNonOutlier,
  range,
  outliers
}

final _numericStatisticGenerator = <NumericStatistic, num Function(Numeric)>{
  NumericStatistic.numberOfInstances: (x) => x.length,
  NumericStatistic.sum: (x) => x.sum,
  NumericStatistic.sumOfSquares: (x) => x.sumOfSquares,
  NumericStatistic.mean: (x) => x.mean,
  NumericStatistic.variance: (x) => x.variance,
  NumericStatistic.inferredVariance: (x) => x.inferredVariance,
  NumericStatistic.standardDeviation: (x) => x.standardDeviation,
  NumericStatistic.inferredStandardDeviation: (x) =>
      x.inferredStandardDeviation,
  NumericStatistic.meanAbsoluteDeviation: (x) => x.meanAbsoluteDeviation,
  NumericStatistic.least: (x) => x.least,
  NumericStatistic.leastNonOutlier: (x) => x.leastNonOutlier,
  NumericStatistic.lowerQuartile: (x) => x.lowerQuartile,
  NumericStatistic.median: (x) => x.median,
  NumericStatistic.upperQuartile: (x) => x.upperQuartile,
  NumericStatistic.greatestNonOutlier: (x) => x.greatestNonOutlier,
  NumericStatistic.greatest: (x) => x.greatest,
  NumericStatistic.range: (x) => x.range,
  NumericStatistic.interquartileRange: (x) => x.interQuartileRange
};
