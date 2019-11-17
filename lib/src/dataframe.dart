part of packhorse;

abstract class ColumnType {
  static const categoric = "cat", numeric = "num";
}

abstract class Alignment {
  static const left = ":--", right = "--:", center = ":--:";
}

class Dataframe {
  /// A data frame with `cats` and `nums` specified.
  Dataframe(this.cats, this.nums, List<String> columnsInOrder,
      {bool ignoreLengths = false}) {
    final lengths = (cats.keys.map((key) => cats[key].length).toList()
          ..addAll(nums.keys.map((key) => nums[key].length)))
        .toSet();
    if (!ignoreLengths && lengths.length != 1) {
      throw Exception("Columns not all of the same length.");
    }
    if (columnsInOrder != null) {
      this.columnsInOrder = List.from(columnsInOrder);
    }
  }

  /// An empty data frame.
  Dataframe.empty() {
    cats = Map<String, Categoric>();
    nums = Map<String, Numeric>();
  }

  /// A data frame from a map of lists.
  ///
  /// The keya of the map are interpreted as the column names;
  /// the values in the respective lists populate the rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = Dataframe.fromMapOfLists({
  ///   "image": ["🍑", "🍆", "🍊", "🍓", "🍍", "🍉", "🍇", "🍌", "🍒", "🍎"],
  ///   "fruit": [
  ///     "peach",
  ///     "eggplant",
  ///     "tangerine",
  ///     "strawberry",
  ///     "pineapple",
  ///     "watermelon",
  ///     "grapes",
  ///     "banana",
  ///     "cherries",
  ///     "apple"
  ///   ],
  ///   "color": [
  ///     "pink",
  ///     "purple",
  ///     "orange",
  ///     "red",
  ///     "yellow",
  ///     "pink",
  ///     "purple",
  ///     "yellow",
  ///     "red",
  ///     "red"
  ///   ],
  ///   "rating": [7, 7, 8, 9, 6, 6, 7, 7, 10, 5]
  /// });
  /// ```
  ///
  Dataframe.fromMapOfLists(Map<String, List<Object>> data) {
    cats = Map<String, Categoric>.fromIterable(
        data.keys.where((key) => data[key].first is String),
        value: (key) => Categoric(data[key].map((x) => x as String)));
    nums = Map<String, Numeric>.fromIterable(
        data.keys.where((key) => data[key].first is num),
        value: (key) => Numeric(data[key].map((x) => x as num)));
  }

  /// A data frame form a list of maps.
  ///
  /// Each map populates a row; the keys in each map determine
  /// the column each value should be put into.
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = Dataframe.fromListOfInstanceMaps([
  ///   {"image": "🍑", "fruit": "peach", "color": "pink", "rating": 7},
  ///   {"image": "🍆", "fruit": "eggplant", "color": "purple", "rating": 7},
  ///   {"image": "🍊", "fruit": "tangerine", "color": "orange", "rating": 8},
  ///   {"image": "🍓", "fruit": "strawberry", "color": "red", "rating": 9},
  ///   {"image": "🍍", "fruit": "pineapple", "color": "yellow", "rating": 6},
  ///   {"image": "🍉", "fruit": "watermelon", "color": "pink", "rating": 6},
  ///   {"image": "🍇", "fruit": "grapes", "color": "purple", "rating": 7},
  ///   {"image": "🍌", "fruit": "banana", "color": "yellow", "rating": 7},
  ///   {"image": "🍒", "fruit": "cherries", "color": "red", "rating": 10},
  ///   {"image": "🍎", "fruit": "apple", "color": "red", "rating": 5}
  /// ]);
  /// ```
  ///
  factory Dataframe.fromListOfInstanceMaps(
      List<Map<String, Object>> instances) {
    final data = Map<String, List<Object>>();
    for (int index = 0; index < instances.length; index++) {
      final instance = instances[index];
      for (final key in instance.keys) {
        if (!data.containsKey(key)) {
          data[key] = List.filled(index, null, growable: true);
        }
        data[key].add(instance[key]);
      }
      for (final key in data.keys.where((key) => !instance.containsKey(key))) {
        data[key].add(null);
      }
    }

    return Dataframe.fromMapOfLists(data);
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
  /// final data = Dataframe.fromCsv("""
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
      {String seperator = ",", Map<String, String> types}) {
    final splitRe = RegExp('($seperator)(?=(?:[^"]|"[^"]*")*\$)'),
        lines = csv
            .split("\n")
            .map((line) => line.trim())
            // Allow comments in csv strings: lines starting with #
            .where((line) => line.isNotEmpty && line[0] != "#")
            .toList();
    columnsInOrder = lines.first.split(splitRe);

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

  /// The names of the columns in this data frame.
  List<String> get columnNames => List<String>.from(columnsInOrder)
    ..addAll(cats.keys.where((key) => !columnsInOrder.contains(key)))
    ..addAll((nums.keys.where((key) => !columnsInOrder.contains(key))));

  /// The number of rows in this data frame.
  num get numberOfRows {
    if (cats.isNotEmpty) {
      return cats[cats.keys.first].length;
    } else if (nums.isNotEmpty) {
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
  Dataframe withRowsOrderedBy(String column, {bool decreasing = false}) {
    var frame = Dataframe(Map<String, Categoric>.from(cats),
        Map<String, Numeric>.from(nums), columnsInOrder);
    if (frame.cats.containsKey(column)) {
      frame = decreasing
          ? frame.withRowsAtIndices(
              frame.cats[column].orderedIndices.reversed.toList())
          : frame.withRowsAtIndices(frame.cats[column].orderedIndices);
    } else if (frame.nums.containsKey(column)) {
      frame = decreasing
          ? frame.withRowsAtIndices(
              frame.nums[column].orderedIndices.reversed.toList())
          : frame.withRowsAtIndices(frame.nums[column].orderedIndices);
    } else {
      throw Exception("Unrecognized column: '$column'.");
    }
    return frame;
  }

  /// Gets a list of sample row indices.
  List<int> sampleRowIndices(int n, {bool replacement = false, int seed}) {
    if (n > numberOfRows && !replacement) {
      throw Exception(
          "Cannot sample more rows than available without replacement.");
    }
    final rand = seed == null ? math.Random() : math.Random(seed),
        randomIndices = replacement
            ? List<int>.generate(n, (_) => rand.nextInt(numberOfRows))
            : (indices..shuffle(rand)).sublist(0, n);
    return randomIndices;
  }

  /// Gets a data frame made up of rows randomly sampled from this data frame.
  Dataframe withRowsSampled(int n, {bool replacement = false, int seed}) =>
      withRowsAtIndices(
          sampleRowIndices(n, replacement: replacement, seed: seed));

  /// Gets a data frame with a row index column added.
  Dataframe withRowIndices(String name) => Dataframe(
      Map<String, Categoric>.from(cats),
      Map<String, Numeric>.from(nums)..addAll({name: Numeric(indices)}),
      [name]..addAll(columnsInOrder));

  /// Ckecks whether all [columns] are actually columns.
  void _validColumnCheck(List<String> columns) {
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
  Dataframe withColumns(List<String> columns) {
    _validColumnCheck(columns);
    final cats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => !columns.contains(key)),
        nums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => !columns.contains(key));
    return Dataframe(cats, nums, columns.toList());
  }

  /// A data frame without the specified columns.
  Dataframe withColumnsDropped(List<String> columns) {
    _validColumnCheck(columns);
    final cats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => columns.contains(key)),
        nums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => columns.contains(key));
    return Dataframe(cats, nums,
        columnsInOrder.where((column) => !columns.contains(column)).toList());
  }

  /// A data frame with column names changed.
  Dataframe withColumnNamesChanged(Map<String, String> names) {
    _validColumnCheck(names.keys.toList());
    final changedCats = Map<String, Categoric>.from(cats),
        changedNums = Map<String, Numeric>.from(nums),
        order = List<String>.from(columnsInOrder);

    for (final key in names.keys) {
      final index = order.indexOf(key);
      if (changedCats.containsKey(key)) {
        changedCats[names[key]] = changedCats[key];
        changedCats.remove(key);
      } else if (changedNums.containsKey(key)) {
        changedNums[names[key]] = changedNums[key];
        changedNums.remove(key);
      }
      if (index != -1) {
        order[index] = names[key];
      }
    }

    return Dataframe(changedCats, changedNums, order);
  }

  /// A data frame with only the columns specified by [predicate].
  Dataframe withColumnsWhere(bool Function(String) predicate) {
    final cats = Map<String, Categoric>.from(this.cats)
          ..removeWhere((key, _) => !predicate(key)),
        nums = Map<String, Numeric>.from(this.nums)
          ..removeWhere((key, _) => !predicate(key)),
        keys = cats.keys.toList()..addAll(nums.keys);
    return Dataframe(cats, nums, columnsInOrder.where(keys.contains).toList());
  }

  /// A data frame with only the rows specified by [indices].
  Dataframe withRowsAtIndices(List<int> indices) {
    final cats = Map<String, Categoric>.fromIterable(this.cats.keys,
            value: (key) => this.cats[key].elementsAtIndices(indices)),
        nums = Map<String, Numeric>.fromIterable(this.nums.keys,
            value: (key) => this.nums[key].elementsAtIndices(indices));
    return Dataframe(cats, nums, columnsInOrder);
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
        for (String key in nums.keys) {
          argument = argument.replaceAll(
              "$startQuote$key$endQuote", nums[key][index].toString());
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
      {String startQuote = "{", String endQuote = "}"}) {
    final templateValues = _templateValues(template, startQuote, endQuote);
    return indices.where((index) => predicate(templateValues[index])).toList();
  }

  /// Gives the indices of rows whose values match the defined predicate.
  List<int> indicesWhereRowValues(
      bool Function(Map<String, String>, Map<String, num>) predicate) {
    return indices.where((index) {
      final catsMap = Map<String, String>.fromIterable(cats.keys,
              value: (key) => cats[key][index]),
          numsMap = Map<String, num>.fromIterable(nums.keys,
              value: (key) => nums[key][index]);
      return predicate(catsMap, numsMap);
    }).toList();
  }

  /// Gives a data frame with only the rows that match a template predicate.
  Dataframe withRowsWhereTemplate(
          String template, bool Function(String) predicate,
          {String startQuote = "{", String endQuote = "}"}) =>
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
      {String startQuote = "{", String endQuote = "}"}) {
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
          {String startQuote = "{", String endQuote = "}"}) =>
      withRowsAtIndices(indicesWhereTemplateAndFormula(
          template, formula, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// Gives the data frame with only rows matched by the defined predicate.
  Dataframe withRowsWhereRowValues(
          bool Function(Map<String, String>, Map<String, num>) predicate) =>
      withRowsAtIndices(indicesWhereRowValues(predicate));

  /// A data frame with a categoric column from a template.
  Dataframe withCategoricFromTemplate(String name, String template,
      {String startQuote = "{",
      String endQuote = "}",
      String Function(String) generator}) {
    generator = generator ?? (x) => x;
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    cats[name] = Categoric(
        _templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a numeric column from a template.
  Dataframe withNumericFromTemplate(
      String name, String template, num Function(String) generator,
      {String startQuote = "{", String endQuote = "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] =
        Numeric(_templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a categoric column from a formula.
  Dataframe withCategoricFromFormula(
      String name, String formula, String Function(num) generator) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    cats[name] = Categoric(_formulaValues(formula).map(generator));
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a numeric inserted.
  Dataframe withNumeric(String name, Numeric numeric) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] = numeric;
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a numeric column from a formula.
  Dataframe withNumericFromFormula(String name, String formula,
      {num Function(num) generator}) {
    generator = generator ?? (x) => x;
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums);
    nums[name] = Numeric(_formulaValues(formula).map(generator));
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a categoric column from a template and formula.
  Dataframe withCategoricFromTemplateAndFormula(String name, String template,
      String formula, String Function(String, num) generator,
      {String startQuote = "{", String endQuote = "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    cats[name] = Categoric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(cats, nums, columnsInOrder);
  }

  /// A data frame with a numeric column from a template and formula.
  Dataframe withNumericFromTemplateAndFormula(String name, String template,
      String formula, num Function(String, num) generator,
      {String startQuote = "{", String endQuote = "}"}) {
    final cats = Map<String, Categoric>.from(this.cats),
        nums = Map<String, Numeric>.from(this.nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    nums[name] = Numeric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(cats, nums, columnsInOrder);
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

    return Dataframe(cats, nums, columnsInOrder);
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

    return Dataframe(cats, nums, columnsInOrder);
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
    return Dataframe(cats, nums, columnsInOrder);
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

    final cats = Map<String, Categoric>.fromIterable(leftCats.keys,
            value: (key) => Categoric(leftCats[key]))
          ..addAll(Map<String, Categoric>.fromIterable(rightCats.keys,
              key: (key) => leftCats.keys.contains(key) ? "other_$key" : key,
              value: (key) => Categoric(rightCats[key]))),
        nums = Map<String, Numeric>.fromIterable(leftNums.keys,
            value: (key) => Numeric(leftNums[key]))
          ..addAll(Map<String, Numeric>.fromIterable(rightNums.keys,
              key: (key) => leftNums.keys.contains(key) ? "other_$key" : key,
              value: (key) => Numeric(rightNums[key])));

    return Dataframe(cats, nums, []);
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
            value: (key) => Numeric(combinedNums[key])),
        List<String>.from(columnsInOrder));
  }

  ///
  Dataframe withNullsDropped([List<String> columns]) {
    if (columns == null) {
      columns = columnNames;
    }

    var set = Set<int>();
    for (final column in columns) {
      if (cats.containsKey(column)) {
        set.addAll(this.cats[column].nullIndices);
      } else {
        set.addAll(this.nums[column].nullIndices);
      }
    }

    final selectedIndices =
        indices.where((index) => !set.contains(index)).toList();
    return withRowsAtIndices(selectedIndices)..columnsInOrder = columnsInOrder;
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
          {String startQuote = "{", String endQuote = "}"}) =>
      _templateValues(template, startQuote, endQuote);

  /// Gives the values in a row as a map.
  Map<String, Object> valuesInRow(int index) =>
      Map<String, Object>.fromIterable(cats.keys,
          value: (key) => cats[key][index])
        ..addAll(Map<String, Object>.fromIterable(nums.keys,
            value: (key) => nums[key][index]));

  /// Gives a markdown representation of this data frame.
  String toMarkdown(
      {Map<String, String> alignment, bool summary = false, int fixed}) {
    alignment = alignment ?? <String, String>{};

    _validColumnCheck(alignment.keys.toList());

    final table =
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

  /// Gives a csv representation of this data frame.
  String toCsv({bool markColumns = false, int fixed}) {
    final table =
        Map<String, List<String>>.fromIterable(columnNames, key: (key) {
      if (markColumns) {
        if (cats.containsKey(key)) {
          // Mark the column as categoric.
          return "$key*";
        } else {
          // Mark the column as numeric.
          return "$key^";
        }
      } else {
        return key;
      }
    }, value: (key) {
      if (cats.containsKey(key)) {
        return cats[key];
      } else {
        return nums[key]
            .map((x) => fixed == null ? x.toString() : x.toStringAsFixed(fixed))
            .toList();
      }
    });

    final header = "${table.keys.join(",")}",
        rows = indices
            .map((index) =>
                "${table.keys.map((key) => table[key][index]).join(",")}")
            .toList();

    return """$header
${rows.join("\n")}
""";
  }

  /// Gives an html table representation of this data frame.
  String toHtml({bool summary = false, int fixed}) {
    final table =
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

  /// Gives a map of lists, each column name as a key.
  Map<String, Column> toMapOfLists([List<String> columns]) =>
      Map<String, Column>.fromIterable(
          columns == null ? (cats.keys.toList()..addAll(nums.keys)) : columns,
          value: (column) =>
              cats.containsKey(column) ? cats[column] : nums[column]);

  /// Gives a list of maps, each map representing a row.
  List<Map<String, Object>> toListOfMaps([List<int> indices]) =>
      (indices == null ? this.indices : indices)
          .map((index) => valuesInRow(index))
          .toList();

  /// Gives a string representation of this data frame.
  @override
  String toString() {
    final table =
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
