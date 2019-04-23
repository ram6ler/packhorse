# Packhorse

[Home](Home.md) | [Numeric](numeric.md) | [Categoric](categoric.md) | [Dataframe](dataframe.md) | [About](about.md)



Welcome to *packhorse*, a library that supports basic analysis for small to medium data projects.

## To use packhorse:

Add it to your pubspec dependencies:

```
dependencies:
  packhorse: any
```

or

```
dependencies:
  packhorse:
    git: https://ram6ler@bitbucket.org/ram6ler/packhorse.git
```

Import the library:

```
import 'package:packhorse/packhorse.dart';
```

## What is packhorse?

A library that supports small to medium data manipulation and analysis projects via the following classes:

### Numeric

Instances of `Numeric` are list-like structures for numeric data, with properties and methods commonly used in data analysis.

Example:

```dart
final numeric = Numeric([4.57, 5.62, 4.12, 5.29, 4.64, 4.31]);
print("Variance: ${numeric.variance}");
```

```text
Variance: 0.28051388888888895

```

See the [Numeric page](numeric.md) for more!

### Categoric

Instances of `Categoric` are list-like structures for categoric data, with properties and methods commonly used in data analysis.

Example:

```dart
final categoric = Categoric("pack packhorse!".split(""));
print("Entropy: ${categoric.entropy}");
```

```text
Entropy: 2.338371704803573

```

See the [Categoric page](categoric.md) for more!

### Dataframe

Instances of `Dataframe` are objects containing maps of `Categoric`s (`cats`) and `Numeric`s (`nums`) that may be interpreted as data frames or tables of data, with each column a variable (categorization or measure) and each row an instance.

See the [Dataframe page](dataframe.md) for more!
