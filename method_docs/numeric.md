

A convenience wrapper class for [List<num>], with
properties and methods commonly used in data analysis.





The [List<num>] wrapped by this numeric.


A helper method for defining operations.















Iteratively adds `that` to this numeric.

If `that` is a num, its value is added to each element;
if it is a list, its values are added to the respective
values in this numeric.

```dart
final numeric = Numeric([1, 2, 3]);

print(numeric + Numeric([10, 11, 12]));
print(numeric + [10, 11, 12]);
print(numeric + 10);
```

```text
Numeric [11, 13, 15]
Numeric [11, 13, 15]
Numeric [11, 12, 13]
```





Iteratively subtracts `that` from this numeric.

If `that` is a num, its value is subtracted from each element;
if it is a list, its values are subtracted the respective
values in this numeric.

```dart
final numeric = Numeric([1, 2, 3]);

print(numeric - Numeric([10, 11, 12]));
print(numeric - [10, 11, 12]);
print(numeric - 10);
```

```text
Numeric [-9, -9, -9]
Numeric [-9, -9, -9]
Numeric [-9, -8, -7]
```




Returns an iterative negation of the data in this numeric.

```dart
final numeric = Numeric([1, 2, 3]);
print(-numeric);
```

```text
Numeric [-1, -2, -3]
```



Iteratively multiplies this numeric by `that`.

If `that` is a num, each element is multiplied by it;
if it is a list, each value is multiplied by each respective
value in it. (Use `dot` for dot multiplication).

```dart
final numeric = Numeric([1, 2, 3]);

print(numeric * Numeric([10, 11, 12]));
print(numeric * [10, 11, 12]);
print(numeric * 10);
```

```text
Numeric [10, 22, 36]
Numeric [10, 22, 36]
Numeric [10, 20, 30]
```




Iteratively divides this numeric by `that`.

If `that` is a num, each element is divided by it;
if it is a list, each value is divided by each respective
value in it.

```dart
final numeric = Numeric([1, 2, 3]);

print(numeric / Numeric([10, 11, 12]));
print(numeric / [10, 11, 12]);
print(numeric / 10);
```

```text
Numeric [0.1, 0.18181818181818182, 0.25]
Numeric [0.1, 0.18181818181818182, 0.25]
Numeric [0.1, 0.2, 0.3]
```




Iteratively performs modular division of this numeric by `that`.

If `that` is a num, each element is divided by it;
if it is a list, each value is divided by each respective
value in it.

```dart
final numeric = Numeric([10, 11, 12]);

print(numeric % Numeric([1, 2, 3]));
print(numeric % [1, 2, 3]);
print(numeric % 3);
```

```text
Numeric [0, 1, 0]
Numeric [0, 1, 0]
Numeric [1, 2, 0]
```




Iteratively performs whole division of this numeric by `that`.

If `that` is a num, each element is divided by it;
if it is a list, each value is divided by each respective
value in it.

```dart
final numeric = Numeric([10, 11, 12]);

print(numeric ~/ Numeric([1, 2, 3]));
print(numeric ~/ [1, 2, 3]);
print(numeric ~/ 3);
```

```text
Numeric [10, 5, 4]
Numeric [10, 5, 4]
Numeric [3, 3, 4]
```
















Returns the indices of the elements that meet a predicate.

(Use `elementsWhere` to get the elements that meet a predicate.)

Example:

```dart
final xs = Numeric([5, 12, 3, 2, 5, 6, 11]);
bool isOdd(x) => x % 2 == 1;
print(xs.indicesWhere(isOdd));
```

```text
[0, 2, 4, 6]
```




Returns the elements that meet a predicate.

This is similar to `where` but returns a numeric.

(Use `indicesWhere` to get the indices of elements that meet a predicate.)

Example:

```dart
final xs = Numeric([5, 12, 3, 2, 5, 6, 11]);
bool isOdd(x) => x % 2 == 1;
print(xs.elementsWhere(isOdd));
print(xs.where(isOdd));
```

```text
Numeric [5, 3, 5, 11]
(5, 3, 5, 11)
```




Returns the elements at specified indices.

Example:

```dart
final xs = Numeric([1, 2, 3, 4, 5]);
print(xs.elementsAtIndices([0, 0, 0, 2, 2, 2]));
```

```text
Numeric [1, 1, 1, 3, 3, 3]
```





Returns a random sample of `n` elements as a numeric.

Optionally set the `seed` to reproduce the results. To draw a
sample without replacement, set `withReplacement` to `false`.

Example:

```dart
for (final length in iris.nums['petal_length'].sample(5, seed: 0)) {
print(length);
}
```

```text
6.6
3.9
3.6
1.4
1.4
```



















The non null (and non [double.nan]) elements in this numeric.



The sum of the elements.

Example:

```dart
print(iris.nums['petal_length'].sum);
```




The sum of the squares of the elements.

Example:

```dart
print(iris.nums['petal_length'].sumOfSquares);
```

```text
2582.7100000000005
```




The mean of the elements.

Example:

```dart
print(iris.nums['petal_length'].mean);
```

```text
3.7580000000000027
```



The variance of the elements, treating these elements as
the population.

Example:

```dart
print(iris.nums['petal_length'].variance);
```

```text
3.0955026666666674
```







The unbiased estimate of the variance of the population
these elements represent a sample of.

Example:

```dart
print(iris.nums['petal_length'].inferredVariance);
```

```text
3.1162778523489942
```




The standard deviation of the elements, treating this
data as the population.

Example:

```dart
print(iris.nums['petal_length'].standardDeviation);
```

```text
1.7594040657753032
```




The unbiased estimate of the standard deviation
of the population these elements represent a sample of.

Example:

```dart
print(iris.nums['petal_length'].inferredStandardDeviation);
```

```text
1.7652982332594667
```





The unbiased estimate of the skewness of the population
these elements represent a sample of.

Example:

```dart
print(iris.nums['petal_length'].skewness);
```

```text
-0.27121905735433716
```









The mean absolute deviation from the mean of these elements.

Example:

```dart
print(iris.nums['petal_length'].meanAbsoluteDeviation);
```

```text
1.5627466666666645
```






The lower quartile of these elements.

Example:

```dart
print(iris.nums['petal_length'].lowerQuartile);
```

```text
1.3250000000000002
```




The median of these elements.

Example:

```dart
print(iris.nums['petal_length'].median);
```

```text
4.35
```



The upper quartile of these elements.

Example:

```dart
print(iris.nums['petal_length'].upperQuartile);
```

```text
5.35
```




The inter-quartile range of these elements.

Example:

```dart
print(iris.nums['petal_length'].interQuartileRange);
```

```text
4.0249999999999995
```




The greatest value in these elements.

Example:

```dart
print(iris.nums['petal_length'].greatest);
```

```text
6.9
```




The index of the greatest value in these elements.

Example:

```dart
print(iris.nums['petal_length'].indexOfGreatest);
```

```text
118
```



The greatest non outlier in these elements.

(Uses the convention that an outlier is any data point that lies
further than 1.5 inter-quartile ranges from the nearest inter-quartile
range boundary.)

Example:

```dart
print(iris.nums['petal_length'].greatestNonOutlier);
```

```text
6.9
```







The least value in these elements.

Example:

```dart
print(iris.nums['petal_length'].least);
```

```text
1.0
```




The index of the least value in these elements.

Example:

```dart
print(iris.nums['petal_length'].indexOfLeast);
```

```text
22
```



The least non outlier in these elements.

(Uses the convention that an outlier is any data point that lies
further than 1.5 interquartile ranges from the nearest interquartile
range boundary.)

Example:

```dart
print(iris.nums['petal_length'].leastNonOutlier);
```

```text
1.0
```







The range of the values of elements in this numeric.

Example:

```dart
print(iris.nums['petal_length'].range);
```

```text
5.9
```



Helper to generate a quantile.








The interpolated p-quantile of the data, with `p` in the range `[0, 1]`.

Example:

```dart
print(iris.nums['petal_length'].quantile(0.99));
```

```text
5.298000000000002
```









Interpolated p-quantiles of the data.

Example:

```dart
for (final quantile in iris.nums['petal_length'].quantiles(
[0, 0.2, 0.4, 0.6, 0.8, 1])) {
print(quantile.toStringAsFixed(3));
}
```

```text
1.400
1.600
3.740
4.240
5.560
5.100
```











The pth percentile of the data, with `p` in the range `[0, 100]`.

Example:

```dart
print(iris.nums['petal_length'].percentile(99).toStringAsFixed(3));
```

```text
5.298
```








The outliers in these elements.

(Uses the convention that an outlier is any data point that lies
further than 1.5 inter-quartile ranges from the nearest inter-quartile
range boundary.)

Example:

```dart
for (final outlier in iris.nums['sepal_width'].outliers.take(5)) {
print(outlier);
}
```

```text
3.5
3.0
3.2
3.1
3.6
```




The cumulative relative frequency associated with these elements.

Example:

```dart
for (final pScore in sepals.nums['sepal_length'].pScores.take(5)) {
print(pScore.toStringAsFixed(3));
}
```

```text
0.125
0.042
0.208
0.292
0.792
```




The theoretical cumulative relative frequency associated with
these elements under the hypothesis of normal distribution.

Example:

```dart
for (final pScore in sepals.nums['sepal_length'].pScoresIfNormal.take(5)) {
print(pScore.toStringAsFixed(3));
}
```

```text
0.095
0.079
0.157
0.275
0.826
```




The z-scores, treating the data in this numeric as a population.

Example:

```dart
for (final z in sepals.nums['sepal_length'].zScores.take(5)) {
print(z.toStringAsFixed(2));
}
```

```text
-1.37
-1.48
-1.05
-0.62
0.98
```




The z-scores, relative to the population this numeric is treated as a sample from.

Example:

```dart
for (final z in sepals.nums['sepal_length'].inferredZScores.take(5)) {
print(z.toStringAsFixed(2));
}
```

```text
-1.31
-1.41
-1.01
-0.60
0.94
```





The z-scores, calculated from specified mean and standard deviation.

Example:

```dart
for (final z in sepals.nums['sepal_length']
.standardizedZScores(5.0, 2.5).take(5)) {
print(z.toStringAsFixed(2));
}
```

```text
-0.12
-0.16
0.00
0.16
0.76
```




The residuals, or differences from the mean.

Example:

```dart
for (final r in sepals.nums['sepal_length'].residuals.take(5)) {
print(r.toStringAsFixed(2));
}
```

```text
-1.28
-1.38
-0.98
-0.58
0.92
```




The squared residuals.

Example:

```dart
for (final r in sepals.nums['sepal_length'].squaredResiduals.take(5)) {
print(r.toStringAsFixed(2));
}
```

```text
1.65
1.91
0.97
0.34
0.84
```



The counts, by value.

Example:

```dart
sepals.nums['sepal_width'].counts.forEach((value, count) {
print('$value: $count');
});
```

```text
3.2: 1
3.1: 2
3.6: 1
3.9: 1
2.3: 1
2.8: 2
3.0: 3
2.9: 1
```




The proportions, by value.

Example:

```dart
sepals.nums['sepal_width'].proportions.forEach((value, proportion) {
print('$value: ${proportion.toStringAsFixed(3)}');
});
```

```text
3.2: 0.083
3.1: 0.167
3.6: 0.083
3.9: 0.083
2.3: 0.083
2.8: 0.167
3.0: 0.250
2.9: 0.083
```





A summary of the statistics.






The dot product with Numeric that.

Example:

```dart
final lengths = iris.nums['petal_length'], widths = iris.nums['petal_width'];
print(lengths.dot(widths));
```

```text
869.25
```














The Pearson correlation between the data in this and that column.

Example:

```dart
final lengths = iris.nums['petal_length'],
widths = iris.nums['petal_width'];

print(lengths.correlation(widths));
```

```text
0.9627460246236469
```






Returns a sample of measures for a specified statistic reaped
from bootstrapping on these elements.

Example:

```dart
for (final mean in iris.nums['petal_length'].bootstrapSampled(
NumericStatistic.mean, samples: 10)) {
print(mean.toStringAsFixed(2));
}
```

```text
3.77
3.81
3.98
3.58
3.63
3.56
3.70
3.70
3.69
3.77
```








A list of histogram bars for this data.

Example:

```dart
for (final bar in iris.nums['petal_length'].histogram(bins: 6)) {
print(bar);
}
```

```text
Bar from 0.4099999999999999 to 1.5899999999999999: 37.0
Bar from 1.5899999999999999 to 2.7699999999999996: 13.0
Bar from 2.7699999999999996 to 3.95: 11.0
Bar from 3.95 to 5.13: 55.0
Bar from 5.13 to 6.31: 29.0
Bar from 6.31 to 7.49: 5.0
```























A range containing all the data.


A rough probability density function.








































































































A store for calculated staistics.


A helper method that looks up, calculates or stores statistics.





