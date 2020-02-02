```dart
final matrix = Dataframe.fromCsv('''
a,b,c,d
5,-3,2,3
2,4,-1,7
1,-11,4,3
''');

for (final operations in [
    [
      RowOperation('[2]', 0),
      RowOperation('[0]', 2)
    ],
    [
      RowOperation('[1]-2*[0]', 1),
      RowOperation('[2]-5*[0]', 2)
    ],
    [
      RowOperation('[2]-2*[1]', 2)
    ]
  ]) {
    matrix.performRowOperations(operations);
    print('${operations.map((op) => '${op.expression} -> ${op.destinationRowIndex}')}: ');
    print(matrix);
  }
```

```text
([2] -> 0, [0] -> 2): 
.-.---.--.-.
|a|  b| c|d|
:-+---+--+-:
|1|-11| 4|3|
|2|  4|-1|7|
|5| -3| 2|3|
'-'---'--'-'

([1]-2*[0] -> 1, [2]-5*[0] -> 2): 
.-.---.---.---.
|a|  b|  c|  d|
:-+---+---+---:
|1|-11|  4|  3|
|0| 26| -9|  1|
|0| 52|-18|-12|
'-'---'---'---'

([2]-2*[1] -> 2): 
.-.---.--.---.
|a|  b| c|  d|
:-+---+--+---:
|1|-11| 4|  3|
|0| 26|-9|  1|
|0|  0| 0|-14|
'-'---'--'---'

```

