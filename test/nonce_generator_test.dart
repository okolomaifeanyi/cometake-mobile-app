import 'package:cometake/core/utils/nonce_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateRawNonce', () {
    test('default length is 32 characters', () {
      expect(generateRawNonce().length, 32);
    });

    test('respects a custom length', () {
      expect(generateRawNonce(16).length, 16);
    });

    test('two calls produce different values', () {
      expect(generateRawNonce(), isNot(equals(generateRawNonce())));
    });

    test('only uses characters from the documented charset', () {
      final nonce = generateRawNonce(64);
      final allowed = RegExp(r'^[0-9A-Za-z\-._]+$');
      expect(allowed.hasMatch(nonce), isTrue);
    });
  });

  group('sha256OfNonce', () {
    test('is deterministic for the same input', () {
      const raw = 'fixed-test-nonce';
      expect(sha256OfNonce(raw), sha256OfNonce(raw));
    });

    test('produces a 64-character lowercase hex digest', () {
      final hash = sha256OfNonce('abc');
      expect(hash.length, 64);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
    });

    test('matches the known SHA-256 digest of "abc"', () {
      expect(
        sha256OfNonce('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });
  });

  group('buildAppleFirstLoginUpdate', () {
    test('returns null when both names are null (repeat login)', () {
      expect(
        buildAppleFirstLoginUpdate(),
        isNull,
      );
    });

    test('returns null when both names are empty strings', () {
      expect(
        buildAppleFirstLoginUpdate(givenName: '', familyName: '  '),
        isNull,
      );
    });

    test('includes only the non-empty name fields', () {
      final result = buildAppleFirstLoginUpdate(givenName: 'Ada');
      expect(result, {'first_name': 'Ada'});
    });

    test('includes both fields, trimmed, on first login', () {
      final result = buildAppleFirstLoginUpdate(givenName: ' Ada ', familyName: ' Lovelace ');
      expect(result, {'first_name': 'Ada', 'last_name': 'Lovelace'});
    });
  });
}
