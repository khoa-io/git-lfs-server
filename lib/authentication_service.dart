import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/logging.dart' show onRecordServer;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

import 'git_lfs.dart';

final Logger _log = Logger(_tag)..onRecord.listen(onRecordServer);

final _tag = 'git-lfs-auth-service';

Future<void> authService(List<dynamic> args) async {
  if (args.length < 3) {
    _log.severe('Missing arguments!');
    return;
  }

  final sendPortData = args[0] as SendPort;
  final sendPortCmd = args[1] as SendPort;
  final url = args[2] as String;

  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  final service = AuthenticationService(url, sendPortData);
  final server = Server([service]);
  server.serve(address: udsa);
  _log.info('$_tag has started.');

  sendPortCmd.send(service.receivePortCmd.sendPort);

  // git-lfs-server only sends nude to shutdown git-lfs-auth-service
  await service.receivePortCmd.first;

  _log.fine('$_tag is shutting down.');
  await server.shutdown();
  _log.info('$_tag has shutdown.');
  Isolate.exit();
}

class AuthenticationService extends AuthenticationServiceBase {
  /// The URL at which Git LFS Server is serving.
  /// For example: https://localhost:8080
  final String _url;

  /// To send data to main
  final SendPort _sendPortData;

  /// To receive commands from main
  final receivePortCmd = ReceivePort();

  AuthenticationService(this._url, this._sendPortData);

  @override
  Future<AuthenticationResponse> authenticate(
      ServiceCall call, AuthenticationRequest request) async {
    if (request.operation != Operation.download.name) {
      _log.warning('Unsupported operation: ${request.operation}');
      // Only operation 'download' is supported
      return AuthenticationResponse()
        ..status = AuthenticationResponse_Status.EOPNOTSUPP
        ..message = 'Invalid LFS operation ${request.operation}';
    }

    final repoDirectory = Directory(request.path);
    if (!repoDirectory.existsSync()) {
      _log.warning('File not found: ${request.path}');
      return AuthenticationResponse()
        ..status = AuthenticationResponse_Status.ENOENT
        ..message = 'No such file or directory';
    }

    final expiresIn =
        int.parse(Platform.environment['GIT_LFS_EXPIRES_IN'] ?? '86400');

    final result = Process.runSync('pwgen', ['-1', '25']);
    final token = (result.stdout as String).trim();

    if (token.length != 25) {
      _log.severe('Failed to generate token!');
      return AuthenticationResponse()
        ..status = AuthenticationResponse_Status.EIO
        ..message = 'I/O error';
    }

    final response = AuthenticationResponse()
      ..status = AuthenticationResponse_Status.SUCCESS
      ..message = jsonEncode({
        'href': _url,
        'header': {
          'Authorization': 'RemoteAuth $token',
        },
        'expires_in': expiresIn,
      });

    _sendPortData.send({'path': request.path, 'token': token});
    _log.info('Successfully authenticated for ${request.path} $response');
    return response;
  }
}
