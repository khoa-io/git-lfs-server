final defaultExpiresIn = 86400;

final filelock = '.git-lfs-server.lock';

final operations = [Operation.download.name, Operation.upload.name];
enum Operation { download, upload }

enum StatusCode {
  success,
  errorUnknown,
  errorInvalidConfig,
  errorInvalidOperation,
  errorInvalidArgument,
}
