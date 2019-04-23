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
