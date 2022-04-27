import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/logging.dart' as lfs_logging;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

Future<int> onExit(lfs.StatusCode code) async {
  if (code == lfs.StatusCode.success) {
    _log.info('git-lfs-authenticate has stopped peacefully.');
  }
  lfs_logging.finalize();
  return code.index;
}

void main(List<String> args) {
  lfs_logging.initialize('git-lfs-authenticate.log');
  runZonedGuarded(() async {
    exitCode = await startAuthenticate(args);
  }, (Object error, StackTrace stack) async {
    final log = Logger('git-lfs-authentication');
    log.severe('Unknown error!', error, stack);
    exitCode = await onExit(lfs.StatusCode.errorUnknown);
  });
}

Future<int> startAuthenticate(List<String> args) async {
  if (args.length < 2) {
    _log.severe('Usage: git-lfs-authenticate {path} {operation}');
    exit(await onExit(lfs.StatusCode.errorInvalidArgument));
  }

  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  final channel = ClientChannel(
    udsa,
    port: 0,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  final stub = AuthenticationClient(channel);

  try {
    final request = AuthenticationRequest()
      ..path = args[0]
      ..operation = args[1];
    final response = await stub.authenticate(request);
    switch (response.status) {
      case AuthenticationResponse_Status.SUCCESS:
        print(response.message);
        exit(await onExit(lfs.StatusCode.success));
      default:
        _log.severe(response.message);
        exit(await onExit(lfs.StatusCode.errorUnknown));
    }
  } catch (e) {
    _log.severe('Failed to authenticate!', e);
  }
  await channel.shutdown();

  return onExit(lfs.StatusCode.success);
}

final Logger _log = Logger('git-lfs-authenticate');
