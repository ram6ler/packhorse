import 'package:packhorse/packhorse.dart' as ph;

main() {
  final df = ph.Dataframe.fromCsv("""
  a,b,c,d,e
  1,5,-3,hello,blue
  2,1,0,bye,orange
  4,9,-1,salve,purple
  hello,5,2,ola,green
  """).withNullsDropped(); //.withColumns(["e", "b", "c"]);
  print(df);
}
