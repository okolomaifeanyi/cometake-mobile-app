import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/addresses_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/screens/vendor_product_form_screen.dart';
import '../../features/chat/presentation/screens/conversation_screen.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/vtu/domain/entities/vtu.dart';
import '../../features/vtu/presentation/screens/vtu_history_screen.dart';
import '../../features/vtu/presentation/screens/vtu_purchase_screen.dart';
import '../../features/vtu/presentation/screens/vtu_screen.dart';
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
import '../../features/home/presentation/screens/home_screen.dart';
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
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.products,
              builder: (_, state) => ProductsScreen(
                initialCategory: state.uri.queryParameters['category'],
              ),
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
              builder: (_, __) => const VtuScreen(),
              routes: [
                GoRoute(
                  path: ':serviceType',
                  builder: (_, state) {
                    final typeStr = state.pathParameters['serviceType'] ?? '';
                    final type = VtuServiceType.values.firstWhere(
                      (t) => t.name == typeStr,
                      orElse: () => VtuServiceType.airtime,
                    );
                    return VtuPurchaseScreen(serviceType: type);
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.vtuHistory,
              builder: (_, __) => const VtuHistoryScreen(),
            ),
            GoRoute(
              path: AppRoutes.chat,
              builder: (_, __) => const ConversationsScreen(),
            ),
            GoRoute(
              path: AppRoutes.conversation,
              builder: (_, state) => ConversationScreen(
                roomId: state.pathParameters['conversationId'] ?? '',
              ),
            ),
            GoRoute(
              path: AppRoutes.notifications,
              builder: (_, __) => const NotificationsScreen(),
            ),
            GoRoute(
              path: AppRoutes.addresses,
              builder: (_, __) => const AddressesScreen(),
            ),
            GoRoute(
              path: AppRoutes.wishlist,
              builder: (_, __) => const WishlistScreen(),
            ),
            GoRoute(
              path: AppRoutes.vendor,
              builder: (_, __) => const VendorDashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.vendorAddProduct,
              builder: (_, __) => const VendorProductFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.vendorEditProduct,
              builder: (_, state) {
                final productId = state.pathParameters['productId'] ?? '';
                // Product entity can be passed via extra
                final extra = state.extra as Product?;
                return VendorProductFormScreen(
                    product: extra?.id == productId ? extra : null,
                );
              },
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

class _MainShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _MainShell({required this.location, required this.child});

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.wallet,
    AppRoutes.vtu,
    AppRoutes.chat,
    AppRoutes.profile,
  ];

  int get _selectedIndex {
    if (location.startsWith(AppRoutes.wallet)) return 1;
    if (location.startsWith(AppRoutes.vtu)) return 2;
    if (location.startsWith(AppRoutes.chat) ||
        location.startsWith(AppRoutes.conversation)) return 3;
    if (location.startsWith(AppRoutes.profile) ||
        location.startsWith(AppRoutes.orders) ||
        location.startsWith('/order/') ||
        location.startsWith(AppRoutes.vendor)) return 4;
    return 0; // home, products, cart all map to Home tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.smartphone_outlined),
            selectedIcon: Icon(Icons.smartphone),
            label: 'VTU',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
