import 'package:cometake/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── currency ───────────────────────────────────────────────────────────────

  group('Formatters.currency', () {
    test('formats zero', () {
      expect(Formatters.currency(0), contains('0'));
    });

    test('formats whole number with naira symbol', () {
      final result = Formatters.currency(1500);
      expect(result, contains('₦'));
      expect(result, contains('1'));
    });

    test('formats decimal amount', () {
      final result = Formatters.currency(1500.50);
      expect(result, contains('₦'));
    });

    test('formats large number with thousand separators', () {
      final result = Formatters.currency(1000000);
      expect(result, contains('₦'));
      // Should have comma or period as thousands separator
      expect(result.replaceAll('₦', ''), anyOf(contains(','), contains('.')));
    });
  });

  // ── currencyCompact ────────────────────────────────────────────────────────

  group('Formatters.currencyCompact', () {
    test('uses full format for amounts below 1 million', () {
      final result = Formatters.currencyCompact(500000);
      expect(result, contains('₦'));
    });

    test('uses compact format for 1 million+', () {
      final result = Formatters.currencyCompact(1500000);
      expect(result, startsWith('₦'));
      // Compact format should NOT show the full number
      expect(result.length, lessThan(12));
    });

    test('compact format for exactly 1 million', () {
      final result = Formatters.currencyCompact(1000000);
      expect(result, startsWith('₦'));
    });
  });

  // ── fileSize ───────────────────────────────────────────────────────────────

  group('Formatters.fileSize', () {
    test('formats bytes under 1 KB', () {
      expect(Formatters.fileSize(512), '512B');
    });

    test('formats 0 bytes', () {
      expect(Formatters.fileSize(0), '0B');
    });

    test('formats exactly 1 KB boundary', () {
      expect(Formatters.fileSize(1024), '1.0KB');
    });

    test('formats KB range', () {
      expect(Formatters.fileSize(2048), '2.0KB');
    });

    test('formats fractional KB', () {
      expect(Formatters.fileSize(1536), '1.5KB');
    });

    test('formats exactly 1 MB boundary', () {
      expect(Formatters.fileSize(1024 * 1024), '1.0MB');
    });

    test('formats MB range', () {
      expect(Formatters.fileSize(5 * 1024 * 1024), '5.0MB');
    });

    test('formats fractional MB', () {
      expect(Formatters.fileSize((1.5 * 1024 * 1024).round()), '1.5MB');
    });
  });

  // ── toE164 ─────────────────────────────────────────────────────────────────

  group('Formatters.toE164', () {
    test('converts 0-prefix format', () {
      expect(Formatters.toE164('08012345678'), '+2348012345678');
    });

    test('converts 234-prefix (no plus)', () {
      expect(Formatters.toE164('2348012345678'), '+2348012345678');
    });

    test('passes through +234-prefix unchanged', () {
      expect(Formatters.toE164('+2348012345678'), '+2348012345678');
    });

    test('converts bare 10-digit number', () {
      expect(Formatters.toE164('8012345678'), '+2348012345678');
    });

    test('strips spaces before converting', () {
      expect(Formatters.toE164('080 1234 5678'), '+2348012345678');
    });

    test('strips hyphens before converting', () {
      expect(Formatters.toE164('080-1234-5678'), '+2348012345678');
    });
  });

  // ── phoneForDisplay ────────────────────────────────────────────────────────

  group('Formatters.phoneForDisplay', () {
    test('strips +234 prefix', () {
      expect(Formatters.phoneForDisplay('+2348012345678'), '8012345678');
    });

    test('strips 234 prefix (no plus)', () {
      expect(Formatters.phoneForDisplay('2348012345678'), '8012345678');
    });

    test('strips leading 0', () {
      expect(Formatters.phoneForDisplay('08012345678'), '8012345678');
    });

    test('returns bare number unchanged', () {
      expect(Formatters.phoneForDisplay('8012345678'), '8012345678');
    });
  });

  // ── orderId ────────────────────────────────────────────────────────────────

  group('Formatters.orderId', () {
    test('prefixes with #', () {
      expect(Formatters.orderId('abcdef12-0000-0000-0000-000000000000'), startsWith('#'));
    });

    test('takes first 8 chars uppercased', () {
      expect(Formatters.orderId('abcdef12-0000-0000-0000-000000000000'), '#ABCDEF12');
    });

    test('uppercases lowercase hex id', () {
      final result = Formatters.orderId('ffffffff-aaaa-0000-0000-000000000000');
      expect(result, '#FFFFFFFF');
    });
  });

  // ── date / dateTime / time ─────────────────────────────────────────────────

  group('Formatters.date', () {
    test('formats a known date', () {
      final d = DateTime(2024, 1, 15);
      final result = Formatters.date(d);
      expect(result, contains('2024'));
      expect(result, contains('Jan'));
      expect(result, contains('15'));
    });
  });

  group('Formatters.time', () {
    test('formats time with AM/PM', () {
      final d = DateTime(2024, 1, 15, 14, 30); // 2:30 PM
      final result = Formatters.time(d);
      expect(result, anyOf(contains('AM'), contains('PM')));
    });
  });
}
