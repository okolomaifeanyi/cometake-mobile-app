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
}
