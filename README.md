# packhorse

Support for small to medium data manipulation and analysis projects, including numeric and categoric data list-like structures and data frames.

## Usage

A simple usage example:

```dart
import 'package:packhorse/packhorse.dart';

main() {
  final data = Dataframe
  // Read in the data.
  .fromCsv("""
    distance,percent
    0 to 1,22
    1 to 5,30
    6 to 10,17
    11 to 15,8
    16 to 20,6
    20 to 50,17
  """)
  // Add a numeric column from a template of categoric data.
  .withNumericFromTemplate("midpoint", "{distance}", (value) {
    final datum = value.split(" to "),
        lower = num.parse(datum.first),
        upper = num.parse(datum.last);
    return (lower + upper) / 2;
  })
  // Add a numeric column from a formula of numeric data.
  .withNumericFromFormula("contribution", "midpoint * percent / 100");

  print(data);
  print("Mean distance: ${data.nums["contribution"].sum}");
}
```

Output:

```
.--------.-------.--------.------------------.
|distance|percent|midpoint|      contribution|
:--------+-------+--------+------------------:
|  0 to 1|     22|     0.5|              0.11|
|  1 to 5|     30|     3.0|0.8999999999999999|
| 6 to 10|     17|     8.0|              1.36|
|11 to 15|      8|    13.0|              1.04|
|16 to 20|      6|    18.0|              1.08|
|20 to 50|     17|    35.0|              5.95|
'--------'-------'--------'------------------'

Mean distance: 10.440000000000001
```

Also provides support for more complicated manipulation, joins and filtering. See the [project wiki](https://bitbucket.org/ram6ler/packhorse/wiki/Home) for further information and examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://bitbucket.org/ram6ler/packhorse/issues).
