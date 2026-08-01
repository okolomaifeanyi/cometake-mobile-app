import 'package:cometake/features/vendor/data/models/subscription_checkout_result_model.dart';
import 'package:cometake/features/vendor/data/models/subscription_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionCheckoutResultModel.fromJson', () {
    test('reads snake_case authorization_url and reference', () {
      final json = {
        'authorization_url': 'https://checkout.paystack.com/xyz',
        'reference': 'SUB-123-abc',
      };
      final model = SubscriptionCheckoutResultModel.fromJson(json);
      expect(model.authorizationUrl, 'https://checkout.paystack.com/xyz');
      expect(model.reference, 'SUB-123-abc');
    });

    test('fields are null when absent', () {
      final model = SubscriptionCheckoutResultModel.fromJson(<String, dynamic>{});
      expect(model.authorizationUrl, isNull);
      expect(model.reference, isNull);
    });
  });

  group('SubscriptionPlan.fromJson (API shape)', () {
    test('maps monthly plan with features array directly (not plan_description)', () {
      final json = {
        'id': 'plan-1',
        'name': 'Starter',
        'slug': 'starter',
        'description': 'For new sellers',
        'price': 2000,
        'features': ['Feature A', 'Feature B'],
        'productLimit': 50,
        'isActive': true,
        'billingPeriod': 'monthly',
      };
      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.name, 'Starter');
      expect(plan.price, 2000.0);
      expect(plan.features, ['Feature A', 'Feature B']);
      expect(plan.productLimit, 50);
      expect(plan.billingPeriod, 'monthly');
      expect(plan.durationDays, isNull);
    });

    test('maps anytime plan with durationDays', () {
      final json = {
        'id': 'plan-2',
        'name': 'Trial',
        'slug': 'trial',
        'price': 500,
        'features': <String>[],
        'productLimit': 10,
        'isActive': true,
        'billingPeriod': 'anytime',
        'durationDays': 45,
      };
      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.billingPeriod, 'anytime');
      expect(plan.durationDays, 45);
    });
  });

  group('VendorSubscription.fromJson (API shape)', () {
    test('maps camelCase fields and nested plan', () {
      final json = {
        'id': 'sub-1',
        'userId': 'user-1',
        'planId': 'plan-1',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': '2026-09-01T00:00:00.000Z',
        'plan': {
          'id': 'plan-1',
          'name': 'Starter',
          'slug': 'starter',
          'price': 2000,
          'features': <String>[],
          'productLimit': 50,
          'isActive': true,
          'billingPeriod': 'monthly',
        },
      };
      final sub = VendorSubscription.fromJson(json);
      expect(sub.userId, 'user-1');
      expect(sub.planId, 'plan-1');
      expect(sub.plan?.name, 'Starter');
      expect(sub.plan?.billingPeriod, 'monthly');
    });

    test('plan is null when absent', () {
      final json = {
        'id': 'sub-2',
        'userId': 'user-2',
        'planId': 'plan-2',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': '2026-09-01T00:00:00.000Z',
      };
      final sub = VendorSubscription.fromJson(json);
      expect(sub.plan, isNull);
    });

    test('isActive is true only when status is ACTIVE and endDate is in the future', () {
      final future = DateTime.now().add(const Duration(days: 10));
      final json = {
        'id': 'sub-3',
        'userId': 'user-3',
        'planId': 'plan-3',
        'status': 'ACTIVE',
        'startDate': '2026-08-01T00:00:00.000Z',
        'endDate': future.toIso8601String(),
      };
      expect(VendorSubscription.fromJson(json).isActive, isTrue);
    });
  });
}
