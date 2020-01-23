part of packhorse;

abstract class ColumnType {
  static const categoric = 'cat', numeric = 'num';
}

abstract class Alignment {
  static const left = ':--', right = '--:', center = ':--:';
}

class RowValues {
  Map<String, String> cats;
  Map<String, num> nums;

  RowValues(this.cats, this.nums);

  @override
  String toString() => '''
cats:
${[for (final key in cats.keys) '  $key: ${cats[key]}'].join('\n')}  
nums:
${[for (final key in nums.keys) '  $key: ${nums[key]}'].join('\n')}
  ''';
}

/// Generalized join helper function.
Dataframe _join(Dataframe left, Dataframe right, String leftPivot,
    String rightPivot, Set<Object> ids) {
  if (![left.cats.keys, left.nums.keys]
      .any((keys) => keys.contains(leftPivot))) {
    throw Exception('Unrecognized pivot: "$leftPivot".');
  }
  if (![right.cats.keys, right.nums.keys]
      .any((keys) => keys.contains(rightPivot))) {
    throw Exception('Unrecognized pivot: "$rightPivot".');
  }

  final leftCats = Map<String, List<String>>.fromIterable(left.cats.keys,
          value: (_) => []),
      rightCats = Map<String, List<String>>.fromIterable(right.cats.keys,
          value: (_) => []),
      leftNums =
          Map<String, List<num>>.fromIterable(left.nums.keys, value: (_) => []),
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
            key: (key) => leftCats.keys.contains(key) ? 'other_$key' : key,
            value: (key) => Categoric(rightCats[key]))),
      nums = Map<String, Numeric>.fromIterable(leftNums.keys,
          value: (key) => Numeric(leftNums[key]))
        ..addAll(Map<String, Numeric>.fromIterable(rightNums.keys,
            key: (key) => leftNums.keys.contains(key) ? 'other_$key' : key,
            value: (key) => Numeric(rightNums[key])));

  return Dataframe(cats, nums, []);
}
