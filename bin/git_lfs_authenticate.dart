import 'dart:async';
import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:logging/logging.dart';

void main(List<String> args) async {
  if (Platform.environment['GIT_LFS_AUTHENTICATE_TRACE'] != null) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.OFF;
  }

  if (args.length < 2) {
    stderr.writeln('Usage: git-lfs-authenticate {path} {operation}');
    exitCode = lfs.StatusCode.errorInvalidArgument.index;
    return;
  }

  await startAuthenticate(args);
}

Future<void> startAuthenticate(List<String> args) async {
  final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
  final ClientChannel _channel = ClientChannel(
    udsa,
    port: 0,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  final stub = AuthenticationClient(_channel);

  final request = RegistrationForm()
    ..path = args[0]
    ..operation = args[1];
  final response = await stub.generateToken(request);
  if (response.status == RegistrationReply_Status.SUCCESS) {
    print(response.message);
  } else {
    stderr.writeln(response.message);
  }

  exitCode = response.status.value;
  await _channel.shutdown();
}
