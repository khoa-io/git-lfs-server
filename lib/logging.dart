import 'dart:io';

import 'package:logging/logging.dart';

void onRecordServer(dynamic record) {
  final msg = StringBuffer(
      '[${record.level.name}] [${record.time}] [${record.loggerName}] [${record.message}]');

  if (record.error != null) {
    msg.write('[${record.error}]');
  }
  if (record.stackTrace != null) {
    msg.write('[${record.stackTrace}]');
  }

  if (record.level >= Level.SEVERE) {
    stderr.writeln(msg);
  } else {
    stdout.writeln(msg);
  }
}
