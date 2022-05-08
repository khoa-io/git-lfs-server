import 'dart:math';

String generateSecret(int length) {
  final characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String secret = '';
  for (var _ in Iterable.generate(length)) {
    secret += characters[Random.secure().nextInt(characters.length)];
  }

  return secret;
}
