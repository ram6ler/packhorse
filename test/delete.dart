import 'package:packhorse/packhorse.dart';

main() {
  final data = {
    'a': [1, 2, 3],
    'b': ['red', 'blue', 'blue']
  }.toDataframe();
  print(data);
}
