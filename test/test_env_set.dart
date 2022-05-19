import 'package:git_lfs_server/git_lfs.dart';
import 'package:git_lfs_server/util.dart';
import 'package:test/test.dart';

void main() {
  final envTrace = GitLfsServerEnv.trace.name;
  test('getEnv($envTrace) when $envTrace is set', () {
    final tracing = getEnv(envTrace) as bool;
    expect(tracing, isNotNull);
    expect(tracing, isA<bool>());
    expect(tracing, isTrue);
  });

  final environments = [
    GitLfsServerEnv.url,
    GitLfsServerEnv.cert,
    GitLfsServerEnv.key,
  ];

  for (final environment in environments) {
    test('getEnv(${environment.name}) when ${environment.name} is set', () {
      final value = getEnv(environment.name);
      expect(value, isNotNull);
      expect(value is String, isTrue);
    });
  }

  final envExpiresIn = GitLfsServerEnv.expiresIn.name;
  test('getEnv($envExpiresIn) when $envExpiresIn is set', () {
    final expiresIn = getEnv(envExpiresIn);
    expect(expiresIn, isNotNull);
    expect(expiresIn, isA<int>());
  });
}
