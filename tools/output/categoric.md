# Packhorse

[Home](Home.md) | [Numeric](numeric.md) | [Categoric](categoric.md) | [Dataframe](dataframe.md) | [About](about.md)



## Categoric

The `Categoric` class is a convenience wrapper for `List<String>` that represents a column of categoric or qualitative data.

We can access `counts` (and similarly `proportions`):

```dart
final data = Categoric("mississippi".split(""));
data.counts.forEach((letter, count) {
  print("$letter: $count");
});
```

```text
i: 4
m: 1
p: 2
s: 4

```

Other statistics that may be useful are presented as properties:

```dart
final data = Categoric("mississippi".split(""));
print("Gini impurity: ${data.impurity}");
```

```text
Gini impurity: 0.6942148760330579

```





### Not quite a `List<String>`...

Internally the values are stored as integer indices that map to a set of allowed categories, which may be explicitly set.

```dart
var data = Categoric("categoric".split(""));
print("Categories: ${data.categories}");
print("Before: $data");
data.recategorize(["c", "t", "g"]);
print("After: $data");
```

```text
Categories: [a, c, e, g, i, o, r, t]
Before: [c, a, t, e, g, o, r, i, c]
After: [c, null, t, null, g, null, null, null, c]

```

In general we only need to worry about the underlying categories when dealing with two or more `Categoric` instances containing the same categorization.

