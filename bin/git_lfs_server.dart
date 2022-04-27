import 'dart:async';
import 'dart:io';

import 'package:git_lfs_server/authentication_service.dart';
import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/logging.dart' as lfs_logging;
import 'package:git_lfs_server/http_server.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

Future<int> onExit(lfs.StatusCode code) async {
  if (code == lfs.StatusCode.success) {
    _log.info('git-lfs-server has stopped peacefully.');
  }
  await lfs_logging.finalize();
  return code.index;
}

void main() {
  lfs_logging.initialize('git-lfs-server.log');
  runZonedGuarded(() async {
    await startServer();
  }, (Object error, StackTrace stack) async {
    final log = Logger('git-lfs-server');
    log.severe('Unknown error!', error, stack);
    exitCode = await onExit(lfs.StatusCode.errorUnknown);
  });
}

final _log = Logger('git-lfs-server');

Future<void> startServer() async {
  final url = Platform.environment['GIT_LFS_SERVER_URL'];
  if (url == null) {
    _log.severe('GIT_LFS_SERVER_URL is not set!');
    exit(await onExit(lfs.StatusCode.errorInvalidConfig));
  }

  final certPath = Platform.environment['GIT_LFS_SERVER_CERT'];
  final keyPath = Platform.environment['GIT_LFS_SERVER_KEY'];
  if (certPath == null || keyPath == null) {
    _log.severe('GIT_LFS_SERVER_CERT and GIT_LFS_SERVER_KEY are not set!');
    exit(await onExit(lfs.StatusCode.errorInvalidConfig));
  }

  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  final authenticationService = Server([AuthenticationService(url)]);
  await authenticationService.serve(address: udsa);

  _log.info('AuthenticationService has started.');

  ProcessSignal.sigint.watch().listen((signal) {
    authenticationService.shutdown().whenComplete(() async => {
          _log.info('AuthenticationService has stopped.'),
          exit(await onExit(lfs.StatusCode.success))
        });
  });

  // final uri = Uri.parse(url);
  // final hostname = uri.host;
  // final port = uri.port;
  // final chain = Platform.script.resolve(certPath).toFilePath();
  // final key = Platform.script.resolve(keyPath).toFilePath();
  // final context = SecurityContext()
  //   ..useCertificateChain(chain)
  //   ..usePrivateKey(key);
  // final server = GitLfsServer(hostname, port, context);
  // server.start();
}
