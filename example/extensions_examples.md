
# Extensions

## Lists

Lists to Numerics:

```dart
final numeric = [1, 2, 3].toNumeric();
print(numeric);
print(numeric.mean);
```

```text
[1, 2, 3]
2.0
```

Lists to Categorics:

```dart
final categoric = ['red', 'blue', 'blue'].toCategoric();
print(categoric);
categoric.proportions.forEach((value, p) {
  print('  $value: $p');
});
```

```text
[red, blue, blue]
  blue: 0.6666666666666666
  red: 0.3333333333333333
```

## Map with variable keys

```dart
final data = {
    'a': [1, 2, 3], 
    'b': ['red', 'blue', 'blue']
  }.toDataframe();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

```

## List of instances

```dart
final data = [
    {'a': 1, 'b': 'red'},
    {'a': 2, 'b': 'blue'},
    {'a': 3, 'b': 'blue'}
  ].toDataframe();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

```

## Strings

### csv content:

```dart
final data = '''
  a,b
  1,red
  2,blue
  3,blue
'''.parseAsCsv();

print(data);
```

```text
.-.----.
|a|   b|
:-+----:
|1| red|
|2|blue|
|3|blue|
'-'----'

```

### Json / map of lists:

```dart
final data = '''
  {
    "a": [1, 2, 3],
    "b": ["red", "blue", "blue"]
  }
'''.parseAsMapOfLists();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

```

### Json / list of maps:

```dart
final data = '''
  [
    {"a": 1, "b": "red"},
    {"a": 2, "b": "blue"},
    {"a": 3, "b": "blue"}
  ]
'''.parseAsListOfMaps();

print(data);
```

```text
.----.-.
|   b|a|
:----+-:
| red|1|
|blue|2|
|blue|3|
'----'-'

```

