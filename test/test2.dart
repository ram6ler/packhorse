import "dart:io";
import 'package:packhorse/packhorse.dart';

main() async {
  final data = Dataframe.fromCsv(await File("test.csv").readAsString());
  print(data);
}
