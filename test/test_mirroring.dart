import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  final url = 'https://localhost:8080';
  final home = Platform.environment['HOME'];

  late final TestProcess serverProcess;

  setUp(() async {
    serverProcess = await TestProcess.start(
      'dart',
      ['run', 'bin/git_lfs_server.dart'],
      environment: {
        GitLfsServerEnv.url.name: url,
        GitLfsServerEnv.cert.name: '$home/certificates/mine.crt',
        GitLfsServerEnv.key.name: '$home/certificates/mine.key',
        GitLfsServerEnv.expiresIn.name: '60',
        GitLfsServerEnv.trace.name: 'true',
      },
    );

    // Set up the mirror with LFS content.
    await TestProcess.start(
      'git',
      [
        'clone',
        '--mirror',
        'https://github.com/khoa-io/git-lfs-sample-repo.git /tmp/git-lfs-sample-mirror.git'
      ],
    );
    await TestProcess.start('git', [
      '--git-dir=/tmp/git-lfs-sample-mirror.git',
      'lfs',
      'fetch',
      '--recent'
    ]);
  });

  test('Root', () async {
    final response = await get(Uri.parse(url + '/'));
    expect(response.statusCode, 404);
    expect(response.body, 'Route not found');
  });

  test('Batch', () async {
    final response = await post(Uri.parse(url + '/objects/batch'));
    expect(response.statusCode, 403);
    expect(response.body, contains('Forbidden'));
  });

  test('Clean exit on signal SIGINT', () async {
    serverProcess.signal(ProcessSignal.sigint);

    await Future.delayed(Duration(seconds: 5));
    expect(0, serverProcess.exitCode);
  });
}
