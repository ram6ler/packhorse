import "package:packhorse/packhorse.dart";

main() {
  void dis(List<num> n) {
    print(n.map((x) => x.toString()).join("\t"));
  }

  final data = Numeric([0, 0, 0, 0, 0, 0, 2, 5, 8, 8, 8, 7, 8]);
  dis(data);
  dis(data.pScores);
  dis(data.pScoresIfNormal);

  final y = data.density();
  for (final x in List.generate(21, (i) => i * 0.5)) {
    print("${x.toStringAsFixed(1)} |${" " * (y(x) * 30).round()}:");
  }

  print([1, 2, 3].toNumeric());
}
