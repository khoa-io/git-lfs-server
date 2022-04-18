import 'dart:convert';
import 'dart:io';

import 'package:git_lfs_server/operation.dart';
import 'package:tcp_scanner/tcp_scanner.dart';

void main(List<String> args) {
  exitCode = 0;

  if (args.length < 2) {
    stderr.writeln('usage: git-lfs-authenticate {path} {operation}');
    exitCode = 1;
    return;
  }

  final url = Platform.environment['GIT_LFS_SERVER_URL'] ?? 'localhost';
  final expiresIn =
      int.parse(Platform.environment['GIT_LFS_EXPIRES_IN'] ?? '120');

  final path = args[0];
  final operation = args[1];

  if (!operations.any((item) => item.toString() == operation)) {
    stderr.writeln('Invalid LFS operation: $operation');
    exitCode = 1;
    return;
  }

  // Find a port that is not in use
  final host = '127.0.0.1';
  final ports = List.generate(990, (i) => 8000 + i);
  var stopwatch = Stopwatch();
  stopwatch.start();
  try {
    TcpScannerTask(host, ports, shuffle: true, parallelism: 2)
        .start()
        .then((report) => exitCode = startServer({
              'hostname': url,
              'port': report.closedPorts.first,
              'expiresIn': expiresIn,
              'token': 'username:password',
              'path': path,
              'operation': operation,
            }))
        .catchError((error) => throw error);
  } catch (e) {
    stderr.writeln('Error: $e');
    exitCode = 1;
  }
}

void printOutput(Map args) {
  final hostname = args['hostname'] as String;
  final port = args['port'] as int;
  final expiresIn = args['expiresIn'] as int;
  final token = base64.encode(utf8.encode(args['token']));
  final path = args['path'] as String;
  var output = {
    "href": "http://$hostname:$port",
    "header": {"Authorization": "Basic $token"},
    "expires_in": expiresIn
  };
  print(json.encode(output).toString());
}

int startServer(Map args) {
  final hostname = args['hostname'] as String;
  final port = args['port'] as int;
  final expiresIn = args['expiresIn'] as int;
  final token = base64.encode(utf8.encode(args['token']));
  final path = args['path'] as String;
  try {
    // git-lfs-server HOSTNAME PORT EXPIRES_IN TOKEN PATH
    Process.start('git-lfs-server',
            [hostname, port.toString(), expiresIn.toString(), token, path],
            mode: ProcessStartMode.detached)
        .catchError((error) => error);
  } catch (e) {
    stderr.writeln('Error: $e');
    return 1;
  }

  printOutput(args);
  return 0;
}
