import 'package:cometake/core/errors/app_exception.dart';
import 'package:cometake/features/orders/data/models/checkout_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── CheckoutResultModel.fromJson ──────────────────────────────────────────

  group('CheckoutResultModel.fromJson', () {
    test('maps full payload correctly', () {
      final json = {
        'orderId':          'order-123',
        'paymentId':        'pay-456',
        'authorizationUrl': 'https://checkout.paystack.com/abc',
        'reference':        'TXN_abc123',
        'correlationId':    'corr-789',
        'cached':           false,
      };

      final model = CheckoutResultModel.fromJson(json);

      expect(model.orderId,          'order-123');
      expect(model.paymentId,        'pay-456');
      expect(model.authorizationUrl, 'https://checkout.paystack.com/abc');
      expect(model.reference,        'TXN_abc123');
      expect(model.correlationId,    'corr-789');
      expect(model.cached,           isFalse);
    });

    test('nullable fields are null when omitted', () {
      final json = {
        'orderId':       'order-001',
        'paymentId':     'pay-001',
        'correlationId': 'corr-001',
      };

      final model = CheckoutResultModel.fromJson(json);

      expect(model.authorizationUrl, isNull);
      expect(model.reference,        isNull);
    });

    test('nullable fields are null when explicitly null in JSON', () {
      final json = {
        'orderId':          'order-002',
        'paymentId':        'pay-002',
        'authorizationUrl': null,
        'reference':        null,
        'correlationId':    'corr-002',
      };

      final model = CheckoutResultModel.fromJson(json);

      expect(model.authorizationUrl, isNull);
      expect(model.reference,        isNull);
    });

    test('cached defaults to false when absent', () {
      final json = {
        'orderId':       'order-003',
        'paymentId':     'pay-003',
        'correlationId': 'corr-003',
      };

      expect(CheckoutResultModel.fromJson(json).cached, isFalse);
    });

    test('cached reads true when server returns cached=true', () {
      final json = {
        'orderId':       'order-004',
        'paymentId':     'pay-004',
        'correlationId': 'corr-004',
        'cached':        true,
      };

      expect(CheckoutResultModel.fromJson(json).cached, isTrue);
    });

    test('needs Paystack WebView when authorizationUrl and reference are present', () {
      final json = {
        'orderId':          'order-005',
        'paymentId':        'pay-005',
        'authorizationUrl': 'https://checkout.paystack.com/xyz',
        'reference':        'TXN_xyz',
        'correlationId':    'corr-005',
      };

      final model = CheckoutResultModel.fromJson(json);

      // This is the condition used in checkout_screen.dart to route to OrderPaymentScreen
      expect(model.authorizationUrl != null && model.reference != null, isTrue);
    });

    test('no WebView needed when Paystack init failed (authorizationUrl absent)', () {
      final json = {
        'orderId':       'order-006',
        'paymentId':     'pay-006',
        'correlationId': 'corr-006',
      };

      final model = CheckoutResultModel.fromJson(json);

      // Falls back to order detail page — cron will retry payment init
      expect(model.authorizationUrl, isNull);
    });
  });

  // ── AppException subclasses ───────────────────────────────────────────────

  group('CheckoutExpiredException', () {
    test('has correct message', () {
      const ex = CheckoutExpiredException();
      expect(ex.message, contains('expired'));
    });

    test('canRestart defaults to true', () {
      const ex = CheckoutExpiredException();
      expect(ex.canRestart, isTrue);
    });

    test('canRestart can be set to false', () {
      const ex = CheckoutExpiredException(canRestart: false);
      expect(ex.canRestart, isFalse);
    });

    test('is an AppException', () {
      const ex = CheckoutExpiredException();
      expect(ex, isA<AppException>());
    });
  });

  group('CheckoutRecoverableException', () {
    test('has correct message', () {
      const ex = CheckoutRecoverableException();
      expect(ex.message, contains('retry'));
    });

    test('is an AppException', () {
      const ex = CheckoutRecoverableException();
      expect(ex, isA<AppException>());
    });

    test('is distinct from CheckoutExpiredException', () {
      const expired    = CheckoutExpiredException();
      const recovering = CheckoutRecoverableException();
      expect(expired,    isNot(isA<CheckoutRecoverableException>()));
      expect(recovering, isNot(isA<CheckoutExpiredException>()));
    });
  });

  // ── Placeholder (keeps original test file passing) ────────────────────────

  test('placeholder always passes', () {
    expect(true, isTrue);
  });
}
