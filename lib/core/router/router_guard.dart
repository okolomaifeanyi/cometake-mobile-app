import 'app_routes.dart';

abstract final class RouterGuard {
  static const _publicRoutes = {
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.otp,
    AppRoutes.forgotPassword,
  };

  static String? redirect(String location, {required bool isAuthenticated}) {
    // Splash is a gateway — always forward to the correct destination.
    if (location == AppRoutes.splash) {
      return isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }

    final isPublic = _publicRoutes.contains(location);
    if (!isAuthenticated && !isPublic) return AppRoutes.login;
    if (isAuthenticated && isPublic) return AppRoutes.home;
    return null;
  }
}
