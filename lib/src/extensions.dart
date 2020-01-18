part of packhorse;

extension IntListExtensions on List<num> {
  Numeric toNumeric() => Numeric(this);
}

extension StringListExtensions on List<String> {
  Categoric toCategoric() => Categoric(Categoric(this));
}

extension DataListExtensions on List<Map<String, Object>> {
  Dataframe toDataframe() => Dataframe.fromListOfMaps(this);
}

extension DataMapExtensions on Map<String, List<Object>> {
  Dataframe toDataframe() => Dataframe.fromMapOfLists(this);
}

extension DataStringExtensions on String {
  Dataframe parseAsCsv({String seperator = ',', Map<String, String> types}) =>
      Dataframe.fromCsv(this, seperator: seperator, types: types);

  Dataframe parseAsMapOfLists() => Dataframe.fromMapOfLists(
      Map<String, List<Object>>.from(json.decode(this)));

  Dataframe parseAsListOfMaps() => Dataframe.fromListOfMaps(
      List<Map<String, Object>>.from(json.decode(this)));
}
