import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/wallet/presentation/screens/topup_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';

import '../supabase/supabase_module.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'app_routes.dart';
import 'router_guard.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final supabaseClient = ref.watch(supabaseClientProvider);
    final refreshNotifier =
        _AuthRefreshNotifier(supabaseClient.auth.onAuthStateChange);

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final isAuth = supabaseClient.auth.currentUser != null;
        return RouterGuard.redirect(
          state.matchedLocation,
          isAuthenticated: isAuth,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (_, state) => OtpScreen(
            phone: state.uri.queryParameters['phone'] ?? '',
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => _MainShell(
            location: state.matchedLocation,
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Home', icon: Icons.home_outlined),
            ),
            GoRoute(
              path: AppRoutes.products,
              builder: (_, __) => const ProductsScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.productDetail,
                  builder: (_, state) => ProductDetailScreen(
                    productId: state.pathParameters['productId'] ?? '',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.cart,
              builder: (_, __) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.wallet,
              builder: (_, __) => const WalletScreen(),
              routes: [
                GoRoute(
                  path: 'topup',
                  builder: (_, __) => const TopupScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.orders,
              builder: (_, __) => const OrdersScreen(),
            ),
            GoRoute(
              path: AppRoutes.orderDetail,
              builder: (_, state) => OrderDetailScreen(
                orderId: state.pathParameters['orderId'] ?? '',
              ),
            ),
            GoRoute(
              path: '/checkout',
              builder: (_, __) => const CheckoutScreen(),
            ),
            GoRoute(
              path: AppRoutes.vtu,
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'VTU Services', icon: Icons.phone_android_outlined),
            ),
            GoRoute(
              path: AppRoutes.chat,
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Messages', icon: Icons.chat_outlined),
            ),
            GoRoute(
              path: AppRoutes.conversation,
              builder: (_, state) => _PlaceholderScreen(
                title: 'Conversation',
                icon: Icons.chat_bubble_outline,
              ),
            ),
            GoRoute(
              path: AppRoutes.vendor,
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Vendor Dashboard', icon: Icons.store_outlined),
            ),
            GoRoute(
              path: AppRoutes.vendorAddProduct,
              builder: (_, __) =>
                  const _PlaceholderScreen(title: 'Add Product', icon: Icons.add_box_outlined),
            ),
          ],
        ),
      ],
    );

    ref.onDispose(() {
      refreshNotifier.dispose();
      router.dispose();
    });

    return router;
  },
  name: 'appRouterProvider',
);

class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _AuthRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _MainShell extends ConsumerWidget {
  final String location;
  final Widget child;

  const _MainShell({required this.location, required this.child});

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.products,
    AppRoutes.cart,
    AppRoutes.wallet,
    AppRoutes.profile,
  ];

  int get _selectedIndex {
    if (location.startsWith(AppRoutes.products)) return 1;
    if (location.startsWith(AppRoutes.cart)) return 2;
    if (location.startsWith(AppRoutes.wallet)) return 3;
    if (location.startsWith(AppRoutes.profile) ||
        location.startsWith(AppRoutes.orders) ||
        location.startsWith('/order/') ||
        location.startsWith(AppRoutes.vtu) ||
        location.startsWith(AppRoutes.chat) ||
        location.startsWith(AppRoutes.vendor)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Coming in a future phase',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
