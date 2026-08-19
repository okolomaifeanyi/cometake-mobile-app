import 'app_routes.dart';

abstract final class RouterGuard {
  // The 4 pre-auth screens — signing in/up/resetting a password.
  static const _authOnlyRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.otp,
    AppRoutes.forgotPassword,
  };

  // Browsing the catalog requires no account (Guideline 5.1.1(v)).
  // Everything NOT listed here (cart, checkout, wallet, VTU, chat, orders,
  // addresses, notifications, vendor, profile, wishlist writes) stays
  // gated — those are all account-specific actions, not browsing.
  static const _publicRoutes = {
    AppRoutes.splash,
    ..._authOnlyRoutes,
    AppRoutes.home,
    AppRoutes.products,
    AppRoutes.wishlist,
  };

  // Nested paths (e.g. /products/:productId) don't appear verbatim in
  // _publicRoutes — matched by prefix instead.
  static const _publicPrefixes = {
    '/products/',
  };

  static bool _isPublic(String location) {
    if (_publicRoutes.contains(location)) return true;
    return _publicPrefixes.any(location.startsWith);
  }

  static String? redirect(String location, {required bool isAuthenticated}) {
    // Splash is a gateway — always forward into the (now public) browse
    // experience. Gated screens still redirect to login individually the
    // moment the user actually navigates to one.
    if (location == AppRoutes.splash) {
      return AppRoutes.home;
    }

    if (!isAuthenticated && !_isPublic(location)) {
      // Preserve the intended destination so login_screen.dart can send
      // the user back here instead of always to home.
      return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
    }
    if (isAuthenticated && _authOnlyRoutes.contains(location)) {
      return AppRoutes.home;
    }
    return null;
  }
}
