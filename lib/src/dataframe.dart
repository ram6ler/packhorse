part of packhorse;

class Dataframe {
  /// Creates a data frame with `cats` and `nums` specified.
  Dataframe(this.cats, this.nums, List<String> columnsInOrder,
      {bool ignoreLengthMismatch = false}) {
    final lengths = (cats.keys.map((key) => cats[key].length).toList()
          ..addAll(nums.keys.map((key) => nums[key].length)))
        .toSet();
    if (!ignoreLengthMismatch && lengths.length != 1) {
      throw Exception('Columns not all of the same length.');
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

  Dataframe.fromMapOfLists(Map<String, List<Object>> data) {
    cats = Map<String, Categoric>.fromIterable(
        data.keys.where((key) => data[key].first is String),
        value: (key) => Categoric(data[key].map((x) => x as String)));
    nums = Map<String, Numeric>.fromIterable(
        data.keys.where((key) => data[key].first is num),
        value: (key) => Numeric(data[key].map((x) => x as num)));
  }

  factory Dataframe.fromListOfMaps(List<Map<String, Object>> instances) {
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

  Dataframe.fromCsv(String csv,
      {String seperator = ',', Map<String, String> types}) {
    final
        // Separators not contained in quotes;
        // see https://stackoverflow.com/a/632552/1340742
        splitRe = RegExp('($seperator)(?=(?:[^"]|"[^"]*")*\$)'),
        tempLines = csv.split('\n');

    // Allow for quoted multiple lines.
    String completeLine = '';
    final nonQuote = RegExp(r'[^"]'),
        lines = tempLines
            .fold<List<String>>(List<String>(), (a, b) {
              completeLine = '$completeLine$b';
              if (completeLine.replaceAll(nonQuote, '').length % 2 == 0) {
                a.add(completeLine);
                completeLine = '';
              } else {
                completeLine += '[EOL]';
              }
              return a;
            })
            .map((line) => line.trim())
            // Allow comments in csv strings: lines starting with #
            .where((line) => line.isNotEmpty && line[0] != '#')
            .toList();
    columnsInOrder = lines.first
        .split(splitRe)
        .map((variable) => variable.replaceAll('"', '').trim())
        .toList();

    types = types ?? Map<String, String>();

    for (int i = 0; i < columnsInOrder.length; i++) {
      if (columnsInOrder[i].contains('*')) {
        // If the header contains an asterisk, the column is a categoric.
        columnsInOrder[i] =
            columnsInOrder[i].replaceAll('*', '').replaceAll('"', '');
        types[columnsInOrder[i]] = ColumnType.categoric;
      }
      if (columnsInOrder[i].contains('^')) {
        // If the header contains a carat, the column is a numeric.
        columnsInOrder[i] =
            columnsInOrder[i].replaceAll('^', '').replaceAll('"', '');
        types[columnsInOrder[i]] = ColumnType.numeric;
      }
    }

    final mapOfValueStrings = Map<String, List<String>>.fromIterable(
        columnsInOrder,
        value: (_) => <String>[]);

    for (final line in lines.sublist(1)) {
      final datum = line
          .split(splitRe)
          .map((value) => value.replaceAll('"', ''))
          .toList();
      for (int i = 0; i < columnsInOrder.length; i++) {
        try {
          mapOfValueStrings[columnsInOrder[i]].add(datum[i]);
        } catch (_) {
          throw Exception('Invalid row:\n  $line\n');
        }
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
      throw Exception('Unknown variable type encountered.');
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

  /// A summary of each column in this data frame.
  Map<String, Map<String, Object>> get summary => {
        for (final key in cats.keys) key: cats[key].summary
      }..addAll({for (final key in nums.keys) key: nums[key].summary});

  Dataframe withHead([int n = 10]) =>
      this.withRowsAtIndices(indices.take(math.min(n, numberOfRows)).toList());

  Dataframe withTail([int n = 10]) => this.withRowsAtIndices(
      indices.reversed.take(math.min(n, numberOfRows)).toList());

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
      throw Exception('Unrecognized column: "$column".');
    }
    return frame;
  }

  /// Gets a list of sample row indices.
  List<int> sampleRowIndices(int n, {bool replacement = false, int seed}) {
    if (n > numberOfRows && !replacement) {
      throw Exception(
          'Cannot sample more rows than available without replacement.');
    }
    final rand = seed == null ? math.Random() : math.Random(seed),
        randomIndices = replacement
            ? List<int>.generate(n, (_) => rand.nextInt(numberOfRows))
            : (indices..shuffle(rand)).sublist(0, n);
    return randomIndices;
  }

  Dataframe withRowsSampled(int n, {bool replacement = false, int seed}) =>
      withRowsAtIndices(
          sampleRowIndices(n, replacement: replacement, seed: seed));

  /// Returns a data frame with a row index column added.
  Dataframe withRowIndices(String name) => Dataframe(
      Map<String, Categoric>.from(cats),
      Map<String, Numeric>.from(nums)..addAll({name: Numeric(indices)}),
      [name]..addAll(columnsInOrder));

  /// Ckecks whether all [columns] are actually columns.
  void _validColumnCheck(List<String> columns) {
    for (final column in columns) {
      if (!(cats.containsKey(column) || nums.keys.contains(column))) {
        throw Exception('Unrecognized column: "$column"');
      }
    }
  }

  Dataframe withColumns(List<String> columns) {
    _validColumnCheck(columns);
    final pipedCats = Map<String, Categoric>.from(cats)
          ..removeWhere((key, _) => !columns.contains(key)),
        pipedNums = Map<String, Numeric>.from(nums)
          ..removeWhere((key, _) => !columns.contains(key));
    return Dataframe(pipedCats, pipedNums, columns.toList());
  }

  Dataframe withColumnsDropped(List<String> columns) {
    _validColumnCheck(columns);
    final pipedCats = Map<String, Categoric>.from(cats)
          ..removeWhere((key, _) => columns.contains(key)),
        pipedNums = Map<String, Numeric>.from(nums)
          ..removeWhere((key, _) => columns.contains(key));
    return Dataframe(pipedCats, pipedNums,
        columnsInOrder.where((column) => !columns.contains(column)).toList());
  }

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

  Dataframe withColumnsWhere(bool Function(String) predicate) {
    final pipedCats = Map<String, Categoric>.from(cats)
          ..removeWhere((key, _) => !predicate(key)),
        pipedNums = Map<String, Numeric>.from(nums)
          ..removeWhere((key, _) => !predicate(key)),
        keys = pipedCats.keys.toList()..addAll(pipedNums.keys);
    return Dataframe(
        pipedCats, pipedNums, columnsInOrder.where(keys.contains).toList());
  }

  Dataframe withRowsAtIndices(List<int> indices) {
    final pipedCats = Map<String, Categoric>.fromIterable(cats.keys,
            value: (key) => cats[key].elementsAtIndices(indices)),
        pipedNums = Map<String, Numeric>.fromIterable(nums.keys,
            value: (key) => nums[key].elementsAtIndices(indices));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// A helper function that generates the values specified by a template.
  List<String> _templateValues(
          String template, String startQuote, String endQuote) =>
      indices.map((index) {
        String argument = template;
        for (String key in cats.keys) {
          argument =
              argument.replaceAll('$startQuote$key$endQuote', cats[key][index]);
        }
        for (String key in nums.keys) {
          argument = argument.replaceAll(
              '$startQuote$key$endQuote', nums[key][index].toString());
        }
        return argument;
      }).toList();

  /// A helper function that generates values from a formula.
  List<num> _formulaValues(String formula) {
    final f = formula.toMultiVariableFunction(nums.keys.toList());
    return indices.map((index) {
      final arguments = Map<String, num>.fromIterable(nums.keys,
          value: (key) => nums[key][index]);
      return f(arguments);
    }).toList();
  }

  /// Gives the indices that match a template predicate.
  List<int> indicesWhereTemplate(
      String template, bool Function(String) predicate,
      {String startQuote = '{', String endQuote = '}'}) {
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

  Dataframe withRowsWhereTemplate(
          String template, bool Function(String) predicate,
          {String startQuote = '{', String endQuote = '}'}) =>
      withRowsAtIndices(indicesWhereTemplate(template, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// Gives the indices that match a formula predicate.
  List<int> indicesWhereFormula(String formula, bool Function(num) predicate) {
    final formulaValues = _formulaValues(formula);
    return indices.where((index) => predicate(formulaValues[index])).toList();
  }

  Dataframe withRowsWhereFormula(
          String formula, bool Function(num) predicate) =>
      withRowsAtIndices(indicesWhereFormula(formula, predicate));

  /// Gives the indices that match a template and formula predicate.
  List<int> indicesWhereTemplateAndFormula(
      String template, String formula, bool Function(String, num) predicate,
      {String startQuote = '{', String endQuote = '}'}) {
    final templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);

    return indices
        .where(
            (index) => predicate(templateValues[index], formulaValues[index]))
        .toList();
  }

  Dataframe withRowsWhereTemplateAndFormula(
          String template, String formula, bool Function(String, num) predicate,
          {String startQuote = '{', String endQuote = '}'}) =>
      withRowsAtIndices(indicesWhereTemplateAndFormula(
          template, formula, predicate,
          startQuote: startQuote, endQuote: endQuote));

  Dataframe withRowsWhereRowValues(
          bool Function(Map<String, String>, Map<String, num>) predicate) =>
      withRowsAtIndices(indicesWhereRowValues(predicate));

  /// Returns a data frame with a categoric column inserted.
  Dataframe withCategoric(String name, Categoric categoric) {
    if (categoric.length != numberOfRows) {
      throw Exception(
          'Expecting $numberOfRows values; got ${categoric.length}.');
    }
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedCats[name] = categoric;
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric inserted.
  Dataframe withNumeric(String name, Numeric numeric) {
    if (numeric.length != numberOfRows) {
      throw Exception('Expecting $numberOfRows values; got ${numeric.length}.');
    }
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedNums[name] = numeric;
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  Dataframe withNumericFromNumeric(String name, String existingNumericName,
          Numeric Function(Numeric numeric) generator) =>
      withNumeric(name, generator(nums[existingNumericName]));

  /// Returns a data frame with a numeric based on an existing categoric.
  Dataframe withNumericFromCategoric(String name, String existingCategoricName,
          Numeric Function(Categoric categoric) generator) =>
      withNumeric(name, generator(cats[existingCategoricName]));

  /// Returns a data frame with a categoric based on an existing numeric.
  Dataframe withCategoricFromNumeric(String name, String existingNumericName,
          Categoric Function(Numeric numeric) generator) =>
      withCategoric(name, generator(nums[existingNumericName]));

  /// Returns a data frame with a categoric based on an existing categoric.
  Dataframe withCategoricFromCategoric(
          String name,
          String existingCategoricName,
          Categoric Function(Categoric categoric) generator) =>
      withCategoric(name, generator(cats[existingCategoricName]));

  Dataframe withCategoricFromTemplate(String name, String template,
      {String startQuote = '{',
      String endQuote = '}',
      String Function(String) generator}) {
    generator = generator ?? (x) => x;
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedCats[name] = Categoric(
        _templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column from a template.
  Dataframe withNumericFromTemplate(
      String name, String template, num Function(String) generator,
      {String startQuote = '{', String endQuote = '}'}) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedNums[name] =
        Numeric(_templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a categoric column from a formula.
  Dataframe withCategoricFromFormula(
      String name, String formula, String Function(num) generator) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedCats[name] = Categoric(_formulaValues(formula).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column from a formula.
  Dataframe withNumericFromFormula(String name, String formula,
      {num Function(num) generator}) {
    generator = generator ?? (x) => x;
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedNums[name] = Numeric(_formulaValues(formula).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a categoric column from a template and formula.
  Dataframe withCategoricFromTemplateAndFormula(String name, String template,
      String formula, String Function(String, num) generator,
      {String startQuote = '{', String endQuote = '}'}) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    pipedCats[name] = Categoric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column from a template and formula.
  Dataframe withNumericFromTemplateAndFormula(String name, String template,
      String formula, num Function(String, num) generator,
      {String startQuote = '{', String endQuote = '}'}) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums),
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    pipedNums[name] = Numeric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a categoric column from the row values.
  Dataframe withCategoricFromRowValues(
      String name,
      String Function(Map<String, String> cats, Map<String, num> nums)
          generator) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedCats[name] = Categoric(indices.map((index) {
      final catsArgument = Map<String, String>.fromIterable(cats.keys,
              value: (key) => cats[key][index]),
          numsArgument = Map<String, num>.fromIterable(nums.keys,
              value: (key) => nums[key][index]);
      return generator(catsArgument, numsArgument);
    }));

    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column from the row values.
  Dataframe withNumericFromRowValues(String name,
      num Function(Map<String, String> cats, Map<String, num> nums) generator) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums);
    pipedNums[name] = Numeric(indices.map((index) {
      final catsArgument = Map<String, String>.fromIterable(cats.keys,
              value: (key) => cats[key][index]),
          numsArgument = Map<String, num>.fromIterable(nums.keys,
              value: (key) => nums[key][index]);
      return generator(catsArgument, numsArgument);
    }));

    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column for each value in a categoric column.
  Dataframe withCategoricEnumerated(String name) {
    final pipedCats = Map<String, Categoric>.from(cats),
        pipedNums = Map<String, Numeric>.from(nums),
        categories = pipedCats[name].categories;
    for (final category in categories) {
      pipedNums['${name}_$category'] =
          Numeric(pipedCats[name].map((cat) => cat == category ? 1 : 0));
    }
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  Dataframe withNumericCategorized(String name,
      {int bins, List<num> breaks, int decimalPlaces}) {
    final bars = nums[name].histogram(bins: bins, breaks: breaks);

    String convert(num x) {
      String category;
      for (final bar in bars) {
        if (x >= bar.lowerBound && x < bar.upperBound) {
          category = decimalPlaces == null
              ? '[${bar.lowerBound}, ${bar.upperBound})'
              : '[${bar.lowerBound.toStringAsFixed(decimalPlaces)}, ${bar.upperBound.toStringAsFixed(decimalPlaces)})';
          break;
        }
      }
      return category;
    }

    return withCategoricFromFormula('${name}_category', name, convert);
  }

  /// Returns a data frame from a full left join.
  Dataframe withLeftJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet();
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a data frame from a full right join.
  Dataframe withRightJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids = other.cats.containsKey(otherPivot)
        ? other.cats[otherPivot].toSet()
        : other.nums[otherPivot].toSet();
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a data frame from an inner join.
  Dataframe withInnerJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        (cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet())
            .intersection(other.cats.containsKey(otherPivot)
                ? other.cats[otherPivot].toSet()
                : other.nums[otherPivot].toSet());
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a data frame from a full join.
  Dataframe withFullJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids =
        (cats.containsKey(pivot) ? cats[pivot].toSet() : nums[pivot].toSet())
            .union(other.cats.containsKey(otherPivot)
                ? other.cats[otherPivot].toSet()
                : other.nums[otherPivot].toSet());
    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a data frame from an outer left join.
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

  /// Returns a data frame from an outer right join.
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

  /// Returns a data frame from an outer join.
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

  /// Returns a data frame with the rows of [other] added.
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

  /// TODO: document
  Dataframe withNullsDropped([List<String> columns]) {
    if (columns == null) {
      columns = columnNames;
    }

    var variableSet = Set<int>();
    for (final column in columns) {
      if (cats.containsKey(column)) {
        variableSet.addAll(cats[column].nullIndices);
      } else {
        variableSet.addAll(nums[column].nullIndices);
      }
    }

    final selectedIndices =
        indices.where((index) => !variableSet.contains(index)).toList();
    return withRowsAtIndices(selectedIndices)..columnsInOrder = columnsInOrder;
  }

  /// Gives a map of data frames grouped by category.
  Map<String, Dataframe> groupedByCategoric(String category) {
    if (!cats.containsKey(category)) {
      throw Exception('Unrecognized category: "$category".');
    }

    final values = cats[category].toSet();

    return Map<String, Dataframe>.fromIterable(values,
        value: (value) =>
            withRowsAtIndices(cats[category].indicesWhere((v) => v == value)));
  }

  /// Gives a map of data frames grouped by value.
  Map<num, Dataframe> groupedByNumeric(String numeric) {
    if (!nums.containsKey(numeric)) {
      throw Exception('Unrecognized numeric: "$numeric".');
    }

    final values = nums[numeric].toSet();

    return Map<num, Dataframe>.fromIterable(values,
        value: (value) =>
            withRowsAtIndices(nums[numeric].indicesWhere((v) => v == value)));
  }

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
          throw Exception('Unknown markdown alignment: "${alignment[key]}".');
        }
      }
    }

    final header = '|${columnNames.join('|')}|',
        alignmentSetting =
            '|${columnNames.map((key) => alignment[key]).join('|')}|',
        summarize = numberOfRows > 10 && summary,
        rows = (summarize
                ? indices
                    .where((index) => index < 5 || numberOfRows - index <= 5)
                : indices)
            .map((index) =>
                '|${columnNames.map((key) => table[key][index]).join('|')}|')
            .toList(),
        empty = '|${columnNames.map((_) => '...').join('|')}|';

    return summarize
        ? '''
$header
$alignmentSetting
${rows.sublist(0, 5).join('\n')}
$empty
${rows.sublist(5).join('\n')}

'''
        : '''
$header
$alignmentSetting
${rows.join('\n')}

''';
  }

  /// Gives a csv representation of this data frame.
  String toCsv({bool markColumns = false, int fixed}) {
    final table =
        Map<String, List<String>>.fromIterable(columnNames, key: (key) {
      if (markColumns) {
        if (cats.containsKey(key)) {
          // Mark the column as categoric.
          return '$key*';
        } else {
          // Mark the column as numeric.
          return '$key^';
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

    final header = '${table.keys.join(',')}',
        rows = indices
            .map((index) =>
                '${table.keys.map((key) => table[key][index]).join(',')}')
            .toList();

    return '''$header
${rows.join('\n')}
''';
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
        header = '<tr><th>${columnNames.join('</th><th>')}</th></tr>',
        rows = (summarize
                ? indices
                    .where((index) => index < 5 || numberOfRows - index <= 5)
                : indices)
            .map((index) =>
                '<tr><td>${columnNames.map((key) => table[key][index]).join('</td><td>')}</td></tr>')
            .toList(),
        empty =
            '<tr><td>${columnNames.map((_) => '...').join('</td><td>')}</td></tr>';

    return summarize
        ? '''
<table>
$header
${rows.sublist(0, 5).join('\n')}
$empty
${rows.sublist(5).join('\n')}
</table>
'''
        : '''
<table>
$header
${rows.join('\n')}
</table>
''';
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

  /// Gives a list of strings generated from the row values.
  List<String> toListOfStringsFromTemplate(String template,
          {String startQuote = '{',
          String endQuote = '}',
          String Function(String) generator}) =>
      generator == null
          ? _templateValues(template, startQuote, endQuote)
          : _templateValues(template, startQuote, endQuote)
              .map(generator)
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
            '${columnNames.map((key) => '-' * widths[key]).join(join)}',
        header =
            '|${columnNames.map((key) => '${key.padLeft(widths[key], ' ')}').join('|')}|',
        rows = sequence(numberOfRows)
            .map((index) =>
                '|${columnNames.map((key) => '${table[key][index].toString().padLeft(widths[key], ' ')}').join('|')}|')
            .join('\n');
    return '''
.${horizontalLine('.')}.
$header
:${horizontalLine('+')}:
$rows
'${horizontalLine("'")}'
''';
  }
}
