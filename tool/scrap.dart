import "package:packhorse/packhorse.dart";

main() {
  final categoric = Categoric("pack packhorse".split(""));
  categoric.counts.forEach((character, count) {
    print("'$character': $count");
  });
  print("Entropy: ${categoric.entropy}");
}
