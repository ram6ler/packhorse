import "package:packhorse/packhorse.dart";

main() {
  void dis(List<num> n) {
    print(n.map((x) => x.toString()).join("\t"));
  }

  final data = Numeric([1, 5, 0, 3, 2]);
  dis(data);
  dis(data.pScores);
  dis(data.pScoresIfNormal);
}
