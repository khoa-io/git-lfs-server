import 'dart:io';
import 'package:logging/logging.dart';

late IOSink _logfile;
void initialize(String logfile) {
  _logfile = File(logfile).openWrite(mode: FileMode.append);
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final msg = record.error != null
        ? '[${record.level.name}] [${record.time}] [${record.message}] [${record.error}]'
        : '[${record.level.name}] [${record.time}] [${record.message}]';
    _logfile.writeln(msg);
    if (record.stackTrace != null) {
      _logfile.writeln(record.stackTrace);
    }
    if (record.level >= Level.SEVERE) {
      // Also write error message to stderr.
      stderr.writeln(record.message);
    }
  });
}

Future<void> finalize() async {
  await _logfile.flush();
  await _logfile.close();
}
