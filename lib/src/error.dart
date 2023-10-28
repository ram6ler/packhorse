final class PackhorseError extends Error {
  PackhorseError.badColumnName(String name)
      : message = "Bad column name: '$name'";

  PackhorseError.badArgument(String hint) : message = "Bad argument: $hint";

  PackhorseError.badStructure(String hint) : message = "Bad structure: $hint";

  final String message;

  @override
  String toString() => "* Packhorse Error:\n  $message\n";
}
