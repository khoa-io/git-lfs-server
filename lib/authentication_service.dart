import 'dart:convert';
import 'dart:io';

import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

import 'git_lfs.dart';

final Logger _log = Logger('AuthenticationService');

class AuthenticationService extends AuthenticationServiceBase {
  /// The URL at which Git LFS Server is serving.
  /// For example: https://localhost:8080
  final String _url;

  AuthenticationService(this._url);

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
          'Authorization': 'Basic $token',
        },
        'expires_in': expiresIn,
      });

    _log.info('Successfully authenticated: $response');
    return response;
  }
}
