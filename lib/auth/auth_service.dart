import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/logging.dart' show onRecordServer;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart' show Server, ServiceCall;
import 'package:logging/logging.dart';

import '../git_lfs.dart';

final Logger _log = Logger(_tag)..onRecord.listen(onRecordServer);

final _tag = 'git-lfs-auth-service';

/// auth-service must run on an isolate.
Future<void> authService(List<dynamic> args) async {
  Logger.root.level = Level.ALL;
  if (args.length < 3) {
    _log.severe('Missing arguments!');
    return;
  }

  final sendPortData = args[0] as SendPort;
  final sendPortCmd = args[1] as SendPort;
  final url = args[2] as String;

  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  final service = _AuthenticationService(url, sendPortData);
  final server = Server([service]);
  server.serve(address: udsa);
  _log.info('$_tag has started.');

  sendPortCmd.send(service.receivePortCmd.sendPort);

  // git-lfs-server only sends null to shutdown git-lfs-auth-service
  await service.receivePortCmd.first;

  _log.fine('$_tag is shutting down.');
  await server.shutdown();
  _log.info('$_tag has shutdown.');
  Isolate.exit();
}

class _AuthenticationService extends AuthenticationServiceBase {
  /// The URL at which Git LFS Server is serving.
  /// For example: https://localhost:8080
  final String _url;

  /// The number of seconds before a token expires.
  final int _expiresIn =
      Platform.environment['GIT_LFS_SERVER_EXPIRES_IN'] == null
          ? lfs.defaultExpiresIn
          : int.parse(Platform.environment['GIT_LFS_SERVER_EXPIRES_IN']!);

  /// Each token is associated with a path.
  final Map<String, String> _mapTokenPath = {};

  /// To send data to main
  final SendPort _sendPortData;

  /// To receive commands from main
  final receivePortCmd = ReceivePort();

  _AuthenticationService(this._url, this._sendPortData);

  @override
  Future<RegistrationReply> generateToken(
      ServiceCall call, RegistrationForm request) async {
    if (request.operation != Operation.download.name) {
      _log.warning('Unsupported operation: ${request.operation}');
      return RegistrationReply()
        ..status = RegistrationReply_Status.EOPNOTSUPP
        ..message = 'Invalid LFS operation ${request.operation}';
    }

    final repoDirectory = Directory(request.path);
    if (!repoDirectory.existsSync()) {
      _log.warning('File not found: ${request.path}');
      return RegistrationReply()
        ..status = RegistrationReply_Status.ENOENT
        ..message = 'No such file or directory';
    }

    final expiresIn =
        int.parse(Platform.environment['GIT_LFS_EXPIRES_IN'] ?? '86400');

    final result = Process.runSync('pwgen', ['-1', '25']);
    final token = (result.stdout as String).trim();

    if (token.length != 25) {
      _log.severe('Failed to generate token!');
      return RegistrationReply()
        ..status = RegistrationReply_Status.EIO
        ..message = 'I/O error';
    }

    _addToken(token, request.path);
    final response = RegistrationReply()
      ..status = RegistrationReply_Status.SUCCESS
      ..message = jsonEncode({
        'href': _url,
        'header': {
          'Authorization': 'RemoteAuth $token',
        },
        'expires_in': expiresIn,
      });

    _sendPortData.send({'path': request.path, 'token': token});
    _log.fine('Successfully authenticated for ${request.path} $response');
    return response;
  }

  @override
  Future<AuthenticationReply> verifyToken(
      ServiceCall call, AuthenticationForm request) async {
    if (!_mapTokenPath.keys.contains(request.token)) {
      _log.fine('Token "${request.token}" is invalid or expired.');
      // Token is invalid or expired
      return AuthenticationReply()
        ..success = false
        ..path = 'Not a path!';
    }

    final path = _mapTokenPath[request.token]!;
    _log.fine('Token "${request.token}" is valid for "$path."');
    return AuthenticationReply()
      ..success = true
      ..expiresIn = _expiresIn
      ..path = path;
  }

  void _addToken(String token, String path) {
    _mapTokenPath[token] = path;
    Timer(Duration(seconds: _expiresIn), () => _mapTokenPath.remove(token));
  }
}
