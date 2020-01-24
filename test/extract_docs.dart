import 'dart:io';

Future<void> main(List<String> args) async {
  final dartFile = args.first, expr = RegExp(r'^ *\/\/\/ ');

  for (final line in await File(dartFile).readAsLines()) {
    if (line.contains(expr)) {
      print(line.replaceAll(expr, ''));
    } else {
      stdout.writeln();
    }
  }
}
