import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

TestProcess? _serverProcess;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  final url = 'https://localhost:8080';
  final home = Platform.environment['HOME'];
  final certPath = '$home/certificates/mine.crt';
  final pemPath = '$home/certificates/mine.crt';
  final keyPath = '$home/certificates/mine.key';

  setUp(() async {
    _serverProcess = _serverProcess ??
        await TestProcess.start(
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

    HttpOverrides.global = MyHttpOverrides();
    SecurityContext.defaultContext.useCertificateChain(pemPath);
    await await Future.delayed(Duration(seconds: 5));
  });

  tearDown(() async {
    if (_serverProcess == null) {
      print('_serverProcess is null');
    } else {
      print('Signaling git-lfs-server to shutdown');
    }
    _serverProcess?.signal(ProcessSignal.sigint);
    await Future.delayed(Duration(seconds: 5));
    await _serverProcess?.shouldExit();
    _serverProcess = null;
  });

  test('Root', () async {
    final response = await get(Uri.parse(url + '/'));
    expect(response.statusCode, 404);
    expect(response.body, 'Route not found');
    print('${response.statusCode} ${response.body}');
  });

  test('Batch', () async {
    final response = await post(Uri.parse(url + '/objects/batch'));
    expect(response.statusCode, 403);
    expect(response.body, contains('Forbidden'));
    print('${response.statusCode} ${response.body}');
  });
}
