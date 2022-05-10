final defaultExpiresIn = 86400;

final filelock = '.git-lfs-server.lock';

final operations = [Operation.download.name, Operation.upload.name];
final requiredEnvironments = [
  GitLfsServerEnv.url.name,
  GitLfsServerEnv.cert.name,
  GitLfsServerEnv.key.name,
];

enum GitLfsServerEnv {
  trace,
  url,
  cert,
  key,
  expiresIn,
}

enum Operation { download, upload }

enum StatusCode {
  success,
  errorUnknown,
  errorInvalidConfig,
  errorInvalidOperation,
  errorInvalidArgument,
}

extension EnvironmentExt on GitLfsServerEnv {
  String get name {
    switch (this) {
      case GitLfsServerEnv.trace:
        return 'GIT_LFS_SERVER_TRACE';
      case GitLfsServerEnv.url:
        return 'GIT_LFS_SERVER_URL';
      case GitLfsServerEnv.cert:
        return 'GIT_LFS_SERVER_CERT';
      case GitLfsServerEnv.key:
        return 'GIT_LFS_SERVER_KEY';
      case GitLfsServerEnv.expiresIn:
        return 'GIT_LFS_EXPIRES_IN';
      default:
        return '';
    }
  }
}
