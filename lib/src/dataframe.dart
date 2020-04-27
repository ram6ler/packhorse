part of packhorse;

class Dataframe {
  /// Creates a data frame with `cats` and `nums` specified.
  Dataframe(Map<String, Categoric> cats, Map<String, Numeric> nums,
      List<String> columnsInOrder,
      {bool ignoreLengthMismatch = false}) {
    final lengths = {
      ...cats.values.map((value) => value.length),
      ...nums.values.map((value) => value.length)
    };

    if (!ignoreLengthMismatch && lengths.length != 1) {
      throw Exception('Columns not all of the same length.');
    }

    if (columnsInOrder != null) {
      this.columnsInOrder = [...columnsInOrder];
    }

    this.cats = {...cats};
    this.nums = {...nums};
  }

  /// An empty data frame.
  Dataframe.empty() {
    cats = <String, Categoric>{};
    nums = <String, Numeric>{};
  }

  /// Creates a data frame from a map of lists.
  ///
  /// The keys of the map are interpreted as the column names;
  /// the values in the respective lists populate the rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = Dataframe.fromMapOfLists({
  ///    'id': [3, 55, 114, 107, 122],
  ///    'species': ['setosa', 'versicolor', 'virginica', 'virginica', 'virginica'],
  ///    'sepal_length': [4.7, 6.5, 5.7, 4.9, 5.6],
  ///    'sepal_width': [3.2, 2.8, 2.5, 2.5, 2.8],
  ///    'petal_length': [1.3, 4.6, 5.0, 4.5, 4.9],
  ///    'petal_width': [0.2, 1.5, 2.0, 1.7, 2.0]});
  ///
  /// print(data);
  /// ```
  ///
  /// ```text
  /// .----------.---.------------.-----------.------------.-----------.
  /// |   species| id|sepal_length|sepal_width|petal_length|petal_width|
  /// :----------+---+------------+-----------+------------+-----------:
  /// |    setosa|  3|         4.7|        3.2|         1.3|        0.2|
  /// |versicolor| 55|         6.5|        2.8|         4.6|        1.5|
  /// | virginica|114|         5.7|        2.5|         5.0|        2.0|
  /// | virginica|107|         4.9|        2.5|         4.5|        1.7|
  /// | virginica|122|         5.6|        2.8|         4.9|        2.0|
  /// '----------'---'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe.fromMapOfLists(Map<String, List<Object>> data) {
    cats = {
      for (final key in data.keys)
        if (data[key].first is String)
          key: Categoric([for (final x in data[key]) x as String])
    };

    nums = {
      for (final key in data.keys)
        if (data[key].first is num)
          key: Numeric([for (final x in data[key]) x as num])
    };
  }

  /// Creates a data frame from a json string.
  ///
  /// The keys of the map are interpreted as the column names;
  /// the values in the respective lists populate the rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(Dataframe.fromJsonAsMapOfLists('''
  ///   {
  ///     "id":["3","4","5","6","53","54","55","56","103","104","105","106"],
  ///     "sepal_length":[4.7,4.6,5.0,5.4,6.9,5.5,6.5,5.7,7.1,6.3,6.5,7.6],
  ///     "sepal_width":[3.2,3.1,3.6,3.9,3.1,2.3,2.8,2.8,3.0,2.9,3.0,3.0]
  ///   }
  /// '''));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// ```
  ///
  factory Dataframe.fromJsonAsMapOfLists(String jsonString) =>
      jsonString.parseAsMapOfLists();

  /// Creates a data frame form a list of maps.
  ///
  /// Each map populates a row; the keys in each map determine
  /// the column each value should be put into.
  ///
  /// Example:
  ///
  /// ```dart
  /// final data = Dataframe.fromListOfMaps([
  ///   {'id': 103, 'species': 'virginica', 'petal_length': 5.9, 'petal_width': 2.1},
  ///   {'id': 53, 'species': 'versicolor', 'petal_length': 4.9, 'petal_width': 1.5},
  ///   {'id': 52, 'species': 'versicolor', 'petal_length': 4.5, 'petal_width': 1.5},
  ///   {'id': 101, 'species': 'virginica', 'petal_length': 6.0, 'petal_width': 2.5},
  ///   {'id': 4, 'species': 'setosa', 'petal_length': 1.5, 'petal_width': 0.2}]);
  ///
  /// print(data);
  /// ```
  ///
  /// ```text
  /// .----------.---.------------.-----------.
  /// |   species| id|petal_length|petal_width|
  /// :----------+---+------------+-----------:
  /// | virginica|103|         5.9|        2.1|
  /// |versicolor| 53|         4.9|        1.5|
  /// |versicolor| 52|         4.5|        1.5|
  /// | virginica|101|         6.0|        2.5|
  /// |    setosa|  4|         1.5|        0.2|
  /// '----------'---'------------'-----------'
  ///
  /// ```
  ///
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

  /// Creates a data fram from a json string.
  ///
  /// Each map in the list is interpreted as an instance.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(Dataframe.fromJsonAsListOfMaps('''
  ///   [
  ///       {
  ///           "id":"4",
  ///           "sepal_length":4.6,
  ///           "sepal_width":3.1
  ///       },{
  ///           "id":"53",
  ///           "sepal_length":6.9,
  ///           "sepal_width":3.1
  ///       },{
  ///           "id":"6",
  ///           "sepal_length":5.4,
  ///           "sepal_width":3.9
  ///       }
  ///   ]
  /// '''));
  /// ```
  ///
  /// ```text
  /// .--.------------.-----------.
  /// |id|sepal_length|sepal_width|
  /// :--+------------+-----------:
  /// | 4|         4.6|        3.1|
  /// |53|         6.9|        3.1|
  /// | 6|         5.4|        3.9|
  /// '--'------------'-----------'
  ///
  /// ```
  ///
  factory Dataframe.fromJsonAsListOfMaps(String jsonString) =>
      jsonString.parseAsListOfMaps();

  /// Creates a data frame from a csv expression.
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
  /// final data = Dataframe.fromCsv('''
  ///     id,sepal_length,sepal_width,petal_length,petal_width,species
  ///     57,6.3,3.3,4.7,1.6,versicolor
  ///     44,5.0,3.5,1.6,0.6,setosa
  ///     58,4.9,2.4,3.3,1.0,versicolor
  ///     68,5.8,2.7,4.1,1.0,versicolor
  ///     94,5.0,2.3,3.3,1.0,versicolor
  /// ''');
  ///
  /// print(data);
  /// ```
  ///
  /// ```text
  /// .--.------------.-----------.------------.-----------.----------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|   species|
  /// :--+------------+-----------+------------+-----------+----------:
  /// |57|         6.3|        3.3|         4.7|        1.6|versicolor|
  /// |44|         5.0|        3.5|         1.6|        0.6|    setosa|
  /// |58|         4.9|        2.4|         3.3|        1.0|versicolor|
  /// |68|         5.8|        2.7|         4.1|        1.0|versicolor|
  /// |94|         5.0|        2.3|         3.3|        1.0|versicolor|
  /// '--'------------'-----------'------------'-----------'----------'
  ///
  /// ```
  ///
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
    columnsInOrder = [
      ...lines.first
          .split(splitRe)
          .map((variable) => variable.replaceAll('"', '').trim())
    ];

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

    final mapOfValueStrings = {
      for (final key in columnsInOrder) key: <String>[]
    };

    for (final line in lines.sublist(1)) {
      final datum = [
        ...line.split(splitRe).map((value) => value.replaceAll('"', ''))
      ];
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

    cats = {
      for (final variable in categoricVariables)
        variable: Categoric(mapOfValueStrings[variable])
    };

    nums = {
      for (final variable in numericVariables)
        variable: Numeric(mapOfValueStrings[variable].map(num.tryParse))
    };
  }

  /// The categoric columns in this data frame.
  Map<String, Categoric> cats;

  /// The numeric columns in this data frame.
  Map<String, Numeric> nums;

  /// The order of the columns in displays.
  List<String> columnsInOrder = [];

  /// The names of the columns in this data frame.
  List<String> get columnNames => [
        ...columnsInOrder,
        ...cats.keys.where((key) => !columnsInOrder.contains(key)),
        ...nums.keys.where((key) => !columnsInOrder.contains(key))
      ];

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
  Map<String, Map<String, num>> get summary => {
        for (final key in cats.keys) key: cats[key].summary,
        ...{for (final key in nums.keys) key: nums[key].summary}
      };

  /// Returns a data frame with just the first, specified number of rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withHead(5));
  /// ```
  ///
  /// ```text
  /// .--.------------.-----------.------------.-----------.-------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species|
  /// :--+------------+-----------+------------+-----------+-------:
  /// | 1|         5.1|        3.5|         1.4|        0.2| setosa|
  /// | 2|         4.9|        3.0|         1.4|        0.2| setosa|
  /// | 3|         4.7|        3.2|         1.3|        0.2| setosa|
  /// | 4|         4.6|        3.1|         1.5|        0.2| setosa|
  /// | 5|         5.0|        3.6|         1.4|        0.3| setosa|
  /// '--'------------'-----------'------------'-----------'-------'
  ///
  /// ```
  ///
  Dataframe withHead([int n = 10]) =>
      withRowsAtIndices(indices.take(math.min(n, numberOfRows)));

  /// Returns a data frame with just the last, specified number of rows.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withTail(5));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.---------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|  species|
  /// :---+------------+-----------+------------+-----------+---------:
  /// |150|         5.9|        3.0|         5.1|        1.8|virginica|
  /// |149|         6.2|        3.4|         5.4|        2.3|virginica|
  /// |148|         6.5|        3.0|         5.2|        2.0|virginica|
  /// |147|         6.3|        2.5|         5.0|        1.9|virginica|
  /// |146|         6.7|        3.0|         5.2|        2.3|virginica|
  /// '---'------------'-----------'------------'-----------'---------'
  ///
  /// ```
  ///
  Dataframe withTail([int n = 10]) =>
      withRowsAtIndices(indices.reversed.take(math.min(n, numberOfRows)));

  /// Returns a data frame with the rows ordered by the values in the specified column.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withRowsOrderedBy('petal_width'));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 54|         4.0|        1.3|versicolor|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// |104|         5.6|        1.8| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |101|         6.0|        2.5| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// ```
  ///
  Dataframe withRowsOrderedBy(String column, {bool decreasing = false}) {
    var frame = Dataframe({...cats}, {...nums}, columnsInOrder);
    if (frame.cats.containsKey(column)) {
      frame = decreasing
          ? frame.withRowsAtIndices(frame.cats[column].orderedIndices.reversed)
          : frame.withRowsAtIndices(frame.cats[column].orderedIndices);
    } else if (frame.nums.containsKey(column)) {
      frame = decreasing
          ? frame.withRowsAtIndices(frame.nums[column].orderedIndices.reversed)
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
            ? [for (var _ = 0; _ < n; _++) rand.nextInt(numberOfRows)]
            : (indices..shuffle(rand)).sublist(0, n);
    return randomIndices;
  }

  /// Returns a data frame made up of rows randomly sampled from this data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withRowsSampled(5));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.----------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|   species|
  /// :---+------------+-----------+------------+-----------+----------:
  /// |136|         7.7|        3.0|         6.1|        2.3| virginica|
  /// |137|         6.3|        3.4|         5.6|        2.4| virginica|
  /// | 22|         5.1|        3.7|         1.5|        0.4|    setosa|
  /// | 70|         5.6|        2.5|         3.9|        1.1|versicolor|
  /// |139|         6.0|        3.0|         4.8|        1.8| virginica|
  /// '---'------------'-----------'------------'-----------'----------'
  ///
  /// ```
  ///
  Dataframe withRowsSampled(int n, {bool replacement = false, int seed}) =>
      withRowsAtIndices(
          sampleRowIndices(n, replacement: replacement, seed: seed));

  /// Returns a data frame with a row index column added.
  Dataframe withRowIndices(String name) => Dataframe({
        ...cats
      }, {
        ...nums,
        ...{name: Numeric(indices)}
      }, [
        name,
        ...columnsInOrder
      ]);

  /// Ckecks whether all [columns] are actually columns.
  void _validColumnCheck(List<String> columns) {
    for (final column in columns) {
      if (!(cats.containsKey(column) || nums.keys.contains(column))) {
        throw Exception('Unrecognized column: "$column"');
      }
    }
  }

  /// Returns a data frame with only the specified columns, in that order.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withColumns(['species', 'petal_length']));
  /// ```
  ///
  /// ```text
  /// .----------.------------.
  /// |   species|petal_length|
  /// :----------+------------:
  /// |    setosa|         1.4|
  /// |    setosa|         1.4|
  /// |    setosa|         1.3|
  /// |    setosa|         1.5|
  /// |versicolor|         4.7|
  /// |versicolor|         4.5|
  /// |versicolor|         4.9|
  /// |versicolor|         4.0|
  /// | virginica|         6.0|
  /// | virginica|         5.1|
  /// | virginica|         5.9|
  /// | virginica|         5.6|
  /// '----------'------------'
  ///
  /// ```
  ///
  Dataframe withColumns(List<String> columns) {
    _validColumnCheck(columns);
    final pipedCats = {...cats}
          ..removeWhere((key, _) => !columns.contains(key)),
        pipedNums = {...nums}..removeWhere((key, _) => !columns.contains(key));
    return Dataframe(pipedCats, pipedNums, columns);
  }

  /// Returns a data frame with the specified columns dropped.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withColumnsDropped(['id', 'petal_width']));
  /// ```
  ///
  /// ```text
  /// .------------.----------.
  /// |petal_length|   species|
  /// :------------+----------:
  /// |         1.4|    setosa|
  /// |         1.4|    setosa|
  /// |         1.3|    setosa|
  /// |         1.5|    setosa|
  /// |         4.7|versicolor|
  /// |         4.5|versicolor|
  /// |         4.9|versicolor|
  /// |         4.0|versicolor|
  /// |         6.0| virginica|
  /// |         5.1| virginica|
  /// |         5.9| virginica|
  /// |         5.6| virginica|
  /// '------------'----------'
  ///
  /// ```
  ///
  Dataframe withColumnsDropped(List<String> columns) {
    _validColumnCheck(columns);
    final pipedCats = {...cats}..removeWhere((key, _) => columns.contains(key)),
        pipedNums = {...nums}..removeWhere((key, _) => columns.contains(key));
    return Dataframe(pipedCats, pipedNums, [
      for (final column in columnsInOrder) if (!column.contains(column)) column
    ]);
  }

  /// Returns a data frame with the specified columns renamed.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withColumnNamesChanged({
  ///     'petal_length': 'length',
  ///     'petal_width': 'width'}));
  /// ```
  ///
  /// ```text
  /// .---.------.-----.----------.
  /// | id|length|width|   species|
  /// :---+------+-----+----------:
  /// |  1|   1.4|  0.2|    setosa|
  /// |  2|   1.4|  0.2|    setosa|
  /// |  3|   1.3|  0.2|    setosa|
  /// |  4|   1.5|  0.2|    setosa|
  /// | 51|   4.7|  1.4|versicolor|
  /// | 52|   4.5|  1.5|versicolor|
  /// | 53|   4.9|  1.5|versicolor|
  /// | 54|   4.0|  1.3|versicolor|
  /// |101|   6.0|  2.5| virginica|
  /// |102|   5.1|  1.9| virginica|
  /// |103|   5.9|  2.1| virginica|
  /// |104|   5.6|  1.8| virginica|
  /// '---'------'-----'----------'
  ///
  /// ```
  ///
  Dataframe withColumnNamesChanged(Map<String, String> names) {
    _validColumnCheck([...names.keys]);
    final changedCats = {...cats},
        changedNums = {...nums},
        order = [...columnsInOrder];

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

  /// Returns a data frame with only the predicated columns.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withColumnsWhere((column) => column.contains('petal')));
  /// ```
  ///
  /// ```text
  /// .------------.-----------.
  /// |petal_length|petal_width|
  /// :------------+-----------:
  /// |         1.4|        0.2|
  /// |         1.4|        0.2|
  /// |         1.3|        0.2|
  /// |         1.5|        0.2|
  /// |         4.7|        1.4|
  /// |         4.5|        1.5|
  /// |         4.9|        1.5|
  /// |         4.0|        1.3|
  /// |         6.0|        2.5|
  /// |         5.1|        1.9|
  /// |         5.9|        2.1|
  /// |         5.6|        1.8|
  /// '------------'-----------'
  ///
  /// ```
  ///
  Dataframe withColumnsWhere(bool Function(String) predicate) {
    final pipedCats = {...cats}..removeWhere((key, _) => !predicate(key)),
        pipedNums = {...nums}..removeWhere((key, _) => !predicate(key)),
        keys = [...pipedCats.keys, ...pipedNums.keys];
    return Dataframe(
        pipedCats, pipedNums, [...columnsInOrder.where(keys.contains)]);
  }

  /// Returns a data frame with only the rows at specified indices.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withRowsAtIndices([0, 20, 40]));
  /// ```
  ///
  /// ```text
  /// .--.------------.-----------.------------.-----------.-------.
  /// |id|sepal_length|sepal_width|petal_length|petal_width|species|
  /// :--+------------+-----------+------------+-----------+-------:
  /// | 1|         5.1|        3.5|         1.4|        0.2| setosa|
  /// |21|         5.4|        3.4|         1.7|        0.2| setosa|
  /// |41|         5.0|        3.5|         1.3|        0.3| setosa|
  /// '--'------------'-----------'------------'-----------'-------'
  ///
  /// ```
  ///
  Dataframe withRowsAtIndices(Iterable<int> indices) => Dataframe(
      {for (final key in cats.keys) key: cats[key].elementsAtIndices(indices)},
      {for (final key in nums.keys) key: nums[key].elementsAtIndices(indices)},
      columnsInOrder);

  /// A helper function that generates the values specified by a template.
  List<String> _templateValues(
          String template, String startQuote, String endQuote) =>
      [
        ...indices.map((index) {
          String argument = template;
          for (String key in cats.keys) {
            argument = argument.replaceAll(
                '$startQuote$key$endQuote', cats[key][index]);
          }
          for (String key in nums.keys) {
            argument = argument.replaceAll(
                '$startQuote$key$endQuote', nums[key][index].toString());
          }
          return argument;
        })
      ];

  /// A helper function that generates values from a formula.
  List<num> _formulaValues(String formula) {
    final f = formula.toMultiVariableFunction([...nums.keys]);
    return [
      ...indices.map((index) {
        final arguments = {for (final key in nums.keys) key: nums[key][index]};
        return f(arguments);
      })
    ];
  }

  /// Gives the indices that match a template predicate.
  List<int> indicesWhereTemplate(
      String template, bool Function(String) predicate,
      {String startQuote = '{', String endQuote = '}'}) {
    final templateValues = _templateValues(template, startQuote, endQuote);
    return [...indices.where((index) => predicate(templateValues[index]))];
  }

  Map<String, String> _catsMap(int index) =>
      {for (final key in cats.keys) key: cats[key][index]};

  Map<String, num> _numsMap(int index) =>
      {for (final key in nums.keys) key: nums[key][index]};

  /// Gives the indices of rows whose values match the defined predicate.
  List<int> indicesWhereRowValues(
      bool Function(Map<String, String>, Map<String, num>) predicate) {
    return [
      ...indices.where((index) {
        final catsMap = _catsMap(index), numsMap = _numsMap(index);
        return predicate(catsMap, numsMap);
      })
    ];
  }

  /// Returns a data frame with only the rows that match a template predicate.
  ///
  /// Example:
  ///
  /// ```dart
  /// final template = '{id}-{species}';
  /// print(petals.withRowsWhereTemplate(template,
  ///   (result) => result.contains('3') || result.contains('setosa')));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 53|         4.9|        1.5|versicolor|
  /// |103|         5.9|        2.1| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// ```
  ///
  Dataframe withRowsWhereTemplate(
          String template, bool Function(String) predicate,
          {String startQuote = '{', String endQuote = '}'}) =>
      withRowsAtIndices(indicesWhereTemplate(template, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// Gives the indices that match a formula predicate.
  List<int> indicesWhereFormula(String formula, bool Function(num) predicate) {
    final formulaValues = _formulaValues(formula);
    return [...indices.where((index) => predicate(formulaValues[index]))];
  }

  /// Returns a data frame with only the rows that match a formula predicate.
  ///
  /// Example:
  ///
  /// ```dart
  /// final formula = 'log(petal_length * petal_width)';
  /// print(petals.withRowsWhereFormula(formula, (result) => result < 0));
  /// ```
  ///
  /// ```text
  /// .--.------------.-----------.-------.
  /// |id|petal_length|petal_width|species|
  /// :--+------------+-----------+-------:
  /// | 1|         1.4|        0.2| setosa|
  /// | 2|         1.4|        0.2| setosa|
  /// | 3|         1.3|        0.2| setosa|
  /// | 4|         1.5|        0.2| setosa|
  /// '--'------------'-----------'-------'
  ///
  /// ```
  ///
  Dataframe withRowsWhereFormula(
          String formula, bool Function(num) predicate) =>
      withRowsAtIndices(indicesWhereFormula(formula, predicate));

  /// Gives the indices that match a template and formula predicate.
  List<int> indicesWhereTemplateAndFormula(
      String template, String formula, bool Function(String, num) predicate,
      {String startQuote = '{', String endQuote = '}'}) {
    final templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);

    return [
      ...indices.where(
          (index) => predicate(templateValues[index], formulaValues[index]))
    ];
  }

  /// Returns a data frame with only the rows that match a template and formula predicate.
  ///
  /// Example:
  ///
  /// ```dart
  /// final template = '{species}', formula = 'petal_length / petal_width';
  /// print(iris.withRowsWhereTemplateAndFormula(template, formula,
  ///   (templateResult, formulaResult) =>
  ///     templateResult == 'virginica' && formulaResult > 3));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.---------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|  species|
  /// :---+------------+-----------+------------+-----------+---------:
  /// |104|         6.3|        2.9|         5.6|        1.8|virginica|
  /// |106|         7.6|        3.0|         6.6|        2.1|virginica|
  /// |108|         7.3|        2.9|         6.3|        1.8|virginica|
  /// |109|         6.7|        2.5|         5.8|        1.8|virginica|
  /// |117|         6.5|        3.0|         5.5|        1.8|virginica|
  /// |118|         7.7|        3.8|         6.7|        2.2|virginica|
  /// |119|         7.7|        2.6|         6.9|        2.3|virginica|
  /// |120|         6.0|        2.2|         5.0|        1.5|virginica|
  /// |123|         7.7|        2.8|         6.7|        2.0|virginica|
  /// |126|         7.2|        3.2|         6.0|        1.8|virginica|
  /// |130|         7.2|        3.0|         5.8|        1.6|virginica|
  /// |131|         7.4|        2.8|         6.1|        1.9|virginica|
  /// |132|         7.9|        3.8|         6.4|        2.0|virginica|
  /// |134|         6.3|        2.8|         5.1|        1.5|virginica|
  /// |135|         6.1|        2.6|         5.6|        1.4|virginica|
  /// |138|         6.4|        3.1|         5.5|        1.8|virginica|
  /// '---'------------'-----------'------------'-----------'---------'
  ///
  /// ```
  ///
  Dataframe withRowsWhereTemplateAndFormula(
          String template, String formula, bool Function(String, num) predicate,
          {String startQuote = '{', String endQuote = '}'}) =>
      withRowsAtIndices(indicesWhereTemplateAndFormula(
          template, formula, predicate,
          startQuote: startQuote, endQuote: endQuote));

  /// Returns the data frame with only rows matched by the defined predicate.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(iris.withRowsWhereRowValues((cats, nums) =>
  ///   cats['species'] == 'virginica' && nums['petal_length'] > 6));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.---------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|  species|
  /// :---+------------+-----------+------------+-----------+---------:
  /// |106|         7.6|        3.0|         6.6|        2.1|virginica|
  /// |108|         7.3|        2.9|         6.3|        1.8|virginica|
  /// |110|         7.2|        3.6|         6.1|        2.5|virginica|
  /// |118|         7.7|        3.8|         6.7|        2.2|virginica|
  /// |119|         7.7|        2.6|         6.9|        2.3|virginica|
  /// |123|         7.7|        2.8|         6.7|        2.0|virginica|
  /// |131|         7.4|        2.8|         6.1|        1.9|virginica|
  /// |132|         7.9|        3.8|         6.4|        2.0|virginica|
  /// |136|         7.7|        3.0|         6.1|        2.3|virginica|
  /// '---'------------'-----------'------------'-----------'---------'
  ///
  /// ```
  ///
  Dataframe withRowsWhereRowValues(
          bool Function(Map<String, String>, Map<String, num>) predicate) =>
      withRowsAtIndices(indicesWhereRowValues(predicate));

  /// Returns a data frame with a categoric column inserted.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(sepals.withCategoricAdded('species', petals.cats['species']));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.
  /// | id|sepal_length|sepal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  3|         4.7|        3.2|    setosa|
  /// |  4|         4.6|        3.1|    setosa|
  /// |  5|         5.0|        3.6|    setosa|
  /// |  6|         5.4|        3.9|    setosa|
  /// | 53|         6.9|        3.1|versicolor|
  /// | 54|         5.5|        2.3|versicolor|
  /// | 55|         6.5|        2.8|versicolor|
  /// | 56|         5.7|        2.8|versicolor|
  /// |103|         7.1|        3.0| virginica|
  /// |104|         6.3|        2.9| virginica|
  /// |105|         6.5|        3.0| virginica|
  /// |106|         7.6|        3.0| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// ```
  ///
  Dataframe withCategoricAdded(String name, Categoric categoric) {
    if (categoric.length != numberOfRows) {
      throw Exception(
          'Expecting $numberOfRows values; got ${categoric.length}.');
    }
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedCats[name] = Categoric(categoric);
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric inserted.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withNumericAdded('sepal_length', sepals.nums['sepal_length']));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.------------.
  /// | id|petal_length|petal_width|   species|sepal_length|
  /// :---+------------+-----------+----------+------------:
  /// |  1|         1.4|        0.2|    setosa|         4.7|
  /// |  2|         1.4|        0.2|    setosa|         4.6|
  /// |  3|         1.3|        0.2|    setosa|         5.0|
  /// |  4|         1.5|        0.2|    setosa|         5.4|
  /// | 51|         4.7|        1.4|versicolor|         6.9|
  /// | 52|         4.5|        1.5|versicolor|         5.5|
  /// | 53|         4.9|        1.5|versicolor|         6.5|
  /// | 54|         4.0|        1.3|versicolor|         5.7|
  /// |101|         6.0|        2.5| virginica|         7.1|
  /// |102|         5.1|        1.9| virginica|         6.3|
  /// |103|         5.9|        2.1| virginica|         6.5|
  /// |104|         5.6|        1.8| virginica|         7.6|
  /// '---'------------'-----------'----------'------------'
  ///
  /// ```
  ///
  Dataframe withNumericAdded(String name, Numeric numeric) {
    if (numeric.length != numberOfRows) {
      throw Exception('Expecting $numberOfRows values; got ${numeric.length}.');
    }
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedNums[name] = Numeric(numeric);
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric based on an existing numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withNumericFromNumeric('petal_length_z', 'petal_length',
  ///   (result) => result.zScores));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.-------------------.
  /// | id|petal_length|petal_width|   species|     petal_length_z|
  /// :---+------------+-----------+----------+-------------------:
  /// |  1|         1.4|        0.2|    setosa| -1.350726370793662|
  /// |  2|         1.4|        0.2|    setosa| -1.350726370793662|
  /// |  3|         1.3|        0.2|    setosa|-1.4056711723174717|
  /// |  4|         1.5|        0.2|    setosa| -1.295781569269852|
  /// | 51|         4.7|        1.4|versicolor|  0.462452079492067|
  /// | 52|         4.5|        1.5|versicolor|  0.352562476444447|
  /// | 53|         4.9|        1.5|versicolor| 0.5723416825396871|
  /// | 54|         4.0|        1.3|versicolor|0.07783846882539718|
  /// |101|         6.0|        2.5| virginica| 1.1767344993015965|
  /// |102|         5.1|        1.9| virginica| 0.6822312855873066|
  /// |103|         5.9|        2.1| virginica| 1.1217896977777868|
  /// |104|         5.6|        1.8| virginica| 0.9569552932063564|
  /// '---'------------'-----------'----------'-------------------'
  ///
  /// ```
  ///
  Dataframe withNumericFromNumeric(String name, String existingNumericName,
          Numeric Function(Numeric numeric) generator) =>
      withNumericAdded(name, generator(nums[existingNumericName]));

  /// Returns a data frame with a numeric based on an existing categoric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final sample = iris.withRowsSampled(10, seed: 0);
  /// print(sample.withNumericFromCategoric('proportion', 'species',
  ///   (species) => Numeric(species.map((name) => species.proportions[name]))));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.----------.----------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|   species|proportion|
  /// :---+------------+-----------+------------+-----------+----------+----------:
  /// |111|         6.5|        3.2|         5.1|        2.0| virginica|       0.3|
  /// |147|         6.3|        2.5|         5.0|        1.9| virginica|       0.3|
  /// | 79|         6.0|        2.9|         4.5|        1.5|versicolor|       0.4|
  /// | 34|         5.5|        4.2|         1.4|        0.2|    setosa|       0.3|
  /// | 86|         6.0|        3.4|         4.5|        1.6|versicolor|       0.4|
  /// | 61|         5.0|        2.0|         3.5|        1.0|versicolor|       0.4|
  /// | 40|         5.1|        3.4|         1.5|        0.2|    setosa|       0.3|
  /// |119|         7.7|        2.6|         6.9|        2.3| virginica|       0.3|
  /// |  8|         5.0|        3.4|         1.5|        0.2|    setosa|       0.3|
  /// | 56|         5.7|        2.8|         4.5|        1.3|versicolor|       0.4|
  /// '---'------------'-----------'------------'-----------'----------'----------'
  ///
  /// ```
  ///
  Dataframe withNumericFromCategoric(String name, String existingCategoricName,
          Numeric Function(Categoric categoric) generator) =>
      withNumericAdded(name, generator(cats[existingCategoricName]));

  /// Returns a data frame with a categoric based on an existing numeric.
  ///
  /// Example:
  ///
  /// ```dart
  /// final sample = iris.withRowsSampled(10, seed: 0);
  /// print(sample.withCategoricFromNumeric('sepal_length_outlier', 'sepal_length',
  ///   (width) => Categoric(width.map((w) => width.outliers.contains(w) ? 'yes': 'no'))));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.----------.--------------------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|   species|sepal_length_outlier|
  /// :---+------------+-----------+------------+-----------+----------+--------------------:
  /// |111|         6.5|        3.2|         5.1|        2.0| virginica|                  no|
  /// |147|         6.3|        2.5|         5.0|        1.9| virginica|                  no|
  /// | 79|         6.0|        2.9|         4.5|        1.5|versicolor|                  no|
  /// | 34|         5.5|        4.2|         1.4|        0.2|    setosa|                  no|
  /// | 86|         6.0|        3.4|         4.5|        1.6|versicolor|                  no|
  /// | 61|         5.0|        2.0|         3.5|        1.0|versicolor|                  no|
  /// | 40|         5.1|        3.4|         1.5|        0.2|    setosa|                  no|
  /// |119|         7.7|        2.6|         6.9|        2.3| virginica|                 yes|
  /// |  8|         5.0|        3.4|         1.5|        0.2|    setosa|                  no|
  /// | 56|         5.7|        2.8|         4.5|        1.3|versicolor|                  no|
  /// '---'------------'-----------'------------'-----------'----------'--------------------'
  ///
  /// ```
  ///
  Dataframe withCategoricFromNumeric(String name, String existingNumericName,
          Categoric Function(Numeric numeric) generator) =>
      withCategoricAdded(name, generator(nums[existingNumericName]));

  /// Returns a data frame with a categoric based on an existing categoric.
  ///
  /// ```dart
  /// final sample = iris.withRowsSampled(10, seed: 0);
  /// print(sample.withCategoricFromCategoric('rarity', 'species',
  ///   (species) => Categoric(
  ///       species.map((s) => species.proportions[s] <= 0.3 ? 'rare': 'common'))));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.----------.------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|   species|rarity|
  /// :---+------------+-----------+------------+-----------+----------+------:
  /// |111|         6.5|        3.2|         5.1|        2.0| virginica|  rare|
  /// |147|         6.3|        2.5|         5.0|        1.9| virginica|  rare|
  /// | 79|         6.0|        2.9|         4.5|        1.5|versicolor|common|
  /// | 34|         5.5|        4.2|         1.4|        0.2|    setosa|  rare|
  /// | 86|         6.0|        3.4|         4.5|        1.6|versicolor|common|
  /// | 61|         5.0|        2.0|         3.5|        1.0|versicolor|common|
  /// | 40|         5.1|        3.4|         1.5|        0.2|    setosa|  rare|
  /// |119|         7.7|        2.6|         6.9|        2.3| virginica|  rare|
  /// |  8|         5.0|        3.4|         1.5|        0.2|    setosa|  rare|
  /// | 56|         5.7|        2.8|         4.5|        1.3|versicolor|common|
  /// '---'------------'-----------'------------'-----------'----------'------'
  ///
  /// ```
  ///
  Dataframe withCategoricFromCategoric(
          String name,
          String existingCategoricName,
          Categoric Function(Categoric categoric) generator) =>
      withCategoricAdded(name, generator(cats[existingCategoricName]));

  /// Returns a data frame with a new categoric column created from a template.
  ///
  /// Example:
  ///
  /// ```dart
  /// final template = '{species}-{id}';
  /// print(petals.withCategoricFromTemplate('id_code', template));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.-------------.
  /// | id|petal_length|petal_width|   species|      id_code|
  /// :---+------------+-----------+----------+-------------:
  /// |  1|         1.4|        0.2|    setosa|     setosa-1|
  /// |  2|         1.4|        0.2|    setosa|     setosa-2|
  /// |  3|         1.3|        0.2|    setosa|     setosa-3|
  /// |  4|         1.5|        0.2|    setosa|     setosa-4|
  /// | 51|         4.7|        1.4|versicolor|versicolor-51|
  /// | 52|         4.5|        1.5|versicolor|versicolor-52|
  /// | 53|         4.9|        1.5|versicolor|versicolor-53|
  /// | 54|         4.0|        1.3|versicolor|versicolor-54|
  /// |101|         6.0|        2.5| virginica|virginica-101|
  /// |102|         5.1|        1.9| virginica|virginica-102|
  /// |103|         5.9|        2.1| virginica|virginica-103|
  /// |104|         5.6|        1.8| virginica|virginica-104|
  /// '---'------------'-----------'----------'-------------'
  ///
  /// ```
  ///
  Dataframe withCategoricFromTemplate(String name, String template,
      {String startQuote = '{',
      String endQuote = '}',
      String Function(String) generator}) {
    generator = generator ?? (x) => x;
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedCats[name] = Categoric(
        _templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a new numeric column created from a template.
  ///
  /// Example:
  ///
  /// ```dart
  /// final template = '{species}';
  /// print(petals.withNumericFromTemplate('species_letters', template,
  ///   (result) => result.length));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.---------------.
  /// | id|petal_length|petal_width|   species|species_letters|
  /// :---+------------+-----------+----------+---------------:
  /// |  1|         1.4|        0.2|    setosa|              6|
  /// |  2|         1.4|        0.2|    setosa|              6|
  /// |  3|         1.3|        0.2|    setosa|              6|
  /// |  4|         1.5|        0.2|    setosa|              6|
  /// | 51|         4.7|        1.4|versicolor|             10|
  /// | 52|         4.5|        1.5|versicolor|             10|
  /// | 53|         4.9|        1.5|versicolor|             10|
  /// | 54|         4.0|        1.3|versicolor|             10|
  /// |101|         6.0|        2.5| virginica|              9|
  /// |102|         5.1|        1.9| virginica|              9|
  /// |103|         5.9|        2.1| virginica|              9|
  /// |104|         5.6|        1.8| virginica|              9|
  /// '---'------------'-----------'----------'---------------'
  ///
  /// ```
  ///
  Dataframe withNumericFromTemplate(
      String name, String template, num Function(String) generator,
      {String startQuote = '{', String endQuote = '}'}) {
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedNums[name] =
        Numeric(_templateValues(template, startQuote, endQuote).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a new categoric column created from a formula.
  ///
  /// Example:
  ///
  /// ```dart
  /// final formula = 'petal_width / petal_length';
  ///
  /// print(petals.withCategoricFromFormula('description', formula,
  ///   (result) => result < 0.3 ? 'narrow' : 'wide'));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.-----------.
  /// | id|petal_length|petal_width|   species|description|
  /// :---+------------+-----------+----------+-----------:
  /// |  1|         1.4|        0.2|    setosa|     narrow|
  /// |  2|         1.4|        0.2|    setosa|     narrow|
  /// |  3|         1.3|        0.2|    setosa|     narrow|
  /// |  4|         1.5|        0.2|    setosa|     narrow|
  /// | 51|         4.7|        1.4|versicolor|     narrow|
  /// | 52|         4.5|        1.5|versicolor|       wide|
  /// | 53|         4.9|        1.5|versicolor|       wide|
  /// | 54|         4.0|        1.3|versicolor|       wide|
  /// |101|         6.0|        2.5| virginica|       wide|
  /// |102|         5.1|        1.9| virginica|       wide|
  /// |103|         5.9|        2.1| virginica|       wide|
  /// |104|         5.6|        1.8| virginica|       wide|
  /// '---'------------'-----------'----------'-----------'
  ///
  /// ```
  ///
  Dataframe withCategoricFromFormula(
      String name, String formula, String Function(num) generator) {
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedCats[name] = Categoric(_formulaValues(formula).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a new numeric column created from a formula.
  ///
  /// Example:
  ///
  /// ```dart
  /// final formula = 'log(petal_length * petal_width)';
  ///
  /// print(petals.withNumericFromFormula('log_petal_area', formula));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.-------------------.
  /// | id|petal_length|petal_width|   species|     log_petal_area|
  /// :---+------------+-----------+----------+-------------------:
  /// |  1|         1.4|        0.2|    setosa|-1.2729656758128876|
  /// |  2|         1.4|        0.2|    setosa|-1.2729656758128876|
  /// |  3|         1.3|        0.2|    setosa|-1.3470736479666092|
  /// |  4|         1.5|        0.2|    setosa| -1.203972804325936|
  /// | 51|         4.7|        1.4|versicolor|  1.884034745337226|
  /// | 52|         4.5|        1.5|versicolor| 1.9095425048844386|
  /// | 53|         4.9|        1.5|versicolor| 1.9947003132247454|
  /// | 54|         4.0|        1.3|versicolor| 1.6486586255873816|
  /// |101|         6.0|        2.5| virginica|   2.70805020110221|
  /// |102|         5.1|        1.9| virginica| 2.2710944259026746|
  /// |103|         5.9|        2.1| virginica|  2.516889695641051|
  /// |104|         5.6|        1.8| virginica| 2.3105532626432224|
  /// '---'------------'-----------'----------'-------------------'
  ///
  /// ```
  ///
  Dataframe withNumericFromFormula(String name, String formula,
      {num Function(num) generator}) {
    generator = generator ?? (x) => x;
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedNums[name] = Numeric(_formulaValues(formula).map(generator));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a categoric column from a template and formula.
  Dataframe withCategoricFromTemplateAndFormula(String name, String template,
      String formula, String Function(String, num) generator,
      {String startQuote = '{', String endQuote = '}'}) {
    final pipedCats = {...cats},
        pipedNums = {...nums},
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
    final pipedCats = {...cats},
        pipedNums = {...nums},
        templateValues = _templateValues(template, startQuote, endQuote),
        formulaValues = _formulaValues(formula);
    pipedNums[name] = Numeric(indices.map(
        (index) => generator(templateValues[index], formulaValues[index])));
    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a new categoric column created from the row values.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.withCategoricFromRowValues('code',
  ///   (cats, nums) {
  ///       final pre = cats['species'].substring(0, 3),
  ///         area = (nums['petal_length'] * nums['petal_width'])
  ///           .toStringAsFixed(2).padLeft(5, '0');
  ///       return '$pre-$area';
  ///   }));
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.----------.---------.
  /// | id|petal_length|petal_width|   species|     code|
  /// :---+------------+-----------+----------+---------:
  /// |  1|         1.4|        0.2|    setosa|set-00.28|
  /// |  2|         1.4|        0.2|    setosa|set-00.28|
  /// |  3|         1.3|        0.2|    setosa|set-00.26|
  /// |  4|         1.5|        0.2|    setosa|set-00.30|
  /// | 51|         4.7|        1.4|versicolor|ver-06.58|
  /// | 52|         4.5|        1.5|versicolor|ver-06.75|
  /// | 53|         4.9|        1.5|versicolor|ver-07.35|
  /// | 54|         4.0|        1.3|versicolor|ver-05.20|
  /// |101|         6.0|        2.5| virginica|vir-15.00|
  /// |102|         5.1|        1.9| virginica|vir-09.69|
  /// |103|         5.9|        2.1| virginica|vir-12.39|
  /// |104|         5.6|        1.8| virginica|vir-10.08|
  /// '---'------------'-----------'----------'---------'
  ///
  /// ```
  ///
  Dataframe withCategoricFromRowValues(
      String name,
      String Function(Map<String, String> cats, Map<String, num> nums)
          generator) {
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedCats[name] = Categoric([
      for (final index in indices) generator(_catsMap(index), _numsMap(index))
    ]);

    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column from the row values.
  Dataframe withNumericFromRowValues(String name,
      num Function(Map<String, String> cats, Map<String, num> nums) generator) {
    final pipedCats = {...cats}, pipedNums = {...nums};
    pipedNums[name] = Numeric([
      for (final index in indices) generator(_catsMap(index), _numsMap(index))
    ]);

    return Dataframe(pipedCats, pipedNums, columnsInOrder);
  }

  /// Returns a data frame with a numeric column for each value in a categoric column.
  Dataframe withCategoricEnumerated(String name) {
    final pipedCats = {...cats},
        pipedNums = {...nums},
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

  /// Returns a left join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nLeft-join:');
  /// print(petals.withLeftJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Left-join:
  /// .---.----------.--------.------------.-----------.------------.-----------.
  /// | id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :---+----------+--------+------------+-----------+------------+-----------:
  /// |  1|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |  2|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |  3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
  /// |  4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
  /// | 51|versicolor|    null|         4.7|        1.4|        null|       null|
  /// | 52|versicolor|    null|         4.5|        1.5|        null|       null|
  /// | 53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
  /// | 54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
  /// |101| virginica|    null|         6.0|        2.5|        null|       null|
  /// |102| virginica|    null|         5.1|        1.9|        null|       null|
  /// |103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
  /// |104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
  /// '---'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withLeftJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids = cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]};

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a right join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nRight-join:');
  /// print(petals.withRightJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Right-join:
  /// .----.----------.--------.------------.-----------.------------.-----------.
  /// |  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :----+----------+--------+------------+-----------+------------+-----------:
  /// |   3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
  /// |   4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
  /// |null|      null|       5|        null|       null|         5.0|        3.6|
  /// |null|      null|       6|        null|       null|         5.4|        3.9|
  /// |  53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
  /// |  54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
  /// |null|      null|      55|        null|       null|         6.5|        2.8|
  /// |null|      null|      56|        null|       null|         5.7|        2.8|
  /// | 103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
  /// | 104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
  /// |null|      null|     105|        null|       null|         6.5|        3.0|
  /// |null|      null|     106|        null|       null|         7.6|        3.0|
  /// '----'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withRightJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids = other.cats.containsKey(otherPivot)
        ? {...other.cats[otherPivot]}
        : {...other.nums[otherPivot]};

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns an inner join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nInner-join:');
  /// print(petals.withInnerJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Inner-join:
  /// .---.----------.--------.------------.-----------.------------.-----------.
  /// | id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :---+----------+--------+------------+-----------+------------+-----------:
  /// |  3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
  /// |  4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
  /// | 53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
  /// | 54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
  /// |103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
  /// |104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
  /// '---'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withInnerJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final ids = (cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]})
        .intersection(other.cats.containsKey(otherPivot)
            ? {...other.cats[otherPivot]}
            : {...other.nums[otherPivot]});

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a full join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nFull-join:');
  /// print(petals.withFullJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Full-join:
  /// .----.----------.--------.------------.-----------.------------.-----------.
  /// |  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :----+----------+--------+------------+-----------+------------+-----------:
  /// |   1|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |   2|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |   3|    setosa|       3|         1.3|        0.2|         4.7|        3.2|
  /// |   4|    setosa|       4|         1.5|        0.2|         4.6|        3.1|
  /// |  51|versicolor|    null|         4.7|        1.4|        null|       null|
  /// |  52|versicolor|    null|         4.5|        1.5|        null|       null|
  /// |  53|versicolor|      53|         4.9|        1.5|         6.9|        3.1|
  /// |  54|versicolor|      54|         4.0|        1.3|         5.5|        2.3|
  /// | 101| virginica|    null|         6.0|        2.5|        null|       null|
  /// | 102| virginica|    null|         5.1|        1.9|        null|       null|
  /// | 103| virginica|     103|         5.9|        2.1|         7.1|        3.0|
  /// | 104| virginica|     104|         5.6|        1.8|         6.3|        2.9|
  /// |null|      null|       5|        null|       null|         5.0|        3.6|
  /// |null|      null|       6|        null|       null|         5.4|        3.9|
  /// |null|      null|      55|        null|       null|         6.5|        2.8|
  /// |null|      null|      56|        null|       null|         5.7|        2.8|
  /// |null|      null|     105|        null|       null|         6.5|        3.0|
  /// |null|      null|     106|        null|       null|         7.6|        3.0|
  /// '----'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withFullJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a = cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]},
        b = other.cats.containsKey(otherPivot)
            ? {...other.cats[otherPivot]}
            : {...other.nums[otherPivot]},
        ids = a.union(b);

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a left outer join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nLeft-outer-join:');
  /// print(petals.withLeftOuterJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Left-outer-join:
  /// .---.----------.--------.------------.-----------.------------.-----------.
  /// | id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :---+----------+--------+------------+-----------+------------+-----------:
  /// |  1|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |  2|    setosa|    null|         1.4|        0.2|        null|       null|
  /// | 51|versicolor|    null|         4.7|        1.4|        null|       null|
  /// | 52|versicolor|    null|         4.5|        1.5|        null|       null|
  /// |101| virginica|    null|         6.0|        2.5|        null|       null|
  /// |102| virginica|    null|         5.1|        1.9|        null|       null|
  /// '---'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withLeftOuterJoin(Dataframe other, String pivot,
      {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a = cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]},
        b = other.cats.containsKey(otherPivot)
            ? {...other.cats[otherPivot]}
            : {...other.nums[otherPivot]},
        ids = a.difference(b);

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a right outer join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nRight-outer-join:');
  /// print(petals.withRightOuterJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Right-outer-join:
  /// .----.-------.--------.------------.-----------.------------.-----------.
  /// |  id|species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :----+-------+--------+------------+-----------+------------+-----------:
  /// |null|   null|       5|        null|       null|         5.0|        3.6|
  /// |null|   null|       6|        null|       null|         5.4|        3.9|
  /// |null|   null|      55|        null|       null|         6.5|        2.8|
  /// |null|   null|      56|        null|       null|         5.7|        2.8|
  /// |null|   null|     105|        null|       null|         6.5|        3.0|
  /// |null|   null|     106|        null|       null|         7.6|        3.0|
  /// '----'-------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withRightOuterJoin(Dataframe other, String pivot,
      {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a = cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]},
        b = other.cats.containsKey(otherPivot)
            ? {...other.cats[otherPivot]}
            : {...other.nums[otherPivot]},
        ids = b.difference(a);

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns an outer join on the data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print('Left: petals sample:');
  /// print(petals);
  ///
  /// print('\nRight: sepals sample:');
  /// print(sepals);
  ///
  /// print('\nOuter-join:');
  /// print(petals.withOuterJoin(sepals, 'id'));
  /// ```
  ///
  /// ```text
  /// Left: petals sample:
  /// .---.------------.-----------.----------.
  /// | id|petal_length|petal_width|   species|
  /// :---+------------+-----------+----------:
  /// |  1|         1.4|        0.2|    setosa|
  /// |  2|         1.4|        0.2|    setosa|
  /// |  3|         1.3|        0.2|    setosa|
  /// |  4|         1.5|        0.2|    setosa|
  /// | 51|         4.7|        1.4|versicolor|
  /// | 52|         4.5|        1.5|versicolor|
  /// | 53|         4.9|        1.5|versicolor|
  /// | 54|         4.0|        1.3|versicolor|
  /// |101|         6.0|        2.5| virginica|
  /// |102|         5.1|        1.9| virginica|
  /// |103|         5.9|        2.1| virginica|
  /// |104|         5.6|        1.8| virginica|
  /// '---'------------'-----------'----------'
  ///
  /// Right: sepals sample:
  /// .---.------------.-----------.
  /// | id|sepal_length|sepal_width|
  /// :---+------------+-----------:
  /// |  3|         4.7|        3.2|
  /// |  4|         4.6|        3.1|
  /// |  5|         5.0|        3.6|
  /// |  6|         5.4|        3.9|
  /// | 53|         6.9|        3.1|
  /// | 54|         5.5|        2.3|
  /// | 55|         6.5|        2.8|
  /// | 56|         5.7|        2.8|
  /// |103|         7.1|        3.0|
  /// |104|         6.3|        2.9|
  /// |105|         6.5|        3.0|
  /// |106|         7.6|        3.0|
  /// '---'------------'-----------'
  ///
  /// Outer-join:
  /// .----.----------.--------.------------.-----------.------------.-----------.
  /// |  id|   species|other_id|petal_length|petal_width|sepal_length|sepal_width|
  /// :----+----------+--------+------------+-----------+------------+-----------:
  /// |   1|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |   2|    setosa|    null|         1.4|        0.2|        null|       null|
  /// |  51|versicolor|    null|         4.7|        1.4|        null|       null|
  /// |  52|versicolor|    null|         4.5|        1.5|        null|       null|
  /// | 101| virginica|    null|         6.0|        2.5|        null|       null|
  /// | 102| virginica|    null|         5.1|        1.9|        null|       null|
  /// |null|      null|       5|        null|       null|         5.0|        3.6|
  /// |null|      null|       6|        null|       null|         5.4|        3.9|
  /// |null|      null|      55|        null|       null|         6.5|        2.8|
  /// |null|      null|      56|        null|       null|         5.7|        2.8|
  /// |null|      null|     105|        null|       null|         6.5|        3.0|
  /// |null|      null|     106|        null|       null|         7.6|        3.0|
  /// '----'----------'--------'------------'-----------'------------'-----------'
  ///
  /// ```
  ///
  Dataframe withOuterJoin(Dataframe other, String pivot, {String otherPivot}) {
    otherPivot = otherPivot ?? pivot;
    final a = cats.containsKey(pivot) ? {...cats[pivot]} : {...nums[pivot]},
        b = other.cats.containsKey(otherPivot)
            ? {...other.cats[otherPivot]}
            : {...other.nums[otherPivot]},
        ids = a.union(b).difference(a.intersection(b));

    return _join(this, other, pivot, otherPivot, ids);
  }

  /// Returns a data frame with the rows of [other] added.
  ///
  /// Example:
  ///
  /// ```dart
  /// final headAndTail = iris.withHead(5).withDataAdded(iris.withTail(5));
  /// print(headAndTail);
  /// ```
  ///
  /// ```text
  /// .---.------------.-----------.------------.-----------.---------.
  /// | id|sepal_length|sepal_width|petal_length|petal_width|  species|
  /// :---+------------+-----------+------------+-----------+---------:
  /// |  1|         5.1|        3.5|         1.4|        0.2|   setosa|
  /// |  2|         4.9|        3.0|         1.4|        0.2|   setosa|
  /// |  3|         4.7|        3.2|         1.3|        0.2|   setosa|
  /// |  4|         4.6|        3.1|         1.5|        0.2|   setosa|
  /// |  5|         5.0|        3.6|         1.4|        0.3|   setosa|
  /// |150|         5.9|        3.0|         5.1|        1.8|virginica|
  /// |149|         6.2|        3.4|         5.4|        2.3|virginica|
  /// |148|         6.5|        3.0|         5.2|        2.0|virginica|
  /// |147|         6.3|        2.5|         5.0|        1.9|virginica|
  /// |146|         6.7|        3.0|         5.2|        2.3|virginica|
  /// '---'------------'-----------'------------'-----------'---------'
  ///
  /// ```
  ///
  Dataframe withDataAdded(Dataframe other) {
    final nNulls = <T>(int n) => List<T>.filled(n, null),
        catsKeysSet = {...cats.keys, ...other.cats.keys},
        combinedCats = {
      for (final key in catsKeysSet)
        key: Categoric([
          if (cats.containsKey(key))
            ...cats[key]
          else
            ...nNulls<String>(numberOfRows),
          if (other.cats.containsKey(key))
            ...other.cats[key]
          else
            ...nNulls<String>(other.numberOfRows)
        ])
    },
        numsKeysSet = {...nums.keys, ...other.nums.keys},
        combinedNums = {
      for (final key in numsKeysSet)
        key: Numeric([
          if (nums.containsKey(key))
            ...nums[key]
          else
            ...nNulls<num>(numberOfRows),
          if (other.nums.containsKey(key))
            ...other.nums[key]
          else
            ...nNulls<num>(other.numberOfRows)
        ])
    };

    return Dataframe(combinedCats, combinedNums, [...columnsInOrder]);
  }

  /// Returns a data frame with all rows containing nulls dropped.
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

    final selectedIndices = [
      ...indices.where((index) => !variableSet.contains(index))
    ];

    return withRowsAtIndices(selectedIndices)..columnsInOrder = columnsInOrder;
  }

  /// Gives a map of data frames grouped by category.
  Map<String, Dataframe> groupedByCategoric(String category) {
    if (!cats.containsKey(category)) {
      throw Exception('Unrecognized category: "$category".');
    }

    final values = {...cats[category]};

    return {
      for (final value in values)
        value: withRowsAtIndices(
            cats[category].indicesWhere((rowValue) => rowValue == value))
    };
  }

  /// Gives a map of data frames grouped by value.
  Map<num, Dataframe> groupedByNumeric(String numeric) {
    if (!nums.containsKey(numeric)) {
      throw Exception('Unrecognized numeric: "$numeric".');
    }

    final values = {...nums[numeric]};

    return {
      for (final value in values)
        value: withRowsAtIndices(
            nums[numeric].indicesWhere((rowValue) => rowValue == value))
    };
  }

  /// Returns an object containing the data in the specified row
  ///
  /// The returned object has map properties `cats` and `nums` with the
  /// categorical and numerical row data respectively.
  ///
  /// Example:
  ///
  /// ```dart
  /// final rowData = petals.getRowValues(0);
  /// print(rowData);
  /// ```
  ///
  /// ```text
  /// cats:
  ///   id: 1
  ///   species: setosa
  /// nums:
  ///   petal_length: 1.4
  ///   petal_width: 0.2
  ///
  /// ```
  RowValues getRowValues(int index) => RowValues(
      {for (final key in cats.keys) key: cats[key][index]},
      {for (final key in nums.keys) key: nums[key][index]});

  void setRowValues(int index, RowValues rowValues) {
    for (final key in rowValues.cats.keys) {
      cats[key][index] = rowValues.cats[key];
    }

    for (final key in rowValues.nums.keys) {
      nums[key][index] = rowValues.nums[key];
    }
  }

  void performRowOperations(List<RowOperation> operations) {
    final indexExtractor = RegExp(r'\[([0-9]+)\]'),
        output = {
      for (final operation in operations)
        operation.destinationRowIndex: {
          for (final key in nums.keys)
            key: operation.expression
                .replaceAllMapped(
                    indexExtractor,
                    (match) => '${() {
                          final value = nums[key][int.tryParse(match.group(1))];
                          return value < 0 ? '($value)' : '$value';
                        }()}')
                .interpret()
        }
    };

    output.forEach((index, map) {
      map.forEach((variable, value) {
        nums[variable][index] = value;
      });
    });
  }

  /// Gives a markdown representation of this data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.toMarkdown());
  /// ```
  ///
  /// ```text
  /// |id|petal_length|petal_width|species|
  /// |:--:|:--:|:--:|:--:|
  /// |1|1.4|0.2|setosa|
  /// |2|1.4|0.2|setosa|
  /// |3|1.3|0.2|setosa|
  /// |4|1.5|0.2|setosa|
  /// |51|4.7|1.4|versicolor|
  /// |52|4.5|1.5|versicolor|
  /// |53|4.9|1.5|versicolor|
  /// |54|4.0|1.3|versicolor|
  /// |101|6.0|2.5|virginica|
  /// |102|5.1|1.9|virginica|
  /// |103|5.9|2.1|virginica|
  /// |104|5.6|1.8|virginica|
  ///
  /// ```
  ///
  String toMarkdown(
      {Map<String, String> alignment, bool summary = false, int fixed}) {
    alignment = alignment ?? <String, String>{};

    _validColumnCheck([...alignment.keys]);

    final table = {
      for (final key in columnNames)
        key: cats.containsKey(key)
            ? cats[key]
            : [for (final x in nums[key]) x.toString()]
    };

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
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.toCsv());
  /// ```
  ///
  /// ```text
  /// id,petal_length,petal_width,species
  /// 1,1.4,0.2,setosa
  /// 2,1.4,0.2,setosa
  /// 3,1.3,0.2,setosa
  /// 4,1.5,0.2,setosa
  /// 51,4.7,1.4,versicolor
  /// 52,4.5,1.5,versicolor
  /// 53,4.9,1.5,versicolor
  /// 54,4.0,1.3,versicolor
  /// 101,6.0,2.5,virginica
  /// 102,5.1,1.9,virginica
  /// 103,5.9,2.1,virginica
  /// 104,5.6,1.8,virginica
  ///
  /// ```
  ///
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
        return [
          for (final x in nums[key])
            fixed == null ? x.toString() : x.toStringAsFixed(fixed)
        ];
      }
    });

    final header = '${table.keys.join(',')}',
        rows = [
      ...indices.map(
          (index) => '${table.keys.map((key) => table[key][index]).join(',')}')
    ];

    return '''$header
${rows.join('\n')}
''';
  }

  /// Returns a json representation of the data frame.
  ///
  /// The json represents a single list of maps representing instances.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(sepals.withHead(2).toJsonAsListOfMaps());
  /// ```
  ///
  /// ```text
  /// [{"id":"3","sepal_length":4.7,"sepal_width":3.2},{"id":"4","sepal_length":4.6,"sepal_width":3.1}]
  /// ```
  ///
  String toJsonAsListOfMaps() => json.encode(toListOfMaps());

  /// Returns a json representation of the data frame.
  ///
  /// The json represents a map with keys corresponding to column names
  /// and lists as values corresponding to row data.
  ///
  /// Example
  ///
  /// ```dart
  /// print(sepals.withHead(2).toJsonAsMapOfLists());
  /// ```
  ///
  /// ```text
  /// {"id":["3","4"],"sepal_length":[4.7,4.6],"sepal_width":[3.2,3.1]}
  /// ```
  ///
  String toJsonAsMapOfLists() => json.encode(toMapOfLists());

  /// Gives an html table representation of this data frame.
  ///
  /// Example:
  ///
  /// ```dart
  /// print(petals.toHtml());
  /// ```
  ///
  /// ```text
  /// <table>
  /// <tr><th>id</th><th>petal_length</th><th>petal_width</th><th>species</th></tr>
  /// <tr><td>1</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
  /// <tr><td>2</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
  /// <tr><td>3</td><td>1.3</td><td>0.2</td><td>setosa</td></tr>
  /// <tr><td>4</td><td>1.5</td><td>0.2</td><td>setosa</td></tr>
  /// <tr><td>51</td><td>4.7</td><td>1.4</td><td>versicolor</td></tr>
  /// <tr><td>52</td><td>4.5</td><td>1.5</td><td>versicolor</td></tr>
  /// <tr><td>53</td><td>4.9</td><td>1.5</td><td>versicolor</td></tr>
  /// <tr><td>54</td><td>4.0</td><td>1.3</td><td>versicolor</td></tr>
  /// <tr><td>101</td><td>6.0</td><td>2.5</td><td>virginica</td></tr>
  /// <tr><td>102</td><td>5.1</td><td>1.9</td><td>virginica</td></tr>
  /// <tr><td>103</td><td>5.9</td><td>2.1</td><td>virginica</td></tr>
  /// <tr><td>104</td><td>5.6</td><td>1.8</td><td>virginica</td></tr>
  /// </table>
  ///
  /// ```
  ///
  String toHtml({bool summary = false, int fixed}) {
    final table = {
      for (final key in columnNames)
        key: cats.containsKey(key)
            ? cats[key]
            : [
                for (final x in nums[key])
                  fixed == null ? x.toString() : x.toStringAsFixed(fixed)
              ]
    };

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
  Map<String, _Column> toMapOfLists() => {
        for (final key in columnNames)
          key: cats.containsKey(key) ? cats[key] : nums[key]
      };

  Map<String, Object> _rowMap(int index) => {
        ...{for (final key in cats.keys) key: cats[key][index]},
        ...{for (final key in nums.keys) key: nums[key][index]}
      };

  /// Gives a list of maps, each map representing a row.
  List<Map<String, Object>> toListOfMaps() =>
      [for (final index in indices) _rowMap(index)];

  /// Gives a list of strings generated from the row values.
  List<String> toListOfStringsFromTemplate(String template,
          {String startQuote = '{',
          String endQuote = '}',
          String Function(String) generator}) =>
      generator == null
          ? _templateValues(template, startQuote, endQuote)
          : [..._templateValues(template, startQuote, endQuote).map(generator)];

  /// Gives a string representation of this data frame.
  @override
  String toString() {
    final table = {
      for (final key in columnNames)
        key: cats.containsKey(key)
            ? cats[key]
            : [for (final x in nums[key]) x.toString()]
    },
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
