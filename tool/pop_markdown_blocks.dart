import 'dart:io';

Future<void> main(List<String> args) async {
  final mdFile = args.first;

  if (!(await Directory(".popmark").exists())) {
    await Directory(".popmark").create();
  }

  final result = await Process.run("popmark", [
    mdFile,
    "--template",
    "tool/popmark_template",
    "--time",
    "--refresh",
  ]);

  if (result.stderr.toString().isNotEmpty) {
    print(result.stderr);
  }
}
