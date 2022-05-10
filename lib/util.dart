import 'dart:io';
import 'dart:math';

import 'package:git_lfs_server/git_lfs.dart';

String generateSecret(int length) {
  final characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String secret = '';
  for (var _ in Iterable.generate(length)) {
    secret += characters[Random.secure().nextInt(characters.length)];
  }

  return secret;
}

dynamic getEnv(String name) {
  if (name == GitLfsServerEnv.trace.name) {
    final tracing = Platform.environment[name] ?? 'FALSE';
    switch (tracing.toLowerCase()) {
      case '1':
      case 'true':
      case 'on':
      case 'yes':
      case 'y':
      case 'enable':
      case 'enabled':
        return true;
      default:
        return false;
    }
  } else if (name == GitLfsServerEnv.url.name) {
    return Platform.environment[name] ?? '';
  } else if (name == GitLfsServerEnv.cert.name) {
    return Platform.environment[name] ?? '';
  } else if (name == GitLfsServerEnv.key.name) {
    return Platform.environment[name] ?? '';
  } else if (name == GitLfsServerEnv.expiresIn.name) {
    final expiresIn = Platform.environment[name] ?? defaultExpiresIn;
    if (expiresIn is int) {
      return expiresIn;
    }
    return int.tryParse(expiresIn as String);
  } else {
    return false;
  }
}
