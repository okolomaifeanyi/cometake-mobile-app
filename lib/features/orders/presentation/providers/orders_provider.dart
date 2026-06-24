import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../data/datasources/supabase_orders_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// ─── DI ──────────────────────────────────────────────────────────────────────

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepositoryImpl(ref.watch(ordersDataSourceProvider)),
  name: 'ordersRepositoryProvider',
);

// ─── Orders list ─────────────────────────────────────────────────────────────

final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
  name: 'ordersNotifierProvider',
);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() =>
      ref.read(ordersRepositoryProvider).getMyOrders();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(ordersRepositoryProvider).getMyOrders(),);
  }
}

// ─── Order detail ─────────────────────────────────────────────────────────────

final orderDetailProvider =
    AsyncNotifierProvider.autoDispose.family<OrderDetailNotifier, Order, String>(
  OrderDetailNotifier.new,
  name: 'orderDetailProvider',
);

class OrderDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String id) =>
      ref.watch(ordersRepositoryProvider).getOrderById(id);
}

// ─── Addresses ────────────────────────────────────────────────────────────────

final addressesProvider =
    AsyncNotifierProvider<AddressesNotifier, List<Address>>(
  AddressesNotifier.new,
  name: 'addressesProvider',
);

class AddressesNotifier extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() =>
      ref.read(ordersRepositoryProvider).getAddresses();

  Future<Address?> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String state,
    bool isDefault = false,
  }) async {
    try {
      final address = await ref.read(ordersRepositoryProvider).createAddress(
            fullName: fullName,
            phone: phone,
            street: street,
            city: city,
            state: state,
            isDefault: isDefault,
          );
      final current = this.state.valueOrNull ?? [];
      this.state = AsyncData([if (isDefault) ...current.map((a) => a.copyWith(isDefault: false)) else ...current, address]);
      return address;
    } on AppException {
      return null;
    }
  }
}

// ─── Checkout / Place order ───────────────────────────────────────────────────

final checkoutProvider =
    AsyncNotifierProvider<CheckoutNotifier, Order?>(
  CheckoutNotifier.new,
  name: 'checkoutProvider',
);

class CheckoutNotifier extends AsyncNotifier<Order?> {
  @override
  Future<Order?> build() async => null;

  Future<Order?> placeOrder({required String addressId, String? notes}) async {
    state = const AsyncLoading();
    try {
      final order = await ref
          .read(ordersRepositoryProvider)
          .placeOrder(addressId: addressId, notes: notes);
      state = AsyncData(order);
      // Clear cart after successful order
      ref.read(cartNotifierProvider.notifier).clearCart();
      // Refresh orders list
      ref.invalidate(ordersNotifierProvider);
      return order;
    } on AppException catch (e) {
      state = AsyncError(ErrorHandler.handle(e), StackTrace.current);
      return null;
    } catch (e) {
      state = AsyncError(
        ErrorHandler.handle(
            const ServerException('Failed to place order.'),),
        StackTrace.current,
      );
      return null;
    }
  }

  void reset() => state = const AsyncData(null);
}
