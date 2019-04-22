import "dart:io";

/// Reads through a markdown file,
/// executes code contained in code blocks
/// (```) and adds the execution output
/// to the output markdown.
///
/// Example usage:
///
/// ```
/// dart generate_docs.dart input/with_code.md > output/with_code_output.md
/// ```
///

main(List<String> args) async {
  print(await File("templates/header.md").readAsString());
  var coding = false,
      buffer = StringBuffer(),
      codeTemplate = await File("templates/code_template.dart").readAsString(),
      outTemplate = await File("templates/output_template.md").readAsString();
  for (final line in await (File("${args.first}").readAsLines())) {
    print(line);
    if (coding) {
      if (line.contains("```")) {
        final sink = File("_temp").openWrite();

        sink.writeln(codeTemplate.replaceFirst("// CODE", buffer.toString()));
        await sink.close();

        final results = await Process.run("dart", ["_temp"]);
        if (results.stdout != "") {
          print(outTemplate.replaceAll("// OUT", results.stdout.toString()));
        }
        await Process.run("rm", ["_temp"]);

        buffer.clear();
        coding = false;
      } else {
        buffer.writeln(line);
      }
    } else {
      if (line.contains("```dart")) {
        coding = true;
      }
    }
  }
}
