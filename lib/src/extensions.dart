part of packhorse;

extension NumListExtensions on List<num> {
  Numeric toNumeric() => Numeric(this);
}

extension StringListExtensions on List<String> {
  Categoric toCategoric() => Categoric(Categoric(this));
}

extension DataStringExtensions on String {
  Dataframe parseAsCsv({String seperator = ",", Map<String, String> types}) =>
      Dataframe.fromCsv(this, seperator: seperator, types: types);
}
