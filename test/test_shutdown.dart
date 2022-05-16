import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  final url = 'https://localhost:8080';
  final home = Platform.environment['HOME'];
  final certPath = '$home/certificates/mine.crt';
  final keyPath = '$home/certificates/mine.key';

  test('Clean exit on signal SIGINT', () async {
    TestProcess serverProcess = await TestProcess.start(
      'dart',
      ['run', 'bin/git_lfs_server.dart'],
      environment: {
        GitLfsServerEnv.url.name: url,
        GitLfsServerEnv.cert.name: certPath,
        GitLfsServerEnv.key.name: keyPath,
        GitLfsServerEnv.expiresIn.name: '60',
        GitLfsServerEnv.trace.name: 'true',
      },
    );
    await Future.delayed(Duration(seconds: 5));
    serverProcess.signal(ProcessSignal.sigint);
    serverProcess.shouldExit(0);
  });

  test('Clean exit on signal SIGTERM', () async {
    TestProcess serverProcess = await TestProcess.start(
      'dart',
      ['run', 'bin/git_lfs_server.dart'],
      environment: {
        GitLfsServerEnv.url.name: url,
        GitLfsServerEnv.cert.name: certPath,
        GitLfsServerEnv.key.name: keyPath,
        GitLfsServerEnv.expiresIn.name: '60',
        GitLfsServerEnv.trace.name: 'true',
      },
    );
    await Future.delayed(Duration(seconds: 5));
    serverProcess.signal(ProcessSignal.sigterm);
    serverProcess.shouldExit(0);
  });
}
