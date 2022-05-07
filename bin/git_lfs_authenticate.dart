import 'dart:async';
import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

void main(List<String> args) {
  if (Platform.environment['GIT_LFS_AUTHENTICATE_TRACE'] != null) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.OFF;
  }
  runZonedGuarded(() async {
    await startAuthenticate(args);
  }, (Object error, StackTrace stack) async {
    final log = Logger('git-lfs-authentication');
    log.severe('Unknown error!', error, stack);
    exit(await onExit(lfs.StatusCode.errorUnknown));
  });
}

late final ClientChannel? _channel;
final Logger _log = Logger(_tag)
  ..onRecord.listen((record) {
    final msg = StringBuffer(
        '[${record.level.name}] [${record.time}] [${record.loggerName}] [${record.message}]');

    if (record.error != null) {
      msg.write('[${record.error}]');
    }
    if (record.stackTrace != null) {
      msg.write('[${record.stackTrace}]');
    }

    stderr.writeln(msg);
  });
final _tag = 'git-lfs-authenticate';

Future<int> onExit(lfs.StatusCode code) async {
  if (code == lfs.StatusCode.success) {
    _log.fine('$_tag has stopped peacefully.');
  }
  await _channel?.shutdown();
  return code.index;
}

Future<void> startAuthenticate(List<String> args) async {
  if (args.length < 2) {
    _log.severe('Usage: git-lfs-authenticate {path} {operation}');
    exit(await onExit(lfs.StatusCode.errorInvalidArgument));
  }

  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  _channel = ClientChannel(
    udsa,
    port: 0,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  final stub = AuthenticationClient(_channel!);

  try {
    final request = RegistrationForm()
      ..path = args[0]
      ..operation = args[1];
    final response = await stub.generateToken(request);
    switch (response.status) {
      case RegistrationReply_Status.SUCCESS:
        print(response.message);
        exit(await onExit(lfs.StatusCode.success));
      default:
        _log.severe(response.message);
        exit(await onExit(lfs.StatusCode.errorUnknown));
    }
  } catch (e) {
    _log.severe('Failed to authenticate!', e);
    exit(await onExit(lfs.StatusCode.errorUnknown));
  }
}
