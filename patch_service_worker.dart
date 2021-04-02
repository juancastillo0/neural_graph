import 'dart:io';

Future<void> main() async {
  final indexFile = await File("./build/web/index.html").readAsString();
  final basePath = RegExp(r"""<\s*base.*href\s*=\s*["'](.*)/["'].*>""")
          .firstMatch(indexFile)
          ?.group(1) ??
      "";

  final serviceWorkerFile = File("./build/web/flutter_service_worker.js");
  final raw = await serviceWorkerFile.readAsString();
  final replaced = raw.replaceAll(
    "self.location.origin",
    "(self.location.origin + '$basePath')",
  );
  await serviceWorkerFile.writeAsString(replaced, flush: true);
}
