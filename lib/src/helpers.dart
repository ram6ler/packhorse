part of packhorse;

List<int> sequence(int n) => List<int>.generate(n, (index) => index);

/// Checks that variable names are compatable with package FunctionTree.
void _checkVariableName(String variable) {
  if (variable.isEmpty) {
    throw Exception("Column name missing.");
  }
  if (variable.contains(" ")) {
    throw Exception(
        "Column name contains spaces: '$variable'. (Use _ instead.)");
  }
  if ("0123456789_".contains(variable[0])) {
    throw Exception(
        "Column name should not start with a number or underscore: '$variable'");
  }
  if (variable.contains(RegExp(r"[^A-Za-z0-9_]"))) {
    throw Exception(
        "Column name should only contain alphanumerics and underscores: '$variable'");
  }
}

/// A numeric of values sampled from a normal distribution.
///
/// Uses the [Box-Muller transform](https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform)
/// to generate [n] values from a normal distribution with mean [mu] and standard deviation [sigma].
///
Numeric sampleNormal(n, {num mu: 0, num sigma: 1, int seed}) {
  final rand = seed == null ? math.Random() : math.Random(seed);

  return Numeric(List<num>.generate(n, (_) {
    final u1 = rand.nextDouble(),
        u2 = rand.nextDouble(),
        z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
    return z * sigma + mu;
  }));
}

/// Ensures that the category index values in [a] and [b] match.
void matchCategories(Categoric a, Categoric b) {
  final categories = (List<String>.from(a.categories)..addAll(b.categories))
      .toSet()
      .toList()
        ..sort();

  void recategorize(Categoric x) {
    for (final index in x.indices) {
      if (x[index] != null) {
        x._categoryIndices[index] = categories.indexOf(x[index]);
      }
    }
    x._categories = categories;
  }

  recategorize(a);
  recategorize(b);
}
