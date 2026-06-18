import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/supabase_cart_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';

// ─── DI ──────────────────────────────────────────────────────────────────────

final cartDatasourceProvider = Provider<SupabaseCartDatasource>(
  (ref) => SupabaseCartDatasource(ref.watch(supabaseClientProvider)),
  name: 'cartDatasourceProvider',
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(ref.watch(cartDatasourceProvider)),
  name: 'cartRepositoryProvider',
);

// ─── Notifier ────────────────────────────────────────────────────────────────

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, Cart>(CartNotifier.new,
        name: 'cartNotifierProvider');

// Convenient count badge
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).valueOrNull?.totalItems ?? 0;
});

class CartNotifier extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() async {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return const Cart();
    return ref.read(cartRepositoryProvider).getCart(userId);
  }

  String? get _userId => ref.read(currentUserProvider)?.id;

  Future<void> addItem(String productId, {int quantity = 1}) async {
    final uid = _userId;
    if (uid == null) return;
    final prev = state.valueOrNull ?? const Cart();
    // Optimistic: show loading only on first add of this item
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .addItem(userId: uid, productId: productId, quantity: quantity);
      state = AsyncData(cart);
    } on AppException catch (e) {
      state = AsyncError(ErrorHandler.handle(e), StackTrace.current);
      state = AsyncData(prev);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final uid = _userId;
    if (uid == null) return;
    if (quantity < 1) {
      await removeItem(itemId);
      return;
    }
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .updateQuantity(userId: uid, itemId: itemId, quantity: quantity);
      state = AsyncData(cart);
    } on AppException catch (e) {
      state = AsyncError(ErrorHandler.handle(e), StackTrace.current);
    }
  }

  Future<void> removeItem(String itemId) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final cart = await ref
          .read(cartRepositoryProvider)
          .removeItem(userId: uid, itemId: itemId);
      state = AsyncData(cart);
    } on AppException catch (e) {
      state = AsyncError(ErrorHandler.handle(e), StackTrace.current);
    }
  }

  Future<void> clearCart() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await ref.read(cartRepositoryProvider).clearCart(uid);
      state = const AsyncData(Cart());
    } on AppException catch (e) {
      state = AsyncError(ErrorHandler.handle(e), StackTrace.current);
    }
  }

  Future<void> refresh() async {
    final uid = _userId;
    if (uid == null) {
      state = const AsyncData(Cart());
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).getCart(uid),
    );
  }
}
