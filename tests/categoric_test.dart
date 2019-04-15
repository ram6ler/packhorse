import 'package:packhorse/packhorse.dart';

main() {
  final data = Categoric("${"a" * 19}${"b" * 21}${"c" * 40}".split(""),
      withCategories: ["a", "b", "c", "d"]);
  print(data.impurity);
  print(data.entropy);
}
