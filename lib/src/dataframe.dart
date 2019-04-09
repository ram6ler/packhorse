part of packhorse;

abstract class ColumnType {
  static const categoric = "cat", numeric = "num";
}

abstract class Alignment {
  static const left = ":--", right = "--:", center = ":--:";
}

class Dataframe {
  Dataframe(this.cats, this.nums) {
    final lengths = (cats.keys.map((key) => cats[key].length).toList()
          ..addAll(nums.keys.map((key) => nums[key].length)))
        .toSet();
    if (lengths.length != 1) {
      throw Exception("Columns not all of the same length.");
    }
  }

  /// A data frame from a csv expression.
  ///
  /// Whether a column contains numeric or categorig is either
  /// explicitly set using [types] or guessed based on the values
  /// in the first row of data. A shorthand way of explicitly
  /// defining column type is to include an asterisk (*) or carat (^) in
  /// the column header to force a column to be categoric or numeric
  /// respectively.
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = DataFrame.fromCsv("""
  ///   image,fruit,color,rating
  ///   🍑,peach,pink,7
  ///   🍆,eggplant,purple,7
  ///   🍊,tangerine,orange,8
  ///   🍓,strawberry,red,9
  ///   🍍,pineapple,yellow,6
  ///   🍉,watermelon,pink,6
  ///   🍇,grapes,purple,7
  ///   🍌,banana,yellow,7
  ///   🍒,cherries,red,10
  ///   🍎,apple,red,5
  /// """);
  /// ```
  ///
  Dataframe.fromCsv(String csv,
      {String seperator: ",", Map<String, String> types}) {
    final lines = csv
        .split("\n")
        .map((line) => line.trim())
        // Allow comments in csv strings: line starting with #
        .where((line) => !line.isEmpty && line[0] != "#")
        .toList();
    columnsInOrder = lines.first.split(seperator);

    types = types ?? Map<String, String>();

    for (int i = 0; i < columnsInOrder.length; i++) {
      if (columnsInOrder[i].contains("*")) {
        // If the header contains an asterisk, the column is a categoric.
        columnsInOrder[i] = columnsInOrder[i].replaceAll("*", "");
        types[columnsInOrder[i]] = ColumnType.categoric;
      }
      if (columnsInOrder[i].contains("^")) {
        // If the header contains a carat, the column is a numeric.
        columnsInOrder[i] = columnsInOrder[i].replaceAll("^", "");
        types[columnsInOrder[i]] = ColumnType.numeric;
      }
    }

    final mapOfValueStrings = Map<String, List<String>>.fromIterable(
        columnsInOrder,
        value: (_) => <String>[]);

    for (final line in lines.sublist(1)) {
      final datum = line.split(seperator);
      for (int i = 0; i < columnsInOrder.length; i++) {
        mapOfValueStrings[columnsInOrder[i]].add(datum[i]);
      }
    }

    for (final variable in columnsInOrder) {
      _checkVariableName(variable);
      if (!types.keys.contains(variable)) {
        types[variable] =
            num.tryParse(mapOfValueStrings[variable].first) == null
                ? ColumnType.categoric
                : ColumnType.numeric;
      }
    }

    final categoricVariables = columnsInOrder
            .where((variable) => types[variable] == ColumnType.categoric),
        numericVariables = columnsInOrder
            .where((variable) => types[variable] == ColumnType.numeric);

    if (columnsInOrder.length !=
        categoricVariables.length + numericVariables.length) {
      throw Exception("Unknown variable type encountered.");
    }

    cats = Map<String, Categoric>.fromIterable(categoricVariables,
        value: (variable) => Categoric(mapOfValueStrings[variable]));
    nums = Map<String, Numeric>.fromIterable(numericVariables,
        value: (variable) =>
            Numeric(mapOfValueStrings[variable].map(num.tryParse)));
  }

  /// The categoric columns in this data frame.
  Map<String, Categoric> cats;

  /// The numeric columns in this data frame.
  Map<String, Numeric> nums;

  /// The order of the columns in displays.
  List<String> columnsInOrder = [];

  /// A shorthand way of accessing the columns. (For editor awareness, use [cats] and [nums] instead.)
  Column operator [](String column) {
    if (cats.containsKey(column)) {
      return cats[column];
    } else if (nums.containsKey(column)) {
      return nums[column];
    } else {
      throw Exception("Unrecognized column: '$column'");
    }
  }

  void operator []=(String key, Iterable value) {
    if (value.length != numberOfRows) {
      throw Exception("Expecting $numberOfRows rows.");
    }
    if (cats.containsKey(key) || nums.containsKey(key)) {
      throw Exception("Data frame already contains column '$key'.");
    }

    if (value.first is num) {
      nums[key] = Numeric(List<num>.from(value));
    } else {
      cats[key] = Categoric(List<String>.from(value));
    }
  }

  /// The number of rows in this data frame.
  num get numberOfRows {
    if (cats.length > 0) {
      return cats[cats.keys.first].length;
    } else if (nums.length > 0) {
      return nums[nums.keys.first].length;
    } else {
      return 0;
    }
  }

  /// The number of columns in this data frame.
  num get numberOfColumns => cats.length + nums.length;

  /// A sequence of integers that runs along the rows of this data frame.
  List<int> get indices => sequence(numberOfRows);

  /// Gets a data frame with rows ordered by the values in [column].
  Dataframe withRowsOrderedBy(String column, {bool decreasing: false}) {
    var frame = Dataframe(
        Map<String, Categoric>.from(cats), Map<String, Numeric>.from(nums));
    if (frame.cats.containsKey(column)) {
      frame = frame.withRowsAtIndices(frame.cats[column].orderedIndices);
    } else if (frame.nums.containsKey(column)) {
      frame = frame.withRowsAtIndices(frame.nums[column].orderedIndices);
    } else {
      throw Exception("Unrecognized column: '$column'.");
    }
    return frame;
  }

  /// Gets a data frame made up of rows randomly sampled from this data frame.
  Dataframe withRowsSampled(int n, {bool replacement: false, int seed}) {
    if (n > numberOfRows && !replacement) {
      throw Exception(
          "Cannot sample more rows than available without replacement.");
    }
    final rand = seed == null ? math.Random() : math.Random(seed),
        randomIndices = replacement
            ? List<int>.generate(n, (_) => rand.nextInt(numberOfRows))
            : (indices..shuffle(rand)).sublist(0, n);

    return withRowsAtIndices(randomIndices);
  }

  /// Gets a data frame with a row index column added.
  Dataframe withRowIndices(String name) => Dataframe(
      Map<String, Categoric>.from(cats),
      Map<String, Numeric>.from(nums)..addAll({name: Numeric(indices)}));

  /// Ckecks whether all [columns] are actually columns.
  void _validColumnCheck(Iterable<String> columns) {
    for (final column in columns) {
      if (!(cats.containsKey(column) || nums.keys.contains(column))) {
        throw Exception("Unrecognized column: '$column'");
      }
    }
  }

  /// A data frame with only the specified columns, in that order.
  ///
  /// (If a column name is repeated the column will appear more than once in presentations.)
  ///
  Dataframe withColumns(Iterable<String> columns) {
    _validColumnCheck(columns);
    final nextCats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => !columns.contains(key)),
        nextNums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => !columns.contains(key));
    return Dataframe(nextCats, nextNums)..columnsInOrder = columns.toList();
  }

  /// A data frame without the specified columns.
  Dataframe withColumnsDropped(Iterable<String> columns) {
    _validColumnCheck(columns);
    final nextCats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => columns.contains(key)),
        nextNums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => columns.contains(key));
    return Dataframe(nextCats, nextNums);
  }

  /// A data frame with column names changed.
  Dataframe withColumnNamesChanged(Map<String, String> names) {
    _validColumnCheck(names.keys);
    final changedCats = Map<String, Categoric>.from(cats),
        changedNums = Map<String, Numeric>.from(nums);

    for (final key in names.keys) {
      if (changedCats.containsKey(key)) {
        changedCats[names[key]] = changedCats[key];
        changedCats.remove(key);
      } else if (changedNums.containsKey(key)) {
        changedNums[names[key]] = changedNums[key];
        changedNums.remove(key);
      }
    }

    return Dataframe(changedCats, changedNums);
  }

  /// A data frame with only the columns specified by [predicate].
  Dataframe withColumnsWhere(bool Function(String) predicate) {
    final cats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => !predicate(key)),
        nums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => !predicate(key));
    return Dataframe(cats, nums);
  }

  /// A data frame with only the rows specified by [indices].
  Dataframe withRowsAtIndices(Iterable<int> indices) {
    final cats = Map<String, Categoric>.fromIterable(this.cats.keys,
            value: (key) => this.cats[key].elementsAtIndices(indices)),
        nums = Map<String, Numeric>.fromIterable(this.nums.keys,
            value: (key) => this.nums[key].elementsAtIndices(indices));
    return Dataframe(cats, nums);
  }

  /// A helper function that generates the values specified by a template.
  List<String> _templateValues(
          String template, String startQuote, String endQuote) =>
      indices.map((index) {
        String argument = template;
        for (String key in cats.keys) {
          argument =
              argument.replaceAll("$startQuote$key$endQuote", cats[key][index]);
        }
        return argument;
      }).toList();

  /// A helper function that generates values from a formula.
  List<num> _formulaValues(String formula) {
    final f = FunctionTree(
        fromExpression: formula, withVariableNames: nums.keys.toList());
    return indices.map((index) {
      final arguments = Map<String, num>.fromIterable(nums.keys,
          value: (key) => nums[key][index]);
      return f(arguments);
    }).toList();
  }

  /// Gives the indices that match a template predicate.
  List<int> indicesWhereTemplate(
      String template, bool Function(String) predicate,
      {String startQuote: "{", String endQuote: "}"}) {
    final templateValues = _templateValues(template, startQuote, endQuote);
    return indices.where((index) => predicate(templateValues[index])).toList();
  }

  /// Gives a data frame with only the rows that match a template predicate.
  Dataframe withRowsWhereTemplate(
          String template, bool Function(String) predicate,
          {String startQuote: "{", String endQuote: "}"}) =>
      withRowsAtIndices(indicesWhereTemplate(template, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// Gives the indices that match a formula predicate.
  List<int> indicesWhereFormula(String formula, bool Function(num) predicate) {
    final formulaValues = _formulaValues(formula);
    return indices.where((index) => predicate(formulaValues[index])).toList();
  }

  /// Gives a data frame with only the rows that match a formula predicate.
  Dataframe withRowsWhereFormula(
          String formula, bool Function(num) predicate) =>
      withRowsAtIndices(indicesWhereFormula(formula, predicate));

  /// Gives the indices that match a template and formula predicate.
  List<int> indicesWhereTemplateAndFormula(
      String template, String formula, bool Function(String, num) predicate,
      {String startQuote: "{", String endQuote: "}"}) {
    final templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);

    return indices
        .where(
            (index) => predicate(templateValues[index], formulaValues[index]))
        .toList();
  }

  /// Gives a data frame with only the rows that match a template and formula predicate.
  Dataframe withRowsWhereTemplateAndFormula(
          String template, String formula, bool Function(String, num) predicate,
          {String startQuote: "{", String endQuote: "}"}) =>
      withRowsAtIndices(indicesWhereTemplateAndFormula(
          template, formula, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// A data frame with a categoric column from a template.
  Dataframe withCategoricFromTemplate(String name, String template,
      {String startQuote: "{",
      String endQuote: "}",
      String Function(String) generator}) {
    generator = generator ?? (x) => x;
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    cats[name] = Categoric(
        _templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(cats, nums);
  }

  /// A data frame with a numeric column from a template.
  Dataframe withNumericFromTemplate(
      String name, String template, num Function(String) generator,
      {String startQuote: "{", String endQuote: "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] =
        Numeric(_templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(cats, nums);
  }

  /// A data frame with a categoric column from a formula.
  Dataframe withCategoricFromFormula(
      String name, String formula, String Function(num) generator) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    cats[name] = Categoric(_formulaValues(formula).map(generator));
    return Dataframe(cats, nums);
  }

  /// A data frame with a numeric column from a formula.
  Dataframe withNumericFromFormula(String name, String formula,
      {num Function(num) generator}) {
    generator = generator ?? (x) => x;
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] = Numeric(_formulaValues(formula).map(generator));
    return Dataframe(cats, nums);
  }

  /// A data frame with a categoric column from a template and formula.
  Dataframe withCategoricFromTemplateAndFormula(String name, String template,
      String formula, String Function(String, num) generator,
      {String startQuote: "{", String endQuote: "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    cats[name] = Categoric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(cats, nums);
  }

  /// A data frame with a numeric column from a template and formula.
  Dataframe withNumericFromTemplateAndFormula(String name, String template,
      String formula, num Function(String, num) generator,
      {String startQuote: "{", String endQuote: "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    nums[name] = Numeric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(cats, nums);
  }

  /// A data frame with a categoric column from the row values.
  Dataframe withCategoricFromRowValues(
      String name,
      String Function(Map<String, String> cats, Map<String, num> nums)
          generator) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    cats[name] = Categoric(indices.map((index) {
      final catsArgument = Map<String, String>.fromIterable(this.cats.keys,
              value: (key) => this.cats[key][index]),
          numsArgument = Map<String, num>.fromIterable(this.nums.keys,
              value: (key) => this.nums[key][index]);
      return generator(catsArgument, numsArgument);
    }));

    return Dataframe(cats, nums);
  }

  /// A data frame with a numeric column from the row values.
  Dataframe withNumericFromRowValues(String name,
      num Function(Map<String, String> cats, Map<String, num> nums) generator) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] = Numeric(indices.map((index) {
      final catsArgument = Map<String, String>.fromIterable(this.cats.keys,
              value: (key) => this.cats[key][index]),
          numsArgument = Map<String, num>.fromIterable(this.nums.keys,
              value: (key) => this.nums[key][index]);
      return generator(catsArgument, numsArgument);
    }));

    return Dataframe(cats, nums);
  }

  /// A data frame with a numeric column for each value in a categoric column.
  Dataframe withCategoricEnumerated(String name) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums),
        categories = cats[name].categories;
    for (final category in categories) {
      nums["${name}_$category"] =
          Numeric(cats[name].map((cat) => cat == category ? 1 : 0));
    }
    return Dataframe(cats, nums);
  }

  /// Generalized join helper function.
  static Dataframe _join(Dataframe left, Dataframe right, String leftPivot,
      String rightPivot, Set<Object> ids) {
    if (![left.cats.keys, left.nums.keys]
        .any((keys) => keys.contains(leftPivot))) {
      throw Exception("Unrecognized pivot: '$leftPivot'.");
    }
    if (![right.cats.keys, right.nums.keys]
        .any((keys) => keys.contains(rightPivot))) {
      throw Exception("Unrecognized pivot: '$rightPivot'.");
    }

    final leftCats = Map<String, List<String>>.fromIterable(left.cats.keys,
            value: (_) => []),
        rightCats = Map<String, List<String>>.fromIterable(right.cats.keys,
            value: (_) => []),
        leftNums = Map<String, List<num>>.fromIterable(left.nums.keys,
            value: (_) => []),
        rightNums = Map<String, List<num>>.fromIterable(right.nums.keys,
            value: (_) => []);

    for (final id in ids) {
      final
          // Rows in left that match id:
          leftIndices = id is String
              ? left.cats[leftPivot].indicesWhere((value) => value == id)
              : left.nums[leftPivot].indicesWhere((value) => value == id),
          // Rows in right that match id:
          rightIndices = id is String
              ? right.cats[rightPivot].indicesWhere((value) => value == id)
              : right.nums[rightPivot].indicesWhere((value) => value == id);

      if (leftIndices.isEmpty && rightIndices.isEmpty) {
        // Dont' add any rows to the join.
      } else if (leftIndices.isEmpty) {
        for (final index in rightIndices) {
          // Fill left with nulls...
          for (final key in leftCats.keys) {
            leftCats[key].add(null);
          }
          for (final key in leftNums.keys) {
            leftNums[key].add(null);
          }
          // ... and right with values.
          for (final key in rightCats.keys) {
            rightCats[key].add(right.cats[key][index]);
          }
          for (final key in rightNums.keys) {
            rightNums[key].add(right.nums[key][index]);
          }
        }
      } else if (rightIndices.isEmpty) {
        for (final index in leftIndices) {
          // Fill left with values...
          for (final key in leftCats.keys) {
            leftCats[key].add(left.cats[key][index]);
          }
          for (final key in leftNums.keys) {
            leftNums[key].add(left.nums[key][index]);
          }
          // ... and right with nulls.
          for (final key in rightCats.keys) {
            rightCats[key].add(null);
          }
          for (final key in rightNums.keys) {
            rightNums[key].add(null);
          }
        }
      } else {
        for (final leftIndex in leftIndices) {
          for (final rightIndex in rightIndices) {
            // Fill left with values...
            for (final key in leftCats.keys) {
              leftCats[key].add(left.cats[key][leftIndex]);
            }
            for (final key in leftNums.keys) {
              leftNums[key].add(left.nums[key][leftIndex]);
            }
            // ... and right with values.
            for (final key in rightCats.keys) {
              rightCats[key].add(right.cats[key][rightIndex]);
            }
            for (final key in rightNums.keys) {
              rightNums[key].add(right.nums[key][rightIndex]);
            }
          }
        }
      }
    }

    final joinedCats = Map<String, Categoric>.fromIterable(leftCats.keys,
            value: (key) => Categoric(leftCats[key]))
          ..addAll(Map<String, Categoric>.fromIterable(rightCats.keys,
              key: (key) => leftCats.keys.contains(key) ? "other_$key" : key,
              value: (key) => Categoric(rightCats[key]))),
        joinedNums = Map<String, Numeric>.fromIterable(leftNums.keys,
            value: (key) => Numeric(leftNums[key]))
          ..addAll(Map<String, Numeric>.fromIterable(rightNums.keys,
              key: (key) => leftNums.keys.contains(key) ? "other_$key" : key,
              value: (key) => Numeric(rightNums[key])));

    return Dataframe(joinedCats, joinedNums);
  }

  /// A data frame from a full left join.
  Dataframe withLeftJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet();
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from a full right join.
  Dataframe withRightJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids = other.cats.containsKey(otherPivot)
        ? other.cats[otherPivot].toSet()
        : other.nums[otherPivot].toSet();
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from an inner join.
  Dataframe withInnerJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        (cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet())
            .intersection(other.cats.containsKey(otherPivot)
                ? other.cats[otherPivot].toSet()
                : other.nums[otherPivot].toSet());
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from a full join.
  Dataframe withFullJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        (cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet())
            .union(other.cats.containsKey(otherPivot)
                ? other.cats[otherPivot].toSet()
                : other.nums[otherPivot].toSet());
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from an outer left join.
  Dataframe withLeftOuterJoin(Dataframe other, String pivot,
      {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a =
            cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet(),
        b = other.cats.containsKey(otherPivot)
            ? other.cats[otherPivot].toSet()
            : other.nums[otherPivot].toSet(),
        ids = a.difference(b);
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from an outer right join.
  Dataframe withRightOuterJoin(Dataframe other, String pivot,
      {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a =
            cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet(),
        b = other.cats.containsKey(otherPivot)
            ? other.cats[otherPivot].toSet()
            : other.nums[otherPivot].toSet(),
        ids = b.difference(a);
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame from an outer join.
  Dataframe withOuterJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a =
            cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet(),
        b = other.cats.containsKey(otherPivot)
            ? other.cats[otherPivot].toSet()
            : other.nums[otherPivot].toSet(),
        ids = a.union(b).difference(a.intersection(b));
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// A data frame with the rows of [other] added.
  Dataframe withDataAdded(Dataframe other) {
    final catsKeysSet = (cats.keys.toList()..addAll(other.cats.keys)).toSet(),
        combinedCats = Map<String, List<String>>.fromIterable(catsKeysSet,
            value: (_) => <String>[]),
        numsKeysSet = (nums.keys.toList()..addAll(other.nums.keys)).toSet(),
        combinedNums = Map<String, List<num>>.fromIterable(numsKeysSet,
            value: (_) => <num>[]);

    // Add this if possible
    for (final key in combinedCats.keys) {
      if (cats.containsKey(key)) {
        combinedCats[key].addAll(cats[key]);
      } else {
        combinedCats[key]
            .addAll(List<String>.generate(numberOfRows, (_) => null));
      }
    }

    for (final key in combinedNums.keys) {
      if (nums.keys.contains(key)) {
        combinedNums[key].addAll(nums[key]);
      } else {
        combinedNums[key].addAll(List<num>.generate(numberOfRows, (_) => null));
      }
    }

    // Add other if possible
    for (final key in combinedCats.keys) {
      if (other.cats.containsKey(key)) {
        combinedCats[key].addAll(other.cats[key]);
      } else {
        combinedCats[key]
            .addAll(List<String>.generate(other.numberOfRows, (_) => null));
      }
    }

    for (final key in combinedNums.keys) {
      if (other.nums.keys.contains(key)) {
        combinedNums[key].addAll(other.nums[key]);
      } else {
        combinedNums[key]
            .addAll(List<num>.generate(other.numberOfRows, (_) => null));
      }
    }

    return Dataframe(
        Map<String, Categoric>.fromIterable(combinedCats.keys,
            value: (key) => Categoric(combinedCats[key])),
        Map<String, Numeric>.fromIterable(combinedNums.keys,
            value: (key) => Numeric(combinedNums[key])));
  }

  /// Gives a map of data frames grouped by category.
  Map<String, Dataframe> groupedByCategoric(String category) {
    if (!cats.containsKey(category)) {
      throw Exception("Unrecognized category: '$category'.");
    }

    final values = cats[category].toSet();

    return Map<String, Dataframe>.fromIterable(values,
        value: (value) =>
            withRowsAtIndices(cats[category].indicesWhere((v) => v == value)));
  }

  /// Gives a map of data frames grouped by value.
  Map<num, Dataframe> groupedByNumeric(String numeric) {
    if (!nums.containsKey(numeric)) {
      throw Exception("Unrecognized category: '$numeric'.");
    }

    final values = nums[numeric].toSet();

    return Map<num, Dataframe>.fromIterable(values,
        value: (value) =>
            withRowsAtIndices(nums[numeric].indicesWhere((v) => v == value)));
  }

  /// Gives a list of strings generated from the row values.
  List<String> stringsFromTemplate(String template,
          {String startQuote: "{", String endQuote: "}"}) =>
      indices.map((index) {
        String line = template;
        for (final key in cats.keys) {
          final pattern = "$startQuote$key$endQuote";
          line = line.replaceAll(pattern, cats[key][index]);
        }
        for (final key in nums.keys) {
          final pattern = "$startQuote$key$endQuote";
          line = line.replaceAll(pattern, nums[key][index].toString());
        }
        return line;
      }).toList();

  /*Map<String, Object> valuesInRow(int index) =>
      Map<String, Object>.fromIterable(cats.keys,
          value: (key) => cats[key][index])
        ..addAll(Map<String, Object>.fromIterable(nums.keys,
            value: (key) => cats[key][index]));*/

  /// Gives a markdown representation of this data frame.
  /// // TODO: limit rows if too many.
  String toMarkdown(
      {Map<String, String> alignment, bool summary: false, int fixed}) {
    alignment = alignment ?? <String, String>{};

    _validColumnCheck(alignment.keys);

    final columnNames = List<String>.from(columnsInOrder)
          ..addAll(cats.keys.where((key) => !columnsInOrder.contains(key)))
          ..addAll((nums.keys.where((key) => !columnsInOrder.contains(key)))),
        table =
            Map<String, List<String>>.fromIterable(columnNames, value: (key) {
      if (cats.containsKey(key)) {
        return cats[key];
      } else {
        return nums[key]
            .map((x) => fixed == null ? x.toString() : x.toStringAsFixed(fixed))
            .toList();
      }
    });

    for (final key in columnNames) {
      if (!alignment.containsKey(key)) {
        alignment[key] = Alignment.center;
      } else {
        if (![Alignment.center, Alignment.left, Alignment.right]
            .contains(alignment[key])) {
          throw Exception("Unknown markdown alignment: '${alignment[key]}'.");
        }
      }
    }

    final header = "|${columnNames.join("|")}|",
        alignmentSetting =
            "|${columnNames.map((key) => alignment[key]).join("|")}|",
        summarize = numberOfRows > 10 && summary,
        rows = (summarize
                ? indices
                    .where((index) => index < 5 || numberOfRows - index <= 5)
                : indices)
            .map((index) =>
                "|${columnNames.map((key) => table[key][index]).join("|")}|")
            .toList(),
        empty = "|${columnNames.map((_) => "...").join("|")}|";

    return summarize
        ? """
$header
$alignmentSetting
${rows.sublist(0, 5).join("\n")}
$empty
${rows.sublist(5).join("\n")}

"""
        : """
$header
$alignmentSetting
${rows.join("\n")}

""";
  }

  String toHtml({bool summary: false, int fixed}) {
    final columnNames = List<String>.from(columnsInOrder)
          ..addAll(cats.keys.where((key) => !columnsInOrder.contains(key)))
          ..addAll((nums.keys.where((key) => !columnsInOrder.contains(key)))),
        table =
            Map<String, List<String>>.fromIterable(columnNames, value: (key) {
      if (cats.containsKey(key)) {
        return cats[key];
      } else {
        return nums[key]
            .map((x) => fixed == null ? x.toString() : x.toStringAsFixed(fixed))
            .toList();
      }
    });

    final summarize = numberOfRows > 10 && summary,
        header = "<tr><th>${columnNames.join("</th><th>")}</th></tr>",
        rows = (summarize
                ? indices
                    .where((index) => index < 5 || numberOfRows - index <= 5)
                : indices)
            .map((index) =>
                "<tr><td>${columnNames.map((key) => table[key][index]).join("</td><td>")}</td></tr>")
            .toList(),
        empty =
            "<tr><td>${columnNames.map((_) => "...").join("</td><td>")}</td></tr>";

    return summarize
        ? """
<table>
$header
${rows.sublist(0, 5).join("\n")}
$empty
${rows.sublist(5).join("\n")}
</table>
"""
        : """
<table>
$header
${rows.join("\n")}
</table>
""";
  }

  /// Gives a string representation of this data frame.
  @override
  String toString() {
    final columnNames = List<String>.from(columnsInOrder)
          ..addAll(cats.keys.where((key) => !columnsInOrder.contains(key)))
          ..addAll((nums.keys.where((key) => !columnsInOrder.contains(key)))),
        table =
            Map<String, List<String>>.fromIterable(columnNames, value: (key) {
      if (cats.containsKey(key)) {
        return cats[key];
      } else {
        return nums[key].map((x) => x.toString()).toList();
      }
    }),
        widths = Map<String, int>.fromIterable(columnNames,
            value: (key) => math.max(
                key.length,
                table[key].fold(
                    0,
                    (length, value) =>
                        // convert potential nulls to Strings...
                        math.max(length, value.toString().length)))),
        horizontalLine = (String join) =>
            "${columnNames.map((key) => "-" * widths[key]).join(join)}",
        header =
            "|${columnNames.map((key) => "${key.padLeft(widths[key], " ")}").join("|")}|",
        rows = sequence(numberOfRows)
            .map((index) =>
                "|${columnNames.map((key) => "${table[key][index].toString().padLeft(widths[key], " ")}").join("|")}|")
            .join("\n");
    return """
.${horizontalLine(".")}.
$header
:${horizontalLine("+")}:
$rows
'${horizontalLine("'")}'
""";
  }
}
