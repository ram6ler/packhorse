import "dart:io";
import "package:packhorse/packhorse.dart";

main() async {
  final petals = Dataframe.fromCsv(
          await File("data/iris_petals_sample.csv").readAsString()),
      sepals = Dataframe.fromCsv(
          await File("data/iris_sepals_sample.csv").readAsString());

  // CODE
}