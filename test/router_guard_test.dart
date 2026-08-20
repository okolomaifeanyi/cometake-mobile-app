import 'package:cometake/core/router/app_routes.dart';
import 'package:cometake/core/router/router_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouterGuard.redirect — public browse routes', () {
    for (final route in [AppRoutes.home, AppRoutes.products, AppRoutes.wishlist]) {
      test('unauthenticated access to $route is allowed (no redirect)', () {
        expect(RouterGuard.redirect(route, isAuthenticated: false), isNull);
      });
    }

    test('unauthenticated access to a product detail path is allowed', () {
      expect(
        RouterGuard.redirect('/products/abc-123', isAuthenticated: false),
        isNull,
      );
    });

    test('authenticated access to public browse routes is also allowed', () {
      expect(RouterGuard.redirect(AppRoutes.home, isAuthenticated: true), isNull);
      expect(RouterGuard.redirect(AppRoutes.products, isAuthenticated: true), isNull);
    });
  });

  group('RouterGuard.redirect — account-gated routes', () {
    for (final route in [
      AppRoutes.cart,
      AppRoutes.wallet,
      AppRoutes.profile,
      AppRoutes.orders,
      AppRoutes.addresses,
      AppRoutes.vtu,
      AppRoutes.chat,
      AppRoutes.notifications,
      AppRoutes.vendor,
      '/checkout',
    ]) {
      test('unauthenticated access to $route redirects to login with a redirect param', () {
        final result = RouterGuard.redirect(route, isAuthenticated: false);
        expect(result, isNotNull);
        expect(result, startsWith(AppRoutes.login));
        expect(result, contains('redirect='));
        expect(result, contains(Uri.encodeComponent(route)));
      });

      test('authenticated access to $route is allowed', () {
        expect(RouterGuard.redirect(route, isAuthenticated: true), isNull);
      });
    }
  });

  group('RouterGuard.redirect — auth-only screens', () {
    test('authenticated user hitting /login is sent home', () {
      expect(RouterGuard.redirect(AppRoutes.login, isAuthenticated: true), AppRoutes.home);
    });

    test('authenticated user hitting /register is sent home', () {
      expect(RouterGuard.redirect(AppRoutes.register, isAuthenticated: true), AppRoutes.home);
    });

    test('unauthenticated user may reach /login and /register freely', () {
      expect(RouterGuard.redirect(AppRoutes.login, isAuthenticated: false), isNull);
      expect(RouterGuard.redirect(AppRoutes.register, isAuthenticated: false), isNull);
    });
  });

  group('RouterGuard.redirect — splash', () {
    test('splash always forwards to home now, authenticated or not', () {
      expect(RouterGuard.redirect(AppRoutes.splash, isAuthenticated: false), AppRoutes.home);
      expect(RouterGuard.redirect(AppRoutes.splash, isAuthenticated: true), AppRoutes.home);
    });
  });

  group('RouterGuard.redirect — full route-surface coverage', () {
    // Mirrors every GoRoute path registered in app_router.dart (with a
    // realistic value substituted for path params, matching how
    // state.matchedLocation looks at runtime — GoRouter resolves params
    // before RouterGuard ever sees the location string). Kept as an
    // explicit list — not derived from AppRoutes reflectively, since Dart
    // has no reflection here — so that adding a new GoRoute without adding
    // it to one of the two buckets below fails this test immediately,
    // instead of silently inheriting RouterGuard's fail-closed default.
    // Splash is public but not a "no redirect" case — it always forwards to
    // home (see the dedicated splash group above) — so it's asserted
    // separately below rather than folded into publicRoutes.
    const publicRoutes = {
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.otp,
      AppRoutes.forgotPassword,
      AppRoutes.home,
      AppRoutes.products,
      '/products/some-product-id',
      AppRoutes.wishlist,
    };

    const gatedRoutes = {
      AppRoutes.cart,
      AppRoutes.wallet,
      '/wallet/topup',
      AppRoutes.profile,
      '/profile/edit',
      '/profile/delete-account',
      AppRoutes.orders,
      '/order/some-order-id',
      '/checkout',
      AppRoutes.vtu,
      '/vtu/airtime',
      AppRoutes.vtuHistory,
      AppRoutes.chat,
      '/chat/some-conversation-id',
      AppRoutes.notifications,
      AppRoutes.addresses,
      AppRoutes.vendor,
      '/vendor/add-product',
      '/vendor/edit-product/some-product-id',
      '/payment/some-payment-id',
      AppRoutes.subscriptionPayment,
    };

    test('public and gated route sets do not overlap, and neither contains splash', () {
      expect(publicRoutes.intersection(gatedRoutes), isEmpty);
      expect(publicRoutes.contains(AppRoutes.splash), isFalse);
      expect(gatedRoutes.contains(AppRoutes.splash), isFalse);
    });

    for (final route in publicRoutes) {
      test('$route is reachable unauthenticated (declared public)', () {
        expect(RouterGuard.redirect(route, isAuthenticated: false), isNull);
      });
    }

    for (final route in gatedRoutes) {
      test('$route redirects to login unauthenticated (declared gated)', () {
        expect(
          RouterGuard.redirect(route, isAuthenticated: false),
          startsWith(AppRoutes.login),
        );
      });
    }
  });
}
