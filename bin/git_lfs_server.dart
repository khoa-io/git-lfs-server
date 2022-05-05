import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:git_lfs_server/auth/auth_service.dart' show authService;
import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/logging.dart' show onRecordServer;
import 'package:logging/logging.dart';

Future<void> main(List<String> args) async {
  if (args.isNotEmpty) {
    if (args[0] == '--debug') {
      Logger.root.level = Level.ALL;
    }
  }

  _log.info('$_tag has started!');

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

  // Receives data from git-lfs-auth-service (1-way)
  final portAuthData = ReceivePort();
  // Receive port/null from and send null to git-lfs-auth-service
  final portAuthCmd = ReceivePort();

  _log.fine('Attempt to start $_authServiceTag');
  var authServiceStopped = false;
  final isolate = await Isolate.spawn(
      authService, [portAuthData.sendPort, portAuthCmd.sendPort, url]);
  isolate.addOnExitListener(portAuthCmd.sendPort);

  // Used to tell git-lfs-auth-service to shutdown later
  late final SendPort sendPortAuthCmd;

  portAuthData.listen((message) {
    // TODO: Fordward this message to git-lfs-http-server
    // TODO: auth-service and git-lfs-http-server communiate directly so don't forward
    _log.fine('Received data from $_authServiceTag: $message.');
  });

  portAuthCmd.listen((msg) {
    if (msg is SendPort) {
      _log.fine('$_authServiceTag gave us a port to command it.');
      sendPortAuthCmd = msg;
    } else if (msg == null) {
      _log.info('$_authServiceTag has stopped!');
      authServiceStopped = true;
      isolate.removeOnExitListener(portAuthCmd.sendPort);
    } else {
      _log.warning('Unexpected message from $_authServiceTag: $msg.');
    }
  });

  // Wait for SIGINT
  var sigintCounter = 0;
  ProcessSignal.sigint.watch().listen((signal) async {
    sigintCounter++;

    if (sigintCounter == 1) {
      _log.fine('Attempt to shutdown git-lfs-auth-service');
      sendPortAuthCmd.send(null);
    } else if (sigintCounter > 2) {
      if (authServiceStopped) {
        exit(await onExit(lfs.StatusCode.success));
      } else {
        exit(await onExit(lfs.StatusCode.errorUnknown));
      }
    }
  });

  // TODO: Start git-lfs-http-server here
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

final Logger _log = Logger(_tag)..onRecord.listen(onRecordServer);
final _tag = 'git-lfs-server';
final _authServiceTag = 'git-lfs-auth-service';

Future<int> onExit(lfs.StatusCode code) async {
  if (code == lfs.StatusCode.success) {
    _log.info('$_tag has stopped peacefully.');
  } else {
    _log.info('$_tag has been forced to stop!');
  }
  return code.index;
}
