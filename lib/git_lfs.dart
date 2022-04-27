final filelock = 'git-lfs-server.lock';
enum Operation { download, upload }
final operations = [Operation.download.name, Operation.upload.name];
enum StatusCode {
  success,
  errorUnknown,
  errorInvalidConfig,
  errorInvalidOperation,
  errorInvalidArgument,
}
