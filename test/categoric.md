

The internal list of categories in this categoric.

The list of categories in this categoric.

The internal data, as indices in [_categories].

The internal data, as indices in [categories].

Redefines the categories.

(Values that do not lie in the new category definition will be lost.)

Adds categories to the existing categories.

Returns a random sample of `n` elements as a numeric.

Optionally set the `seed` to reproduce the results. To draw a
sample without replacement, set `withReplacement` to `false`.

Example:

```dart
for (final species in iris.cats['species'].sample(5)) {
    print(species);
}
```

```text
virginica
versicolor
versicolor
virginica
virginica
```

The counts, by category.

Example:

```dart
iris.cats['species'].counts.forEach((species, count) {
   print('$species: $count');
});

```

```text
setosa: 50
versicolor: 50
virginica: 50
```

# `proportions`

The proportions, by category.

Example:

```dart
iris.cats['species'].proportions.forEach((species, proportion) {
   print('$species: $proportion');
});

```

```text
setosa: 0.3333333333333333
versicolor: 0.3333333333333333
virginica: 0.3333333333333333
```

Returns the indices of elements that match a specified predicate.

(Use `elementsWhere` to get elements that match a predicate.)

Example:

```dart
for (final index in iris.cats['species'].indicesWhere(
    (species) => species.contains('color')).take(5)) {
        print(index);
    }
```

```text
50
51
52
53
54
```

Returns the elements at the specified indices.

Example:

```dart
for (final species in iris.cats['species'].elementsAtIndices([0, 50, 100])) {
    print(species);
}
```

```text
setosa
versicolor
virginica
```

Returns the elements that match a predicate.

This is similar to 'where' but, whereas 'where' returns an iterable, 'elementsWhere' returns a categoric.

(Use `indicesWhere` to get the indices of the elements.)

Example:

```dart
for (final element in iris.cats['species'].elementsWhere(
    (species) => species.contains('color')).take(5)) {
        print(element);
    }
```

```text
versicolor
versicolor
versicolor
versicolor
versicolor
```

The Gini impurity.

Example:

```dart
print(iris.cats['species'].impurity);
```

```text
0.6666666666666667
```

The entropy (in nats).

Example:

```dart
print(iris.cats['species'].entropy);
```

```text
1.0986122886681096
```

A summary of the stistics associated with this data.

Returns a sample of measures for a specified statistic reaped
from bootstrapping on these elements.

Example:

```dart
for (final entropy in iris.cats['species'].bootstrapSampled(
  CategoricStatistic.entropy, samples: 10)) {
    print(entropy.toStringAsFixed(4));
}
```

```text
1.0948
1.0938
1.0895
1.0949
1.0878
1.0938
1.0985
1.0949
1.0938
1.0860
```

A store for calculated statistics.

A helper method that looks up, calculates or stores statistics.

