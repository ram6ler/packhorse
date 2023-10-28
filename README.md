# ![Packhorse](pics/packhorse-banner.png)

Welcome to *packhorse*, a library supporting small to medium data manipulation and analysis projects, either at the client or server level.

Packhorse gives us access to several classes that allow us to easily define new tables and columns, extract commonly used statistics, perform structural manipulations such as joins, and export data to a variety of forms, such as csv, html and json.

## Example

```dart
final rectPart1 = """
   id,length,color
   0,12,red
   1,15,blue
   2,6,green
   3,10,blue
   4,5,green
""".parseAsCsv(),
    rectPart2 = {
      "id": [0, 1, 2, 3, 4],
      "width": [4, 9, 3, 2, 10],
    }.toDataFrame();

print(
  rectPart1
      .withInnerJoinOn(
        rectPart2,
        pivot: "id",
      )
      .withNumericColumnFromFormula(
        name: "area",
        formula: "length * width",
      )
      .withCategoricColumnFromRowValues(
        name: "desc",
        generator: (numeric, categoric) =>
            (numeric["area"]! > 25 ? "large-" : "small-") +
            categoric["color"]!,
      ),
);
```

```text
.--.------.--------.-----.----.-------.-------------.
|id|length|right_id|width|area|color  |desc         |
:--+------+--------+-----+----+-------+-------------:
|0 |12    |0       |4    |48  |red    |large-red    |
|1 |15    |1       |9    |135 |blue   |large-blue   |
|2 |6     |2       |3    |18  |green  |small-green  |
|3 |10    |3       |2    |20  |blue   |small-blue   |
|4 |5     |4       |10   |50  |green  |large-green  |
'--'------'--------'-----'----'-------'-------------'
```

Take a look at the examples in `example/example.md` for a quick overview.

Thanks for your interest in this library. Please [file bugs, issues and requests here](https://github.com/ram6ler/packhorse/issues).
