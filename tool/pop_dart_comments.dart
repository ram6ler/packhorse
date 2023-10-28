import 'dart:io';

enum State {
  code,
  comment;
}

const tempFileName = ".popmark/comment";

/// Inserts output to example dart code in documentation comments.
///
/// To run:
///
/// 1. Install popmark.
/// 2. Run:
///
/// ```
/// dart tool/parse_comments.dart [Dart file]
/// ```
///
///
Future<void> main(List<String> args) async {
  final dartFile = args.first,
      commentStart = RegExp(r'^( *)\/\/\/ ?(.*)'),
      outBuffer = StringBuffer(),
      tempBuffer = StringBuffer();

  State state = State.code;

  String stripComment(String line) =>
      commentStart.firstMatch(line)!.group(2)!; //line.split(r"///")[1].trim();

  var padding = 0;

  if (!(await Directory(".popmark").exists())) {
    await Directory(".popmark").create();
  }

  for (final line in await File(dartFile).readAsLines()) {
    switch (state) {
      case State.code:
        if (commentStart.hasMatch(line)) {
          padding = commentStart.firstMatch(line)!.group(1)!.length;
          tempBuffer
            ..clear()
            ..writeln(stripComment(line));
          state = State.comment;
        } else {
          outBuffer.writeln(line);
        }
      case State.comment:
        if (!commentStart.hasMatch(line)) {
          final f = File(tempFileName);
          await f.writeAsString(tempBuffer.toString());
          final result = await Process.run("popmark", [
            tempFileName,
            "--template",
            "tool/popmark_template",
            //"--time",
            "--refresh",
          ]);
          if (result.stderr.toString().isNotEmpty) {
            print(result.stderr);
          }
          for (final line in await File(tempFileName).readAsLines()) {
            outBuffer.writeln(" " * padding + "/// " + line);
          }
          await File(tempFileName).delete();
          outBuffer.writeln(line);
          state = State.code;
        } else {
          tempBuffer.writeln(stripComment(line));
        }
    }
  }

  await File(dartFile).writeAsString(outBuffer.toString());
}
