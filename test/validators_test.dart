import 'package:cometake/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── email ──────────────────────────────────────────────────────────────────

  group('Validators.email', () {
    test('null returns required error', () {
      expect(Validators.email(null), isNotNull);
    });

    test('empty string returns required error', () {
      expect(Validators.email(''), isNotNull);
    });

    test('valid email returns null', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('email without @ returns error', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('email without domain returns error', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('email without TLD returns error', () {
      expect(Validators.email('user@domain'), isNotNull);
    });

    test('email with subdomain is valid', () {
      expect(Validators.email('user@mail.example.co.uk'), isNull);
    });

    test('email with + alias is valid', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });
  });

  // ── password ───────────────────────────────────────────────────────────────

  group('Validators.password', () {
    test('null returns required error', () {
      expect(Validators.password(null), isNotNull);
    });

    test('empty returns required error', () {
      expect(Validators.password(''), isNotNull);
    });

    test('too short returns error', () {
      expect(Validators.password('Ab1efg'), isNotNull); // 6 chars
    });

    test('exactly 8 chars but missing uppercase returns error', () {
      expect(Validators.password('abcdefg1'), isNotNull);
    });

    test('exactly 8 chars but missing number returns error', () {
      expect(Validators.password('Abcdefgh'), isNotNull);
    });

    test('valid password: 8+ chars, uppercase, number', () {
      expect(Validators.password('Password1'), isNull);
    });

    test('valid long password', () {
      expect(Validators.password('SuperSecret123!'), isNull);
    });
  });

  // ── phone ──────────────────────────────────────────────────────────────────

  group('Validators.phone', () {
    test('null returns required error', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('empty returns required error', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('0-prefix 11-digit Nigerian number is valid', () {
      expect(Validators.phone('08012345678'), isNull);
    });

    test('10-digit number without prefix is valid', () {
      expect(Validators.phone('8012345678'), isNull);
    });

    test('+234-prefix 13-digit number is valid', () {
      expect(Validators.phone('+2348012345678'), isNull);
    });

    test('234-prefix without plus is valid', () {
      expect(Validators.phone('2348012345678'), isNull);
    });

    test('number starting with 5 (invalid for Nigeria) returns error', () {
      expect(Validators.phone('05012345678'), isNotNull);
    });

    test('too short number returns error', () {
      expect(Validators.phone('0801234'), isNotNull);
    });

    test('non-numeric input returns error', () {
      expect(Validators.phone('not-a-phone'), isNotNull);
    });
  });

  // ── required ───────────────────────────────────────────────────────────────

  group('Validators.required', () {
    test('null returns error', () {
      expect(Validators.required(null), isNotNull);
    });

    test('empty string returns error', () {
      expect(Validators.required(''), isNotNull);
    });

    test('whitespace-only returns error', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('valid string returns null', () {
      expect(Validators.required('hello'), isNull);
    });

    test('custom label appears in error message', () {
      final error = Validators.required('', label: 'Street address');
      expect(error, contains('Street address'));
    });
  });

  // ── minLength ──────────────────────────────────────────────────────────────

  group('Validators.minLength', () {
    test('null returns error', () {
      expect(Validators.minLength(null, 3), isNotNull);
    });

    test('too short returns error', () {
      expect(Validators.minLength('ab', 3), isNotNull);
    });

    test('exactly min length is valid', () {
      expect(Validators.minLength('abc', 3), isNull);
    });

    test('longer than min is valid', () {
      expect(Validators.minLength('abcdef', 3), isNull);
    });

    test('custom label in error message', () {
      final error = Validators.minLength('x', 5, label: 'Username');
      expect(error, contains('Username'));
      expect(error, contains('5'));
    });
  });

  // ── amount ─────────────────────────────────────────────────────────────────

  group('Validators.amount', () {
    test('null returns error', () {
      expect(Validators.amount(null), isNotNull);
    });

    test('empty returns error', () {
      expect(Validators.amount(''), isNotNull);
    });

    test('non-numeric returns error', () {
      expect(Validators.amount('abc'), isNotNull);
    });

    test('zero returns error', () {
      expect(Validators.amount('0'), isNotNull);
    });

    test('negative amount returns error', () {
      expect(Validators.amount('-100'), isNotNull);
    });

    test('valid positive amount returns null', () {
      expect(Validators.amount('500'), isNull);
    });

    test('decimal amount is valid', () {
      expect(Validators.amount('500.50'), isNull);
    });

    test('amount with comma thousands separator is valid', () {
      expect(Validators.amount('1,500'), isNull);
    });
  });

  // ── confirmPassword ────────────────────────────────────────────────────────

  group('Validators.confirmPassword', () {
    test('null returns error', () {
      expect(Validators.confirmPassword(null, 'Password1'), isNotNull);
    });

    test('empty returns error', () {
      expect(Validators.confirmPassword('', 'Password1'), isNotNull);
    });

    test('mismatch returns error', () {
      expect(Validators.confirmPassword('Different1', 'Password1'), isNotNull);
    });

    test('matching password returns null', () {
      expect(Validators.confirmPassword('Password1', 'Password1'), isNull);
    });

    test('case-sensitive: different case returns error', () {
      expect(Validators.confirmPassword('password1', 'Password1'), isNotNull);
    });
  });
}
