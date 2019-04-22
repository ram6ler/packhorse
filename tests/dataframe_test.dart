import 'package:packhorse/packhorse.dart';

main() {
  final data = Dataframe.fromCsv("""
    distance,percent
    0 to 1,22
    1 to 5,30
    6 to 10,17
    11 to 15,8
    16 to 20,6
    20 to 50,17
  """).withNumericFromTemplate("midpoint", "{distance}", (value) {
    final datum = value.split(" to "),
        lower = num.parse(datum.first),
        upper = num.parse(datum.last);
    return (lower + upper) / 2;
  }).withNumericFromFormula("contribution", "midpoint * percent / 100");

  print(data);
  print("Mean distance: ${data.nums["contribution"].sum}");
}
