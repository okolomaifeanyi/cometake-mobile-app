import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
  static final _compact = NumberFormat.compact(locale: 'en_NG');
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _time = DateFormat('hh:mm a');

  static String currency(num amount) => _naira.format(amount);

  static String currencyCompact(num amount) {
    if (amount >= 1000000) return '₦${_compact.format(amount)}';
    return currency(amount);
  }

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
  static String time(DateTime d) => _time.format(d);

  static String fileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Converts any accepted Nigerian phone format to E.164 (+234XXXXXXXXXX).
  /// Input: 08066134387 | 8066134387 | +2348066134387 | 2348066134387
  static String toE164(String value) {
    final c = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (c.startsWith('+234')) return c;
    if (c.startsWith('234')) return '+$c';
    if (c.startsWith('0')) return '+234${c.substring(1)}';
    return '+234$c';
  }

  /// Strips the +234 prefix for pre-filling the phone field (field already shows +234 visually).
  static String phoneForDisplay(String stored) {
    final c = stored.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (c.startsWith('+234')) return c.substring(4);
    if (c.startsWith('234')) return c.substring(3);
    if (c.startsWith('0')) return c.substring(1);
    return c;
  }

  static String phone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (c.startsWith('+234') && c.length == 14) {
      return '+234 ${c.substring(4, 7)} ${c.substring(7, 11)} ${c.substring(11)}';
    }
    if (c.startsWith('0') && c.length == 11) {
      return '${c.substring(0, 4)} ${c.substring(4, 7)} ${c.substring(7)}';
    }
    return raw;
  }

  static String orderId(String id) =>
      '#${id.substring(0, 8).toUpperCase()}';
}
