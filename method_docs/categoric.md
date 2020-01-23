The internal list of categories in this categoric.
The list of categories in this categoric.
The internal data, as indices in `_categories`.
The internal data, as indices in `categories`.
Redefines the categories.

(Values that do not lie in the new category definition will be lost.)
Adds categories to the existing categories.
The counts, by category.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
colors.counts.forEach((color, count) {
print('$color: $count');
});

```

The proportions, by category.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
colors.proportions.forEach((color, p) {
print('$color: ${p.toStringAsFixed(2)}');
});

```

The frequencies, by category.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
colors.proportions.forEach((color, f) {
print('$color: $f');
});



```

Gets the indices where `predicate` holds.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
print(colors.indicesWhere((color) => color.contains('re')));

```

Gets the elements at the specified indices.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
print(colors.elementsAtIndices([4, 4, 5, 5, 0]));

```
(Compare `elementsWhere`.)

Gets the elements that match `predicate`.

This is similar to `where` (which also works on this categoric) but, whereas
`where` only returns an iterable, `elementsWhere` returns a categoric.

Example:

```dart
final colors = Categoric(['red', 'red', 'green', 'red', 'blue', 'green']);
print(colors.elementsWhere((color) => color.contains('re')));

print(colors.where((color) => color.contains('re')));

```

(Compare `indicesWhere`.)

The Gini impurity.
The entropy (in nats).
